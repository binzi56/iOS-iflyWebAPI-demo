////  UIControl+HYEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/10.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UIControl+HYEventTracker.h"

#import "NSObject+HYFEventTracker.h"
#import "HYFControlEvent.h"
#import "HYFEventTrackerCenter.h"

@implementation UIControl (HYEventTracker)

- (void)ET_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    //过滤掉系统方法
    if (target && action && ![NSStringFromSelector(action) hasPrefix:@"_"]) {
        HYFControlEvent *event = [[HYFControlEvent alloc] initWithSEL:action target:target type:ETControlEventTypeSendAction];
        [[HYFEventTrackerCenter sharedInstance] addEvent:event];
    }
    
    [self ET_sendAction:action to:target forEvent:event];
}

+ (void)ET_swizzle {
    [UIControl ET_swizzleMethod:@selector(sendAction:to:forEvent:)
                         newSel:@selector(ET_sendAction:to:forEvent:)];
}

@end
