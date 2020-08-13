//
//  EventCenter.m
//  kiwi
//
//  Created by pengfeihuang on 16/6/21.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "EventCenter.h"
#import "NSObject+HYThread.h"

@interface EventCenter()

@property(nonatomic,strong) NSMutableDictionary* eventsDicts;

@end

@implementation EventCenter

- (instancetype)init
{
    if (self = [super init]) {
        _eventsDicts = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)performBlockInMainThread:(void (^)(void))completeBlock
{
    dispatch_async_main_queue_safe(^{
        completeBlock();
    });
}

- (NSMutableArray*)eventsArrWithName:(NSString*)eventName object:(id)object
{
    NSMutableArray* events = nil;
 
    if (eventName) {
        NSMutableDictionary* objectEvtDicts = [self eventsWithObject:object];
        events = [objectEvtDicts objectForKey:eventName];
    
        if (!events) {
            events = [[NSMutableArray alloc] init];
            [objectEvtDicts setObject:events forKey:eventName];
        }
    }
    
    return events;
}

- (NSMutableDictionary*)eventsWithObject:(id)object
{
    NSMutableDictionary* objectEvtDicts = nil;
    NSString* objectKey = [NSString stringWithFormat:@"%p",object];
    
    objectEvtDicts = [_eventsDicts objectForKey:objectKey];
    
    if (!objectEvtDicts) {
        objectEvtDicts = [[NSMutableDictionary alloc] init];
        [_eventsDicts setObject:objectEvtDicts forKey:objectKey];
    }
    
    return objectEvtDicts;
}

#pragma mark - register

- (void)registerEvent:(NSString*)event object:(id)object callback:(EventTriggerBlock)callback
{
    if (object) {
        [self performBlockInMainThread:^{
            NSMutableArray* events = [self eventsArrWithName:event object:object];
            [events addObject:callback];
        }];
    }
}

#pragma mark - unregister

- (void)unRegisterEventWithObject:(id)object
{
    if (object) {
        [self performBlockInMainThread:^{
            NSString* objectKey = [NSString stringWithFormat:@"%p",object];
            [_eventsDicts removeObjectForKey:objectKey];
        }];
    }
}

#pragma mark - dispatch

- (void)dispatchEvent:(NSString*)event userInfo:(id)userInfo
{
    if (event) {
        [self performBlockInMainThread:^{
            
            for (NSString* objEvtKey in _eventsDicts) {
                
                NSDictionary* eventDicts = [_eventsDicts objectForKey:objEvtKey];
                NSArray* events = [eventDicts objectForKey:event];
                
                for (EventTriggerBlock blk in events) {
                    if (blk) {
                        blk(userInfo);
                    }
                }
            }
        }];
    }
}

@end
