
//
//  DYSafeAreaMacros.h
//  XHX
//
//  Created by 郑思越 on 2019/2/13.
//  Copyright © 2019 XYWL. All rights reserved.
//

#ifndef DYSafeAreaMacros_h
#define DYSafeAreaMacros_h

static const CGFloat kDYSafeArea4NotchBottomPortrait  = 34;
static const CGFloat kDYSafeArea4NotchBottomLandscape = 21;
static const CGFloat kDYSafeArea4NotchLeftLandscape   = 44;
static const CGFloat kDYSafeArea4NotchRightLandscape  = 44;

#define DYSAFEAREAAPI                              \
-(CGFloat) dy_safeEdgeInsetsTop;               \
-(CGFloat) dy_safeEdgeInsetsTopCountStatesBar; \
-(CGFloat) dy_safeEdgeInsetsLeft;              \
-(CGFloat) dy_safeEdgeInsetsBottom;            \
-(CGFloat) dy_safeEdgeInsetsRight;

#define DYSAFEAREAIMPL                                         \
-(CGFloat) dy_safeEdgeInsetsTop                            \
{                                                          \
return [self dy_safeEdgeInsets].top;                   \
}                                                          \
-(CGFloat) dy_safeEdgeInsetsLeft                           \
{                                                          \
return [self dy_safeEdgeInsets].left;                  \
}                                                          \
-(CGFloat) dy_safeEdgeInsetsBottom                         \
{                                                          \
return [self dy_safeEdgeInsets].bottom;                \
}                                                          \
-(CGFloat) dy_safeEdgeInsetsRight                          \
{                                                          \
return [self dy_safeEdgeInsets].right;                 \
}

#import "UIViewController+SafeArea.h"
#import "UIView+SafeArea.h"

#endif /* DYSafeAreaMacros_h */
