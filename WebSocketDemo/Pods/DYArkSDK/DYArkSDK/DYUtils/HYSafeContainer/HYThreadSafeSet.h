//
//  HYThreadSafeSet.h
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//
//【NOTE】
//线程安全的可变集，读写操作时有自旋锁保护

#import <Foundation/Foundation.h>

@interface HYThreadSafeSet : NSObject

- (NSSet *)inner;

- (id)anyObject;

- (void)addObject:(id)object;

- (void)removeObject:(id)object;
- (void)removeAllObjects;

//会锁住整个遍历过程，如果block里的操作相对耗时，业务层可以对inner遍历，而不是调用该方法遍历
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;

@end
