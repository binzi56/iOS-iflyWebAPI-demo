//
//  KiwiCacheManager.h
//  kiwi
//
//  Created by lslin on 16/7/22.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYCache.h"

@interface HYCacheManager : NSObject

@property(nonatomic,strong,readonly) id<IHYCache> memoryCache;

+ (instancetype)sharedManager;

+ (id<IHYCache>)createMemoryCache;

- (uint64_t)diskTotalCost;

/**
 *  同步返回对象
 */
- (id)objectForKey:(NSString *)key;

/**
 *  异步返回对象
 */
- (void)objectForKey:(NSString *)key block:(HYCacheManagerObjectBlock)block;

/**
 *  异步异步对象，block = nil
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

/**
 *  异步异步对象
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(HYCacheManagerObjectBlock)block;

/**
 *  同步删除对象
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 *  异步删除对象
 */
- (void)removeObjectForKey:(NSString *)key block:(HYCacheManagerObjectBlock)block;

/**
 *  清除所有
 */
- (void)removeAllObjects:(HYCacheManagerObjectBlock)block;

@end
