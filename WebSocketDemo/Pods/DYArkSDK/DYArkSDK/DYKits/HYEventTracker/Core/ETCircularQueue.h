////  ETCircularQueue.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/10.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETCircularQueue : NSObject

- (instancetype)initWithCapacity:(NSInteger)capacity;
- (void)addObject:(id)object;
- (NSUInteger)count;
- (void)reverseEnumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
