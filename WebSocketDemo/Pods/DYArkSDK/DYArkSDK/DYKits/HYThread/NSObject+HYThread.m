//
//  NSObject+ThreadAbout.m
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "NSObject+HYThread.h"

void dispatch_async_main_queue_safe(dispatch_block_t block)
{
    if (!block) return;
    
    static const void* mainQueueKey = @"mainQueue";
    static void* mainQueueContext = @"mainQueue";
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, mainQueueContext, nil);
    });
    
    if (dispatch_get_specific(mainQueueKey) == mainQueueContext) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@implementation NSObject (ThreadAbout)

- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName
{
    [self postNotificationInMainThreadWithName:aName object:nil userInfo:nil];
}

- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName userInfo:(nullable NSDictionary *)aUserInfo
{
    [self postNotificationInMainThreadWithName:aName object:nil userInfo:aUserInfo];
}

- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    if (aName.length == 0) return;
    
    dispatch_async_main_queue_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
    });
}

@end
