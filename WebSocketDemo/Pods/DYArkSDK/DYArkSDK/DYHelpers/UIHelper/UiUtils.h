//
//  UIUtils.h
//  ipadyy
//
//  Created by lslin on 13-1-30.
//  Copyright (c) 2013年 YY.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "DYSafeAreaMacros.h"
#import "MASConstraint+DY.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define UIUTILS_iPhoneX (((int)((kScreenHeight/kScreenWidth)*100) == 216) ? YES : NO)
// 判断是否是iPhone X
//#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//是否是开启热点的状态
#define UIUTILS_STATUS_BAR_BIGGER_THAN_20 [UIApplication sharedApplication].statusBarFrame.size.height > 20
// 状态栏高度
#define UIUTILS_STATUS_BAR_HEIGHT (UIUTILS_iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define UIUTILS_NAVIGATION_BAR_HEIGHT (UIUTILS_iPhoneX ? 88.f : 64.f)
// tabBar高度
#define UIUTILS_TAB_BAR_HEIGHT (UIUTILS_iPhoneX ? (49.f+34.f) : 49.f)
// home indicator
#define UIUTILS_HOME_INDICATOR_HEIGHT (UIUTILS_iPhoneX ? 34.f : 0.f)

#define kColorHighlight        Color_RGB(255, 102, 0)    //橙色高亮(#FF6600)
#define kColorNormal           Color_RGB(255, 108, 1)   //橙色常态（#ff6c01）
#define Color_RGB(r, g, b)     [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1]
#define Color_RGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

#define DEF_CGFLOAT_CONST(name) static CGFloat name;
#define DEF_UI_CONST_6P(name, value) name = [UIUtils valueWithScreenWidth6p:value];
#define DEF_UI_CONST_SCALE(name, value) name = [UIUtils valueWithScreenWidthScale:value];

#define SCALE_375(name) name  = floorf([UIUtils screenWidth375Scale] * (name));
#define SCALE_375_VALUE(value) floorf([UIUtils screenWidth375Scale] * (value))
#define SCALE_375_NAME_VALUE(name,value) name  = floorf([UIUtils screenWidth375Scale] * (value) * (name));

