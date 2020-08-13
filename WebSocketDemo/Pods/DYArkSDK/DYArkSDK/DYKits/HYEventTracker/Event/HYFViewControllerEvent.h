////  HYFViewControllerEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"
typedef NS_ENUM(NSInteger, ETViewControllerEventType) {
    ETViewControllerEventTypeViewDidLoad = 1,
    ETViewControllerEventTypeViewLoadView,
    ETViewControllerEventTypeViewWillAppear,
    ETViewControllerEventTypeViewDidAppear,
    ETViewControllerEventTypeViewWillDisappear,
    ETViewControllerEventTypeViewDidDisappear,
    ETViewControllerEventTypePresentViewController,
    ETViewControllerEventTypeDismissViewController,
    ETViewControllerEventTypeSetTitle,
};

@interface HYFViewControllerEvent : HYFEventBase

- (instancetype)initWithViewController:(UIViewController*)viewController
                                   ext:(id)ext
                                  type:(ETViewControllerEventType)type;

@end
