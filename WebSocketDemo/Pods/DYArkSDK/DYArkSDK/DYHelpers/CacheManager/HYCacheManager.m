//
//  HYCacheManager.m
//  kiwi
//
//  Created by lslin on 16/7/22.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYCacheManager.h"
//#import "YYCache/YYCache.h"
#import "YYCache.h"

@interface HYCacheManager()

@property(nonatomic,strong) YYCache* cache;

@end

@implementation HYCacheManager

+ (instancetype)sharedManager
{
    static id sharedCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCacheManager = [[self alloc] init];
    });
    return sharedCacheManager;
}

+ (id<IHYCache>)createMemoryCache
{
    HYMemoryCache* memoryCache = [[HYMemoryCache alloc] init];
    return memoryCache;
}

- (YYCache *)cache
{
    if (!_cache) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //懒加载
            _cache = [[YYCache alloc] initWithName:NSStringFromClass([self class])];
            //内存cache在memorywarning时移除
            _cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
        });
    }
    return _cache;
}


#pragma mark - Public

- (uint64_t)diskTotalCost
{
    return [self.cache.diskCache totalCost];
}

- (id)objectForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

- (void)objectForKey:(NSString *)key block:(HYCacheManagerObjectBlock)block
{
    [self.cache objectForKey:key withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        if (block) {
            block(key, object);
        }
    }];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    [self.cache setObject:object forKey:key withBlock:nil];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(HYCacheManagerObjectBlock)block
{
    [self.cache setObject:object forKey:key withBlock:^{
        if (block) {
            block(key, object);
        }
    }];
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key block:(HYCacheManagerObjectBlock)block
{
    [self.cache removeObjectForKey:key withBlock:^(NSString * _Nonnull key) {
        if (block) {
            block(nil , nil);
        }
    }];
}

- (void)removeAllObjects:(HYCacheManagerObjectBlock)block
{
    [self.cache removeAllObjectsWithBlock:^{
        if (block) {
            block(nil , nil);
        }
    }];
}

- (id<IHYCache>)memoryCache
{
    return (id<IHYCache>)self.cache.memoryCache;
}

@end
