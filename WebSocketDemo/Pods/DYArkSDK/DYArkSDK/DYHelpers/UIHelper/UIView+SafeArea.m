//
//  UIView+SafeArea.m
//  XHX
//
//  Created by 郑思越 on 2019/2/13.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "UIView+SafeArea.h"
#import "UIViewController+SafeArea.h"

@implementation UIView (SafeArea)

- (UIEdgeInsets)dy_safeEdgeInsets
{
    return [self dy_safeEdgeInsetsCountStatesBar:YES];
}

- (UIEdgeInsets)dy_safeEdgeInsetsCountStatesBar:(BOOL)countStatesBar
{
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return [((UIViewController *)self.nextResponder) dy_safeEdgeInsetsCountStatesBar:countStatesBar];
    }
    else {
        return [[UIApplication sharedApplication].delegate.window.rootViewController dy_safeEdgeInsetsCountStatesBar:countStatesBar];
    }
}

- (CGRect)dy_safeFrame
{
    return [self dy_safeFrameCountStatesBar:YES];
}

- (CGRect)dy_safeFrameCountStatesBar:(BOOL)countStatesBar
{
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return [((UIViewController *)self.nextResponder) dy_safeFrameCountStatesBar:countStatesBar];
    }
    else {
        return [[UIApplication sharedApplication].delegate.window.rootViewController dy_safeFrameCountStatesBar:countStatesBar];
    }
}

DYSAFEAREAIMPL

@end
