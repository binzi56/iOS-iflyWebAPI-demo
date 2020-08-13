//
//  HYThreadSafeSet.m
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "HYThreadSafeSet.h"
#import "HYSpinLock.h"

#define LOCK(...) \
[self.lock lock]; \
__VA_ARGS__; \
[self.lock unlock];

//使用内聚一个NSMutableSet的方式，
//因为NSSet是一个类簇，直接继承其子类NSMutableSet，会有问题

@interface HYThreadSafeSet ()
@property (nonatomic, strong)HYSpinLock  *lock;
@property (nonatomic, strong)NSMutableSet  *set;
@end

@implementation HYThreadSafeSet

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[HYSpinLock alloc] init];
        self.set = [NSMutableSet set];
    }
    return self;
}

- (NSSet *)inner
{
    return [self.set copy];
}

- (id)anyObject
{
    [self.lock lock];
    id value = [self.set anyObject];
    [self.lock unlock];
    
    return value;
}

- (void)addObject:(id)object
{
    LOCK([self.set addObject:object]);
}

- (void)removeObject:(id)object
{
    LOCK([self.set removeObject:object]);
}

- (void)removeAllObjects
{
    LOCK([self.set removeAllObjects]);
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
    [self.lock lock];
    [self.set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
    [self.lock unlock];
}

@end
