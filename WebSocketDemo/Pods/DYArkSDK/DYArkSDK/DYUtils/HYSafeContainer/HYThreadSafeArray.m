//
//  HYThreadSafeArray.m
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "HYThreadSafeArray.h"
#import "HYSpinLock.h"

#define LOCK(...) \
[self.lock lock]; \
__VA_ARGS__; \
[self.lock unlock];

//使用内聚一个NSMutableArray的方式，
//因为NSArray是一个类簇，直接继承其子类NSMutableArray，会有问题

@interface HYThreadSafeArray ()
@property (nonatomic, strong)HYSpinLock  *lock;
@property (nonatomic, strong)NSMutableArray  *array;
@end

@implementation HYThreadSafeArray

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[HYSpinLock alloc] init];
        self.array = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)inner
{
    return [self.array copy];
}

- (id)objectAtIndex:(NSUInteger)index
{
    [self.lock lock];
    id value = [self.array objectAtIndex:index];
    [self.lock unlock];
    
    return value;
}

- (void)addObject:(id)anObject
{
    LOCK([self.array addObject:anObject]);
}
- (void)removeObject:(id)anObject
{
    LOCK([self.array removeObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray
{
    LOCK([self.array addObjectsFromArray:otherArray]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    LOCK([self.array insertObject:anObject atIndex:index]);
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    LOCK([self.array removeObjectAtIndex:index]);
}

- (void)removeLastObject
{
    LOCK([self.array removeLastObject]);
}

- (void)removeAllObjects
{
    LOCK([self.array removeAllObjects]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    LOCK([self.array replaceObjectAtIndex:index withObject:anObject]);
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    LOCK([self.array exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self.lock lock];
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx, stop);
    }];
    [self.lock unlock];
}

@end
