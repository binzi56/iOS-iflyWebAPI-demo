//
//  HYThreadSafeDictionary.h
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//
//【NOTE】
//线程安全的可变字典，读写操作时有自旋锁保护

#import <Foundation/Foundation.h>

@interface HYThreadSafeDictionary : NSObject

- (NSDictionary *)inner;

- (id)objectForKey:(id)aKey;

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;

//会锁住整个遍历过程，如果block里的操作相对耗时，业务层可以对inner遍历，而不是调用该方法遍历
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL * stop))block;

@end