#define DEF_FONT_SIZE_6P(name, fontSize) name = [UIUtils fontSizeWithScreenWidth6p:fontSize];
#define DEF_FONT_SIZE_SCALE(name, fontSize) name = [UIUtils valueWithScreenWidthScale:fontSize];
#define FONT_SIZE_6P(fontSize) [UIUtils fontSizeWithScreenWidth6p:fontSize]

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_HEIGHT_LESS_568 (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_HEIGHT_568 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_HEIGHT_667 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_HEIGHT_OVER_736 (IS_IPHONE && SCREEN_MAX_LENGTH >= 736.0)
#define IS_IPHONE_HEIGHT_812 (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define IPHONE_X_BOTTOM_ADJUST_SIZE     20.0
#define IPHONE_X_ADJUST_SIZE            44.0

#define LimitValueAtRange(min, value, max)                      ( value < min ? min : (max < value ? max : value) )

/**************** UIView + CGRect ****************/

#define CGRectAdjust(r, x1, y1, w1, h1)         CGRectMake(r.origin.x + x1, r.origin.y + y1,  r.size.width + w1, r.size.height + h1)
#define CGRectSetSize(r, w1, h1)                CGRectMake(r.origin.x, r.origin.y, w1, h1)
#define CGRectSetOrigin(r, x1, y1)              CGRectMake(x1, y1, r.size.width, r.size.height)
#define CGRectScale(r, scale)                   CGRectMake(r.origin.x, r.origin.y, r.size.width * scale, r.size.height * scale)

#define ViewAdjustFrame(view, x1, y1, w1, h1)   view.frame = CGRectAdjust(view.frame, x1, y1, w1, h1)
#define ViewSetSize(view, w1, h1)               view.frame = CGRectSetSize(view.frame, w1, h1)
#define ViewSetOrigin(view, x1, y1)             view.frame = CGRectSetOrigin(view.frame, x1, y1)
#define ViewScaleFrame(view, scale)             view.frame = CGRectScale(view.frame, scale)

#define LabelScaleFont(label, scale)            label.font = [label.font fontWithSize:label.font.pointSize * scale];
#define ButtonScaleFont(button, scale)          LabelScaleFont((button.titleLabel), scale)
#define TextFieldScaleFont(textField, scale)    textField.font = [textField.font fontWithSize:textField.font.pointSize * scale];

#define LabelFont6P(label)            label.font = [label.font fontWithSize:FONT_SIZE_6P(label.font.pointSize)]
#define ButtonFont6P(button)          LabelFont6P((button.titleLabel))
#define TextFieldFont6P(textField)    textField.font = [textField.font fontWithSize:FONT_SIZE_6P(textField.font.pointSize)]

typedef void (^MoveViewCallback)(void);

extern const CGFloat kButtonWidthInItem;
extern const CGFloat kButtonHeightInItem;

@interface UIUtils : NSObject

+ (BOOL)isRetina;
+ (UIScreen *)mainScreen;
+ (CGRect)screenBounds;
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;
+ (CGFloat)screenScale;
+ (UIView *)loadViewFromNib:(NSString *)nibName;

/**
 * 屏幕宽度比例，CGRectGetWidth([UIScreen mainScreen].bounds) / 320.0;
 */
+ (CGFloat)screenWidthScale;
/**
 屏幕宽度比例，CGRectGetWidth([UIScreen mainScreen].bounds) / 375.0;
 */
+ (CGFloat)screenWidth375Scale;

/**
 *  @brief 判断屏幕宽度是否大于320
 */
+ (BOOL)isScreenWidthOver320;

+ (void)setAccessibilityIdentifier:(NSString *)identify toView:(UIView *)view;
+ (void)setButtonBackgroundImageToDefaultGreen:(UIButton *)btn;
+ (void)setButtonBackgroundImageToDefaultGray:(UIButton *)btn;
+ (void)setButtonsBackgroundImageToDefaultGray:(NSArray *)btns;

+ (void)moveView:(UIView *)view withDuration:(NSTimeInterval)duration xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset animated:(BOOL)animated callback:(MoveViewCallback)cb;
+ (void)zoomView:(UIView *)view withDuration:(NSTimeInterval)duration width:(CGFloat)w height:(CGFloat)h animated:(BOOL)animated callback:(MoveViewCallback)cb;

+ (NSArray*)indexPathsFromIndexSet:(NSIndexSet*)idxSet inSection:(int)section;
+ (NSArray*)indexPathsFromIndexSet:(NSIndexSet*)idxSet withTotal:(int)totalCount inSection:(int)section;

+ (void)setGradientColorToView:(UIView *)view;
+ (void)setGradientColorToView:(UIView *)view
                     fromColor:(NSString *)fromColorHex
                       toColor:(NSString *)toColorHex;
+ (CAGradientLayer *)setGradientColorToView:(UIView *)view
                                fromUIColor:(UIColor *)fromColor
                                  toUIColor:(UIColor *)toColor;

+ (UIBarButtonItem *)negativeSpacer;
+ (UIBarButtonItem *)negativeSpacerWithWidth:(CGFloat)width;

+ (void)setView:(UIView *)view withCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color;
+ (void)setView:(UIView *)view withShadowRadius:(CGFloat)radius shadowOffset:(CGSize)offset shadowColor:(UIColor *)color;

//UIBarButtonItem
+ (UIButton*)createRightButton:(NSString *)imgName;
+ (UIButton*)createRightButton:(NSString *)imgName forXOffset:(CGFloat)xOffset;

+ (void)centerButtonImageAndTitle:(UIButton *)btn;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

+ (CGFloat)valueWithScreenWidth6p:(CGFloat)value;
+ (CGFloat)valueWithScreenWidthScale:(CGFloat)value;

+ (CGFloat)fontSizeWithScreenWidth6p:(CGFloat)fontSize;

+ (CGFloat)increaseFontSizeWithBase:(CGFloat)fontSize;

+ (BOOL)isOverIPhoneXHeight;

@end
