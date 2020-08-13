//
//  HYCache.m
//  kiwi
//
//  Created by pengfeihuang on 16/11/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYCache.h"
//#import "YYCache/YYCache.h"
#import "YYCache.h"

@interface HYMemoryCache()

@property(nonatomic,strong) YYMemoryCache* cache;

@end

@implementation HYMemoryCache

- (instancetype)init
{
    if (self = [super init]) {
        _cache = [[YYMemoryCache alloc] init];
        _cache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return [_cache objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [_cache setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    [_cache removeObjectForKey:key];
}

- (void)removeAllObjects:(HYCacheManagerObjectBlock)block
{
    [_cache removeAllObjects];
    
    if (block) {
        block(nil,nil);
    }
}

@end
