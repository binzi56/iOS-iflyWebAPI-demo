//
//  HYCache.h
//  kiwi
//
//  Created by pengfeihuang on 16/11/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HYCacheManagerBlock)();
typedef void (^HYCacheManagerObjectBlock)(NSString *key, id object);

@protocol IHYCache <NSObject>

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObjects:(HYCacheManagerObjectBlock)block;

@end

@interface HYMemoryCache : NSObject<IHYCache>

@end
