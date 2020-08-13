//
//  UIViewController+SafeArea.m
//  XHX
//
//  Created by 郑思越 on 2019/2/13.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "UIViewController+SafeArea.h"
#import "UIDevice+KWS.h"

static BOOL dyTabBarSafeAreaInsetsDidSetup = NO;

@implementation UIViewController (SafeArea)

- (UIEdgeInsets)dy_safeEdgeInsets
{
    return [self dy_safeEdgeInsetsCountStatesBar:YES];
}

- (UIEdgeInsets)dy_safeEdgeInsetsCountStatesBar:(BOOL)countStatesBar
{
    CGFloat topSpace    = 0;
    CGFloat bottomSpace = 0;
    
    [self p_topSpace:&topSpace bottomSpace:&bottomSpace needStatesBar:countStatesBar];
    if (self.p_isNotch && self.p_isLandscape) {
        return UIEdgeInsetsMake(topSpace, kDYSafeArea4NotchLeftLandscape, bottomSpace, kDYSafeArea4NotchRightLandscape);
    }
    else {
        return UIEdgeInsetsMake(topSpace, 0, bottomSpace, 0);
    }
}

- (CGRect)dy_safeFrame
{
    return [self dy_safeFrameCountStatesBar:YES];
}

- (CGRect)dy_safeFrameCountStatesBar:(BOOL)countStatesBar
{
    CGSize screenSize   = [[UIScreen mainScreen] bounds].size;
    CGFloat topSpace    = 0;
    CGFloat bottomSpace = 0;
    [self p_topSpace:&topSpace bottomSpace:&bottomSpace needStatesBar:countStatesBar];
    if (self.p_isNotch && self.p_isLandscape) {
        return CGRectMake(kDYSafeArea4NotchLeftLandscape, topSpace,
                          screenSize.width - kDYSafeArea4NotchLeftLandscape - kDYSafeArea4NotchRightLandscape,
                          screenSize.height - topSpace - bottomSpace);
    }
    else {
        return CGRectMake(0, topSpace, screenSize.width, screenSize.height - topSpace - bottomSpace);
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    if (dyTabBarSafeAreaInsetsDidSetup ||![self isKindOfClass:[UITabBarController class]]) {
        return;
    }
    dyTabBarSafeAreaInsetsDidSetup = YES;
}

/**
 根据statusBar,navigationBar,bottomTabBar的状态,获取上下边距
 
 @param topSpace 上边距
 @param bottomSpace 下边距
 @param needStatesBar navigationBar隐藏时是否需要计入statesBar的高度
 */
- (void)p_topSpace:(CGFloat *)topSpace bottomSpace:(CGFloat *)bottomSpace needStatesBar:(BOOL)needStatesBar
{
    CGFloat statesBarSpace = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarSpace    = self.navigationController.navigationBar.frame.size.height;
    // NOTE:navigationBar显示且为透明时才需要navigationBar的边距
    BOOL isNeedNavSpace = !self.navigationController.isNavigationBarHidden && self.navigationController.navigationBar.isTranslucent;
    *topSpace   = isNeedNavSpace ? (navBarSpace + statesBarSpace) : (needStatesBar ? statesBarSpace : 0);
    
    CGFloat tabBarSpace    = self.tabBarController.tabBar.frame.size.height;
    // NOTE:使用hidesBottomBarWhenPushed时isHidden判断不准确，所以这里or一下
    BOOL isTabHidden = self.tabBarController.tabBar.isHidden || self.hidesBottomBarWhenPushed;
    // NOTE:bottomTabBar显示且为透明时才需要bottomTabBar的边距
    BOOL isNeedTabSpace = !isTabHidden && self.tabBarController.tabBar.isTranslucent;
    tabBarSpace = isNeedTabSpace ? tabBarSpace : 0;
    // NOTE:没有tabBar或safeArea未知的情况下，为刘海屏加入特定的bottomSpace
    if ((!tabBarSpace || isTabHidden || !dyTabBarSafeAreaInsetsDidSetup) && self.p_isNotch) {
        tabBarSpace += self.p_isLandscape ? kDYSafeArea4NotchBottomLandscape : kDYSafeArea4NotchBottomPortrait;
    }
    *bottomSpace = tabBarSpace;
}


/**
 获取设备屏幕朝向
 */
- (BOOL)p_isLandscape
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationUnknown) {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    return UIDeviceOrientationIsLandscape(orientation);
}

/**
 获取是否刘海屏
 */
- (BOOL)p_isNotch
{
    return [[UIDevice currentDevice]dy_isNotch];
}

DYSAFEAREAIMPL

@end
