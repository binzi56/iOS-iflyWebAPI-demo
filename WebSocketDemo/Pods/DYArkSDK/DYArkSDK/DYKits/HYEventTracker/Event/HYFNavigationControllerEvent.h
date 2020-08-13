////  HYFNavigationControllerEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

typedef NS_ENUM(NSInteger, ETNavigationControllerEventType) {
    ETNavigationControllerEventTypePushViewController = 1,
    ETNavigationControllerEventTypePopViewController,
    ETNavigationControllerEventTypePopToViewController,
    ETNavigationControllerEventTypePopToRootViewController,
    ETNavigationControllerEventTypeSetViewControllers,
};

@interface HYFNavigationControllerEvent : HYFEventBase

- (instancetype)initWithNavigationController:(UINavigationController*)navigationController
                             viewControllers:(NSArray*)viewControllers
                                        type:(ETNavigationControllerEventType)type;

@end
