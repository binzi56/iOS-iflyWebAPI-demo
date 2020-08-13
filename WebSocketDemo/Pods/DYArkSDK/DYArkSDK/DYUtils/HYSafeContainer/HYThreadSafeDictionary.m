//
//  HYThreadSafeDictionary.m
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "HYThreadSafeDictionary.h"
#import "HYSpinLock.h"

#define LOCK(...) \
[self.lock lock]; \
__VA_ARGS__; \
[self.lock unlock];

//使用内聚一个NSMutableDictionary的方式，
//因为NSDictionary是一个类簇，直接继承其子类NSMutableDictionary，会有问题

@interface HYThreadSafeDictionary ()
@property (nonatomic, strong)HYSpinLock  *lock;
@property (nonatomic, strong)NSMutableDictionary  *dictionary;
@end

@implementation HYThreadSafeDictionary

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[HYSpinLock alloc] init];
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)inner
{
    return [self.dictionary copy];
}

- (id)objectForKey:(id)aKey
{
    [self.lock lock];
    id value = [self.dictionary objectForKey:aKey];
    [self.lock unlock];
    
    return value;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    LOCK([self.dictionary setObject:anObject forKey:aKey]);
}

- (void)removeObjectForKey:(id)aKey
{
    LOCK([self.dictionary removeObjectForKey:aKey]);
}

- (void)removeAllObjects
{
    LOCK([self.dictionary removeAllObjects]);
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL * stop))block
{
    [self.lock lock];
    [self.dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj, stop);
    }];
    [self.lock unlock];
}

@end
