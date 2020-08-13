//
//  NSObject+YYAdd.m
//  YYCategories <https://github.com/ibireme/YYCategories>
//
//  Created by ibireme on 14/10/8.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSObject+DY.h"
#import "YYCategoriesMacro.h"
#import <objc/objc.h>
#import <objc/runtime.h>

static NSString *kDYEventsKey;

@implementation NSObject (DY)

- (void)dy_sendNotification:(NSString *)name obj:(id)object
{
    //创建一个消息对象
    NSNotification *notice = [NSNotification notificationWithName:name object:object userInfo:nil];
    //发送消息
    [[NSNotificationCenter defaultCenter] postNotification:notice];
}

- (void)setDYEvents:(NSMutableDictionary *)dicts
{
    objc_setAssociatedObject(self, &kDYEventsKey, dicts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)dyEvents
{
    NSMutableDictionary *events = objc_getAssociatedObject(self, &kDYEventsKey);
    
    if (!events) {
        events = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    [self setDYEvents:events];
    return events;
}

- (id)dy_addObserver:(NSString *)name
            block:(void(^)(NSNotification *notification))block
{
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:nil usingBlock:block];
    [[self dyEvents] setObject:observer forKey:name];
    return observer;
}

- (void)dy_removeObserver:(NSString *)name
{
    id observer = [[self dyEvents] objectForKey:name];
    
    if (!observer) {
        return;
    }
    
    if(name.length <= 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
    }
    
    [[self dyEvents] removeObjectForKey:name];
}

- (void)dy_clearEvents
{
    NSMutableDictionary *events = [self dyEvents];
    
    for(id key in events)
    {
        id observer = [events objectForKey:key];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [events removeAllObjects];
}

@end
