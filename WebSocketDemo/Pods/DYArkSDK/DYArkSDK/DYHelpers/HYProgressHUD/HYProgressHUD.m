//
//  HYProgressHUD.m
//  kiwi
//
//  Created by Loong on 16/8/23.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYProgressHUD.h"
#import "KiwiSDKMacro.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation DYProgressHUD

- (instancetype)init {
    if (self = [super init]) {
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        
        [SVProgressHUD setSuccessImage:nil];
        [SVProgressHUD setErrorImage:nil];
        
        [self updateCenterOffset];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCenterOffset)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)updateCenterOffset
{
    CGFloat offsetY = 0;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    //整体向下偏移60%，即centerY向下移动10%
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        offsetY = MAX(screenSize.width, screenSize.height) * 0.1;
    } else {
        offsetY = MIN(screenSize.width, screenSize.height) * 0.1;
    }
    
    //20为一行一半的高度
    offsetY += 20;
    
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, offsetY)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

+ (instancetype)sharedObject
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)showWithMaskType:(HYProgressHUDMaskType)maskType
{
    [self sharedObject]; 
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskType)maskType];
    [SVProgressHUD show];
}

+ (void)showLoadingWithStatus:(NSString *)status
{
    [self sharedObject];
    [SVProgressHUD showWithStatus:status];
}

+ (void)showInfoWithStatus:(NSString *)string
{
    if (!string || string.length <= 0) {
        return;
    }
    
    [self sharedObject];
    
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD showInfoWithStatus:string];

    [SVProgressHUD dismissWithDelay:1.0f];
}

+ (void)showInfoWithStatus:(NSString *)string dismissDuration:(CGFloat)dismissDuration
{
    [self sharedObject];
    
    [SVProgressHUD setInfoImage:nil];
    [SVProgressHUD showInfoWithStatus:string];
    
    [SVProgressHUD dismissWithDelay:dismissDuration];
}

+ (void)showInfoWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType
{
    [self sharedObject];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskType)maskType];
    [SVProgressHUD showInfoWithStatus:string];
}

+ (void)showInfoWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType dismissDuration:(CGFloat)dismissDuration
{
    [self sharedObject];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskType)maskType];
    [SVProgressHUD showInfoWithStatus:string];
    [SVProgressHUD dismissWithDelay:dismissDuration];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [self sharedObject];
    [SVProgressHUD showErrorWithStatus:string];
}

+ (void)showErrorWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType
{
    [self sharedObject];
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskType)maskType];
    [SVProgressHUD showErrorWithStatus:string];
}

+ (void)showSuccessWithStatus:(NSString *)string
{
    [self sharedObject];
    [SVProgressHUD showSuccessWithStatus:string];
}

+ (void)dismiss
{
//    if (![SVProgressHUD isVisible]) {
//        KWSLogInfo(@"SVProgressHUD not visible");
//        return;
//    }
    
    [self sharedObject];
    [SVProgressHUD dismiss];
}

+ (void)show
{
    [self sharedObject];
    [SVProgressHUD show];
}

+ (BOOL)isVisible
{
    [self sharedObject];
    return [SVProgressHUD isVisible];
}

+ (void)setBackgroundColor:(UIColor *)color
{
    [self sharedObject];
    [SVProgressHUD setBackgroundColor:color];
}

+ (void)setForegroundColor:(UIColor *)color
{
    [self sharedObject];
    [SVProgressHUD setForegroundColor:color];
}

+ (void)setSuccessImage:(UIImage *)image
{
    [self sharedObject];
    [SVProgressHUD setSuccessImage:image];
}

+ (void)setErrorImage:(UIImage *)image
{
    [self sharedObject];
    [SVProgressHUD setErrorImage:image];
}

+ (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self sharedObject];
    [SVProgressHUD setCornerRadius:cornerRadius];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
