//
//  HYGCDQueuePool.m
//  HYBase
//
//  Created by lslin on 2017/9/29.
//  Copyright © 2017年 huya.com. All rights reserved.
//

#import "HYGCDQueuePool.h"
#import <libkern/OSAtomic.h>

#pragma mark - HYGCDQueue

@class HYGCDQueue;

@protocol HYGCDQueueDelegate <NSObject>

@required
- (void)HYGCDQueueDidFinish:(HYGCDQueue *)queue;

@end

@interface HYGCDQueue: NSObject

@property (nonatomic, weak) id<HYGCDQueueDelegate> delegate;
@property (nonatomic, strong) NSString *name;
@property (atomic, assign) BOOL isFree;
@property (nonatomic, strong) dispatch_queue_t queue;

- (instancetype)initWithDelegate:(id<HYGCDQueueDelegate>)delegate name:(NSString *)name;
- (BOOL)dispatchWithBlock:(dispatch_block_t)block;

@end

@implementation HYGCDQueue

- (instancetype)initWithDelegate:(id<HYGCDQueueDelegate>)delegate name:(NSString *)name {
    if (self = [super init]) {
        _delegate = delegate;
        _name = name;
        _isFree = YES;
        _queue = dispatch_queue_create([self.name UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)dispatchWithBlock:(dispatch_block_t)block {
    if (!self.isFree) {
        //KWSLogInfo(@"%@ is not free", self.name);
        return NO;
    }
    
    //KWSLogInfo(@"dispatch task to: %@", self.name);
    
    self.isFree = NO;
    dispatch_async(self.queue, ^{
        block();
        [self.delegate HYGCDQueueDidFinish:self];
    });
    
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"HYGCDQueue.name: %@, isFree: %d", self.name, self.isFree];
}

@end

#pragma mark - HYGCDQueuePool

#define hy_gcd_queue_pool_lock_semaphore(semaphore)     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
#define hy_gcd_queue_pool_unlock_semaphore(semaphore)     dispatch_semaphore_signal(semaphore);

@interface HYGCDQueuePool : NSObject <HYGCDQueueDelegate>

@property (nonatomic, assign) long poolID;
@property (nonatomic, assign) long maxQueueCount;
@property (nonatomic, strong) NSMutableArray *queues;
@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) dispatch_semaphore_t dispatchSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t taskSemaphore;

- (instancetype)initWithID:(long)poolID maxQueueCount:(long)maxQueueCount;
- (void)dispatchWithBlock:(dispatch_block_t)block;

@end

@implementation HYGCDQueuePool

- (instancetype)initWithID:(long)poolID maxQueueCount:(long)maxQueueCount {
    if (self = [super init]) {
        _poolID = poolID;
        _maxQueueCount = maxQueueCount;
        _queues = [NSMutableArray array];
        _tasks = [NSMutableArray array];
        
        _dispatchSemaphore = dispatch_semaphore_create(1);
        _taskSemaphore = dispatch_semaphore_create(1);
        
        //KWSLogInfo(@"init with poolID: %ld, maxQueueCount: %ld", poolID, maxQueueCount);
    }
    return self;
}

- (void)dispatchWithBlock:(dispatch_block_t)block {
    hy_gcd_queue_pool_lock_semaphore(self.dispatchSemaphore);
    
    HYGCDQueue *queue = [self getFreeQueue];
    if (!queue) {
        queue = [self createQueue];
    }
    
    hy_gcd_queue_pool_unlock_semaphore(self.dispatchSemaphore);
    
    if (queue && [queue dispatchWithBlock:block]) {
        return;
    }
    
    [self.tasks addObject:block];
}

#pragma mark - Delegate

- (void)HYGCDQueueDidFinish:(HYGCDQueue *)queue {
    //KWSLogInfo(@"done with queue: %@", queue.name);
    
    hy_gcd_queue_pool_lock_semaphore(self.taskSemaphore);
    
    if (self.tasks.count) {
        dispatch_block_t block = self.tasks[0];
        
        hy_gcd_queue_pool_lock_semaphore(self.dispatchSemaphore);
        
        queue.isFree = YES;
        if ([queue dispatchWithBlock:block]) {
            [self.tasks removeObject:block];
        }
        
        hy_gcd_queue_pool_unlock_semaphore(self.dispatchSemaphore);
    } else {
        queue.isFree = YES;
    }
    
    hy_gcd_queue_pool_unlock_semaphore(self.taskSemaphore);
}

#pragma mark - Private

- (HYGCDQueue *)getFreeQueue {
    for (HYGCDQueue *queue in self.queues) {
        if (queue.isFree) {
            return queue;
        }
    }
    return nil;
}

- (HYGCDQueue *)createQueue {
    if (self.queues.count >= self.maxQueueCount) {
        return nil;
    }
    HYGCDQueue *queue = [[HYGCDQueue alloc] initWithDelegate:self name:[NSString stringWithFormat:@"com.huya.kiwi.gcdPool_%ld_Queue_%d", self.poolID, (int)self.queues.count]];
    [self.queues addObject:queue];
    return queue;
}

@end

#pragma mark - HYGCDQueuePoolManager

@interface HYGCDQueuePoolManager ()

@property (nonatomic, strong) NSMutableDictionary *poolDict;
@property (nonatomic, assign) BOOL enable;

- (HYGCDQueuePool *)getPoolByID:(long)poolID;

@end

@implementation HYGCDQueuePoolManager

+ (instancetype)sharedObject {
    static HYGCDQueuePoolManager *_mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[HYGCDQueuePoolManager alloc] init];
    });
    return _mgr;
}

- (id)init {
    if (self = [super init]) {
        _poolDict = [NSMutableDictionary dictionary];
        _enable = YES;
        //一次性创建多个线程池，避免创建线程池本身也需要加锁解锁。
        NSArray *poolIDs = @[@(HY_DISPATCH_QUEUE_POOL_ID_BIZ), @(HY_DISPATCH_QUEUE_POOL_ID_MODEL)];
        for (NSNumber *poolID in poolIDs) {
            [_poolDict setObject:[[HYGCDQueuePool alloc] initWithID:[poolID longValue] maxQueueCount:HY_DISPATCH_QUEUE_POOL_DEFAULT_QUEUE_COUNT] forKey:poolID];
        }
    }
    return self;
}

- (HYGCDQueuePool *)getPoolByID:(long)poolID {
    HYGCDQueuePool *pool = self.poolDict[@(poolID)];
    if (pool) {
        return pool;
    }
    return nil;
}

#pragma mark - Helper

- (BOOL)enableGCDQueuePool
{
    if (!self.enable) {
        return NO;
    }
    if (self.delegate) {
        self.enable = [self.delegate hyGCDQueuePoolManagerEnable];
        return self.enable;
    }
    return YES;
}

@end

#pragma mark - C

void hy_dispatch_async(long poolID, dispatch_block_t block) {
    if (block) {
        if ([[HYGCDQueuePoolManager sharedObject] enableGCDQueuePool]) {
            [[[HYGCDQueuePoolManager sharedObject] getPoolByID:poolID] dispatchWithBlock:block];
        } else {
            //如果不能使用 GCDQueuePool，则调回原生 API。
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
        }
    }
}

void hy_dispatch_async_biz(dispatch_block_t block) {
    hy_dispatch_async(HY_DISPATCH_QUEUE_POOL_ID_BIZ, block);
}

void hy_dispatch_async_model(dispatch_block_t block) {
    hy_dispatch_async(HY_DISPATCH_QUEUE_POOL_ID_MODEL, block);
}
