//
//  CircularQueue.h
//  HYBase
//
//  Created by Arokenda on 2017/8/1.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//Note: endIndex不指向实际对象，而是指向用于标示尾部的占位符

@interface CircularQueue : NSObject

//barrage dispatcher.
- (instancetype)initWithLength:(int)length removeObjectWhenFull:(BOOL)remove;

- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (BOOL)isEmpty;
- (BOOL)isFull;

- (void)removeFirstObject;
- (void)removeFrontObjectWithCount:(int)count;

- (void)addObject:(id)anObject;
- (void)addObjectInFront:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)addObjectsFromCircularQueue:(CircularQueue *)otherQueue;
- (void)clear;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)insertObjectsFromCircularQueue:(CircularQueue *)otherQueue atIndex:(NSInteger)index;
- (CircularQueue *)filteredCircularQueueUsingBlock:(BOOL (^)(id obj))block;

#pragma mark - queue public api
- (void)enqueue:(id)anObject;
- (id)dequeue;
- (id)front;
@end
