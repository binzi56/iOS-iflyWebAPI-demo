//
//  CircularQueue.m
//  HYBase
//
//  Created by Arokenda on 2017/8/1.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "CircularQueue.h"
#import "KiwiSDKMacro.h"

//TODO:抽离CircularQueue并支持下标访问

int getCircularQueueLength()
{
    if (IS_LOW_PERFORMANCE_DEVICE)
        return 100;
    else
        return 200;
}


@interface CircularQueue()
{
    NSUInteger _realLength;
    NSUInteger _beginIndex;
    NSUInteger _endIndex;
    BOOL       _remove;
}

@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation CircularQueue

#pragma mark LifeCycle

- (id)init
{
    /*
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Must use initWithLength: instead."
                                 userInfo:nil];*/
    return [self initWithLength:getCircularQueueLength()];
}

- (id)initWithLength:(NSUInteger)length
{
    self = [super init];
    if (self) {
        _realLength = length + 1;
        _beginIndex = 0;
        _endIndex = 0;
        _remove = YES;
    }
    return self;
}

- (instancetype)initWithLength:(int)length removeObjectWhenFull:(BOOL)remove
{
    if (self = [super init]) {
        _realLength = length + 1;
        _beginIndex = 0;
        _endIndex = 0;
        _remove = remove;
    }
    return self;
}

#pragma mark Property

- (NSMutableArray *)queue
{
    if (_queue == nil) {
        _queue = [[NSMutableArray alloc] initWithCapacity:_realLength];
        for (NSUInteger i = 0; i < _realLength; ++i) {
            [_queue addObject:[NSNull null]];
        }
    }
    return _queue;
}

#pragma mark Public

- (id)objectAtIndex:(NSUInteger)index
{
    NSAssert(index < [self count], @"[CircularQueue] Out of range!");
    const NSUInteger i = [self increaseIndex:_beginIndex withOffset:index];
    return self.queue[i];
}

- (NSUInteger)count
{
    return (_endIndex + _realLength - _beginIndex) % _realLength;
}

- (BOOL)isEmpty
{
    return _beginIndex == _endIndex;
}

- (BOOL)isFull
{
    return _beginIndex == [self increaseIndex:_endIndex withOffset:1];
}

- (void)removeFirstObject
{
    if ([self count]) {
        _beginIndex = [self increaseIndex:_beginIndex withOffset:1];
    }
}

- (void)removeFrontObjectWithCount:(int)count
{
    if ([self count] >= count) {
        _beginIndex = [self increaseIndex:_beginIndex withOffset:count];
    } else {
        [self clear];
    }
}

- (void)addObject:(id)anObject
{
    [self addObjectToQueue:anObject];
}

- (void)addObjectInFront:(id)anObject
{
    [self addObjectInFrontToQueue:anObject];
}

- (void)addObjectsFromArray:(NSArray *)otherArray
{
    if ([otherArray count] == 0) {
        return;
    }
    [otherArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addObjectToQueue:obj];
    }];
}

- (void)addObjectsFromCircularQueue:(CircularQueue *)otherQueue
{
    const NSUInteger otherQueueCount = [otherQueue count];
    if (otherQueueCount == 0) {
        return;
    }
    
    for (NSUInteger i = 0; i < otherQueueCount; ++i) {
        id obj = [otherQueue objectAtIndex:i];
        if (!obj) {
             KWSLogInfo(@"otherQueue: %@",otherQueue);
        }
        
        [self addObjectToQueue:obj];
    }
}

- (void)insertObjectsFromCircularQueue:(CircularQueue *)otherQueue atIndex:(NSInteger)index
{
    const NSUInteger otherQueueCount = [otherQueue count];
    if (otherQueueCount == 0) {
        return;
    }
    NSAssert(index < [self count], @"[CircularQueue] Out of range!");
    id oriObj = [self objectAtIndex:index];
    [self replaceObjectAtIndex:index withObject:[otherQueue objectAtIndex:0]];
    for (NSUInteger i = 1; i < otherQueueCount; ++i) {
        id obj = [otherQueue objectAtIndex:i];
        [self addObjectToQueue:obj];
    }
    [self addObjectToQueue:oriObj];
}

- (void)clear
{
    //[NOTE] 为避免频繁释放分配_queue，不将_queue置空
    _beginIndex = 0;
    _endIndex = 0;
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj
{
    if (!obj) {
        KWSLogError(@"anObject == nil");
        return;
    }
    if (index < [self count] && obj) {
        const NSUInteger i = [self increaseIndex:_beginIndex withOffset:index];
        [self.queue replaceObjectAtIndex:i withObject:obj];
    }
}

- (CircularQueue *)filteredCircularQueueUsingBlock:(BOOL (^)(id obj))block
{
    CircularQueue *tmpQueue = [[CircularQueue alloc] initWithLength:(int)(_realLength - 1) removeObjectWhenFull:_remove];
    for (int i = 0; i < (int)[self count]; i++) {
        id obj = [self objectAtIndex:i];
        if (block && block(obj)) {
            [tmpQueue addObjectToQueue:obj];
        }
    }
    return tmpQueue;
}

#pragma mark Private

- (void)addObjectToQueue:(id)anObject
{
    if (!anObject) {
        KWSLogError(@"anObject == nil");
        return;
    }
    static int32_t kMinRemovedCountWhenFull = 50;
    if (IS_LOW_PERFORMANCE_DEVICE){
        kMinRemovedCountWhenFull = 30;
    }
    
    self.queue[_endIndex] = anObject;
    
    if ([self isFull] && _remove) {
        NSAssert(kMinRemovedCountWhenFull > 0 && kMinRemovedCountWhenFull <= getCircularQueueLength(), @"Invalid Removed Count");
        _beginIndex = [self increaseIndex:_beginIndex withOffset:kMinRemovedCountWhenFull];
        KWSLogInfo(@"[ChannelText: OutRange] addObjectToQueue, beginIndex: %u", (uint32_t)_beginIndex);
    }
    _endIndex = [self increaseIndex:_endIndex withOffset:1];
}

- (void)addObjectInFrontToQueue:(id)anObject
{
    if (!anObject) {
        KWSLogError(@"anObject == nil");
        return;
    }
    static int32_t kMinRemovedCountWhenFull = 50;
    if (IS_LOW_PERFORMANCE_DEVICE){
        kMinRemovedCountWhenFull = 30;
    }
    
    if ([self isFull] && _remove) {
        NSAssert(kMinRemovedCountWhenFull > 0 && kMinRemovedCountWhenFull <= getCircularQueueLength(), @"Invalid Removed Count");
        _beginIndex = [self increaseIndex:_beginIndex withOffset:kMinRemovedCountWhenFull];
        KWSLogInfo(@"[ChannelText: OutRange] addObjectToQueue, beginIndex: %u", (uint32_t)_beginIndex);
    }
    _beginIndex = [self increaseIndex:_beginIndex withOffset:-1];
    self.queue[_beginIndex] = anObject;
}

- (NSUInteger)increaseIndex:(NSUInteger)index withOffset:(NSUInteger)offset
{
    return (_realLength > 0) ? (index + offset + _realLength) % _realLength : 0;
}

#pragma mark - queue public api

- (void)enqueue:(id)anObject
{
    [self addObjectToQueue:anObject];
}

- (id)dequeue
{
    id front = [self front];
    [self removeFirstObject];
    return front;
}

- (id)front
{
    if (![self count]) {
        return nil;
    }
    return [self objectAtIndex:0];
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

