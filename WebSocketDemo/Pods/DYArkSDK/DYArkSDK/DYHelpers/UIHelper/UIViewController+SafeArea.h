//
//  UIViewController+SafeArea.h
//  XHX
//
//  Created by 郑思越 on 2019/2/13.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYSafeAreaMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SafeArea)

- (UIEdgeInsets)dy_safeEdgeInsets;

- (UIEdgeInsets)dy_safeEdgeInsetsCountStatesBar:(BOOL)countStatesBar;

- (CGRect)dy_safeFrame;

- (CGRect)dy_safeFrameCountStatesBar:(BOOL)countStatesBar;

DYSAFEAREAAPI

@end

NS_ASSUME_NONNULL_END
