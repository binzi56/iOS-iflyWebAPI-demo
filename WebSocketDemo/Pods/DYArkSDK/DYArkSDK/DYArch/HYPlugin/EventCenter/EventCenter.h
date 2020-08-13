//
//  EventCenter.h
//  kiwi
//
//  Created by pengfeihuang on 16/6/21.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EventTriggerBlock)(NSDictionary* userInfo);

//线程安全，内部保证都在主线程操作
@interface EventCenter : NSObject

- (void)registerEvent:(NSString*)event object:(id)object callback:(EventTriggerBlock)callback;

- (void)unRegisterEventWithObject:(id)object;

- (void)dispatchEvent:(NSString*)event userInfo:(NSDictionary*)userInfo;

@end
