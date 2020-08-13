////  UINavigationController+HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UINavigationController+HYFEventTracker.h"

#import "HYFEventTrackerCenter.h"
#import "HYFNavigationControllerEvent.h"
#import "NSObject+HYFEventTracker.h"

@implementation UINavigationController (HYFEventTracker)

- (void)ET_traceEventWithNavigationController:(UINavigationController*)navigationController
                        viewControllers:(NSArray*)viewControllers
                                      type:(ETNavigationControllerEventType)type {
    HYFNavigationControllerEvent *event = [[HYFNavigationControllerEvent alloc]initWithNavigationController:navigationController viewControllers:viewControllers type:type];
    [[HYFEventTrackerCenter sharedInstance] addEvent:event];
}

- (void)ET_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController) {
        [self ET_traceEventWithNavigationController:self
                                    viewControllers:@[viewController]
                                               type:ETNavigationControllerEventTypePushViewController];
    }
    return [self ET_pushViewController:viewController animated:animated];
}

- (UIViewController*)ET_popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [self ET_popViewControllerAnimated:animated];
    if (vc) {
        [self ET_traceEventWithNavigationController:self
                                    viewControllers:@[vc]
                                               type:ETNavigationControllerEventTypePopViewController];
    }
    return vc;
}

- (NSArray<__kindof UIViewController *> *)ET_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray<__kindof UIViewController *> * vcs = [self ET_popToViewController:viewController animated:animated];
    [self ET_traceEventWithNavigationController:self
                                viewControllers:vcs
                                           type:ETNavigationControllerEventTypePopToViewController];

    return vcs;
}

- (NSArray<__kindof UIViewController *> *)ET_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<__kindof UIViewController *> * vcs = [self ET_popToRootViewControllerAnimated:animated];
    [self ET_traceEventWithNavigationController:self
                                viewControllers:vcs
                                           type:ETNavigationControllerEventTypePopToRootViewController];

    return vcs;
}

- (void)ET_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    [self ET_setViewControllers:viewControllers animated:animated];
    [self ET_traceEventWithNavigationController:self
                             viewControllers:viewControllers
                                        type:ETNavigationControllerEventTypeSetViewControllers];
}

+ (void)ET_swizzle {
    [UINavigationController ET_swizzleMethod:@selector(pushViewController:animated:)
                                      newSel:@selector(ET_pushViewController:animated:)];
    
    [UINavigationController ET_swizzleMethod:@selector(popViewControllerAnimated:)
                                      newSel:@selector(ET_popViewControllerAnimated:)];
    
    [UINavigationController ET_swizzleMethod:@selector(popToViewController:animated:)
                                      newSel:@selector(ET_popToViewController:animated:)];
    
    [UINavigationController ET_swizzleMethod:@selector(popToRootViewControllerAnimated:)
                                      newSel:@selector(ET_popToRootViewControllerAnimated:)];
    
    [UINavigationController ET_swizzleMethod:@selector(setViewControllers:animated:)
                                      newSel:@selector(ET_setViewControllers:animated:)];
}

@end
