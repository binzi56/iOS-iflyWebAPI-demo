//
//  HYProgressHUD.h
//  kiwi
//
//  Created by Loong on 16/8/23.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HYProgressHUDMaskType) {
    HYProgressHUDMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    HYProgressHUDMaskTypeClear,     // don't allow user interactions
    HYProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD
    HYProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient
};

@interface DYProgressHUD : NSObject

+ (void)showWithMaskType:(HYProgressHUDMaskType)maskType;

+ (void)showLoadingWithStatus:(NSString *)status;

+ (void)showInfoWithStatus:(NSString *)string;
+ (void)showInfoWithStatus:(NSString *)string dismissDuration:(CGFloat)dismissDuration;
+ (void)showInfoWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType;
+ (void)showInfoWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType dismissDuration:(CGFloat)dismissDuration;

+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string maskType:(HYProgressHUDMaskType)maskType;

+ (void)showSuccessWithStatus:(NSString *)string;

+ (void)dismiss;
+ (void)show;

+ (BOOL)isVisible;

+ (void)setBackgroundColor:(UIColor *)color;     // default is [UIColor colorWithWhite:0.0 alpha:0.8]
+ (void)setForegroundColor:(UIColor *)color;     // default is [UIColor whiteColor]

+ (void)setSuccessImage:(UIImage *)image;        // default is nil
+ (void)setErrorImage:(UIImage *)image;          // default is nil

+ (void)setCornerRadius:(CGFloat)cornerRadius;

@end
