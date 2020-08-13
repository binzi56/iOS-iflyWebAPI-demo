//
//  WFCacheManager+IWFDataCenterCacheProxy.m
//  kiwi
//
//  Created by hpf1908 on 2017/1/12.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#if __has_include(<YYDiskCache.h>)
#import <YYDiskCache.h>
#else
#import "YYDiskCache.h"
#endif

#import "HYCacheManager+IHYDataCenterCacheProxy.h"

@implementation HYCacheManager (IHYDataCenterCacheProxy)

- (id)huyaObjectForKey:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)huyaSetObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key];
}

- (void)huyaRemoveObjectForKey:(NSString *)key
{
    [self removeObjectForKey:key];
}

- (void)huyaRemoveAllObjects
{
    [self removeAllObjects:nil];
}

- (CFAbsoluteTime)cachedTimeForObject:(id)object
{
    NSData *data = [YYDiskCache getExtendedDataFromObject:object];
    CFAbsoluteTime cachedTime;
    [data getBytes:&cachedTime length:sizeof(CFAbsoluteTime)];
    return cachedTime;
}

- (void)saveCachedTime:(CFAbsoluteTime)cachedTime forObject:(id)object
{
    NSData *data = [NSData dataWithBytes:&cachedTime length:sizeof(CFAbsoluteTime)];
    [YYDiskCache setExtendedData:data toObject:object];
}

@end
