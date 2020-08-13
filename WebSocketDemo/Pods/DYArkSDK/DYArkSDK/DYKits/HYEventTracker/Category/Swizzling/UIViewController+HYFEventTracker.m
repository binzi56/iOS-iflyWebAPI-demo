////  UIViewController+HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UIViewController+HYFEventTracker.h"

#import "HYFEventTrackerCenter.h"
#import "NSObject+HYFEventTracker.h"

@implementation UIViewController (HYFEventTracker)

- (void)ET_traceEventWithTracedObj:(UIViewController*)tracedObj ext:(id)ext type:(ETViewControllerEventType)type {
    HYFViewControllerEvent *event = [[HYFViewControllerEvent alloc] initWithViewController:tracedObj ext:ext type:type];
    [[HYFEventTrackerCenter sharedInstance] addEvent:event];
}

- (void)ET_viewDidLoad {
    [self ET_traceEventWithTracedObj:self ext:nil type:ETViewControllerEventTypeViewDidLoad];
    [self ET_viewDidLoad];
}

- (void)ET_viewWillAppear:(BOOL)animated {
    [self ET_traceEventWithTracedObj:self ext:nil type:ETViewControllerEventTypeViewWillAppear];
    [self ET_viewWillAppear:animated];
}

- (void)ET_viewDidAppear:(BOOL)animated {
    [self ET_traceEventWithTracedObj:self ext:nil type:ETViewControllerEventTypeViewDidAppear];
    [self ET_viewDidAppear:animated];
}

- (void)ET_viewWillDisappear:(BOOL)animated {
    [self ET_traceEventWithTracedObj:self ext:nil type:ETViewControllerEventTypeViewWillDisappear];
    [self ET_viewWillDisappear:animated];
}

- (void)ET_viewDidDisappear:(BOOL)animated {
    [self ET_traceEventWithTracedObj:self ext:nil type:ETViewControllerEventTypeViewDidDisappear];
    [self ET_viewDidDisappear:animated];
}

- (void)ET_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self ET_traceEventWithTracedObj:viewControllerToPresent ext:nil type:ETViewControllerEventTypePresentViewController];
    [self ET_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)ET_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController *dismissedViewController = self;
    if (self.presentedViewController) {
        dismissedViewController = self.presentedViewController;
    }
    [self ET_traceEventWithTracedObj:dismissedViewController ext:nil type:ETViewControllerEventTypeDismissViewController];
    [self ET_dismissViewControllerAnimated:flag completion:completion];
}

- (void)ET_setTitle:(NSString *)title {
    [self ET_traceEventWithTracedObj:self ext:title type:ETViewControllerEventTypeSetTitle];
    [self ET_setTitle:title];
}

+ (void)ET_swizzle {
    [UIViewController ET_swizzleMethod:@selector(viewDidLoad)
                                newSel:@selector(ET_viewDidLoad)];
    
    [UIViewController ET_swizzleMethod:@selector(viewWillAppear:)
                                newSel:@selector(ET_viewWillAppear:)];
    
    [UIViewController ET_swizzleMethod:@selector(viewDidAppear:)
                                newSel:@selector(ET_viewDidAppear:)];
    
    [UIViewController ET_swizzleMethod:@selector(viewWillDisappear:)
                                newSel:@selector(ET_viewWillDisappear:)];
    
    [UIViewController ET_swizzleMethod:@selector(viewDidDisappear:)
                                newSel:@selector(ET_viewDidDisappear:)];
    
    [UIViewController ET_swizzleMethod:@selector(presentViewController:animated:completion:)
                                newSel:@selector(ET_presentViewController:animated:completion:)];
    
    [UIViewController ET_swizzleMethod:@selector(dismissViewControllerAnimated:completion:)
                                newSel:@selector(ET_dismissViewControllerAnimated:completion:)];
    
    [UIViewController ET_swizzleMethod:@selector(setTitle:)
                                newSel:@selector(ET_setTitle:)];
}

@end
