//
//  HYThreadSafeArray.h
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//
//【NOTE】
//线程安全的可变数组，读写操作时有自旋锁保护

#import <Foundation/Foundation.h>

@interface HYThreadSafeArray : NSObject

- (NSArray *)inner;

- (id)objectAtIndex:(NSUInteger)index;

- (void)addObject:(id)anObject;
- (void)removeObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeAllObjects;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

//会锁住整个遍历过程，如果block里的操作相对耗时，业务层可以对inner遍历，而不是调用该方法遍历
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
