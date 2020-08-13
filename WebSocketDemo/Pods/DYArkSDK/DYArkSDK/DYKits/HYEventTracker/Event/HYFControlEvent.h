////  HYFControlEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

typedef NS_ENUM(NSInteger, ETControllerEventType) {
    ETControlEventTypeSendAction = 1,
};

@interface HYFControlEvent : HYFEventBase

- (instancetype)initWithSEL:(SEL)sel target:(id)target type:(ETControllerEventType)type;

@end
