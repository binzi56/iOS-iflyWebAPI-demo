//
//  UIUtils.m
//  ipadyy
//
//  Created by lslin on 13-1-30.
//  Copyright (c) 2013年 YY.com. All rights reserved.
//

#import "UiUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "KiwiSDKMacro.h"
#import "NSArray+DY.h"

const CGFloat kButtonWidthInItem   = 32.0;
const CGFloat kButtonHeightInItem  = 36.0;

@implementation UIUtils

+ (BOOL)isRetina
{
    return (int)[UIUtils screenScale] == 2;
}

+ (UIScreen *)mainScreen
{
    return [UIScreen mainScreen];
}

+ (CGRect)screenBounds
{
    return [[UIScreen mainScreen] bounds];
}

+ (CGFloat)screenWidth
{
    //return [UIUtils screenBounds].size.width;
    return MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
}

+ (CGFloat)screenHeight
{
    return MAX(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
}

+ (CGFloat)screenScale
{
    return [[UIUtils mainScreen] scale];
}

+ (UIView *)loadViewFromNib:(NSString *)nibName
{
    NSArray *arrView = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    if ([arrView count] > 0) {
        return [arrView safeObjectAtIndex:0];
    }
    return nil;
}

+ (CGFloat)screenWidthScale
{
    static CGFloat scale320 = -1;
    CGFloat width = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    if (scale320 <= 0) {
        scale320 = width / 320.f;
    }
    return scale320;
}

+ (CGFloat)screenWidth375Scale
{
    static CGFloat scale375 = -1;
    CGFloat width = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    if (scale375 <= 0) {
        scale375 = width / 375.f;
    }
    return scale375;
}

+ (BOOL)isScreenWidthOver320
{
    return [self screenWidthScale] > 1.01;
}

+ (void)setAccessibilityIdentifier:(NSString *)identify toView:(UIView *)view
{
    if ([view respondsToSelector:@selector(setAccessibilityIdentifier:)]) {
        view.accessibilityIdentifier = identify;
    }
}

+ (void)setButtonBackgroundImageToDefaultGreen:(UIButton *)btn
{
    [UIUtils setButtonBackgroundImage:btn withImageName:@"button_default_background_green_normal" forState:UIControlStateNormal];
    [UIUtils setButtonBackgroundImage:btn withImageName:@"button_default_background_green_down" forState:UIControlStateHighlighted];
}

+ (void)setButtonBackgroundImageToDefaultGray:(UIButton *)btn
{
    [UIUtils setButtonBackgroundImage:btn withImageName:@"button_default_background_gray" forState:UIControlStateNormal];
}

+ (void)setButtonsBackgroundImageToDefaultGray:(NSArray *)btns
{
    for (UIButton *btn in btns) {
        [UIUtils setButtonBackgroundImage:btn withImageName:@"button_default_background_gray" forState:UIControlStateNormal];
    }
}

+ (void)setButtonBackgroundImage:(UIButton *)btn withImageName:(NSString *)img forState:(UIControlState)state
{
    UIImage *bgImage = [UIImage imageNamed:img];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width / 2
                                           topCapHeight:bgImage.size.height / 2];
    [btn setBackgroundImage:bgImage forState:state];
}

+ (void)moveView:(UIView *)view withDuration:(NSTimeInterval)duration xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset animated:(BOOL)animated callback:(MoveViewCallback)cb
{
    void (^workBlock)(void) = ^{
        CGRect frame = view.frame;
        frame.origin.x += xOffset;
        frame.origin.y += yOffset;
        view.frame = frame;
    };
    
    if (animated) {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                         animations:workBlock
                         completion:^(BOOL finish) {
                             if (finish) {
                                 if (cb) {
                                     cb();
                                 }
                             }
                         }];
    } else {
        workBlock();
    }
}

+ (void)zoomView:(UIView *)view withDuration:(NSTimeInterval)duration width:(CGFloat)w height:(CGFloat)h animated:(BOOL)animated callback:(MoveViewCallback)cb
{
    void (^workBlock)(void) = ^{
        CGRect frame = view.frame;
        frame.size.width += w;
        frame.size.height += h;
        view.frame = frame;
    };
    if (animated) {
        [UIView animateWithDuration:duration animations:workBlock completion:^(BOOL finished) {
            if (finished) {
                if (cb) {
                    cb();
                }
            }
        }];
    }else{
        workBlock();
    }
}

+ (NSArray*)indexPathsFromIndexSet:(NSIndexSet*)idxSet inSection:(int)section
{
    NSMutableArray* indexPaths = [NSMutableArray array];
    NSUInteger currentIndex = [idxSet firstIndex];
    while (currentIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:section];
        [indexPaths addObject:indexPath];
        currentIndex = [idxSet indexGreaterThanIndex:currentIndex];
    }
    return indexPaths;
}

+ (NSArray*)indexPathsFromIndexSet:(NSIndexSet*)idxSet withTotal:(int)totalCount inSection:(int)section
{
    NSMutableArray* indexPaths = [NSMutableArray array];
    NSUInteger currentIndex = [idxSet firstIndex];
    while (currentIndex != NSNotFound) {
        NSUInteger di = MIN(MAX(0, totalCount - currentIndex - 1), totalCount - 1);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:di inSection:section];
        [indexPaths addObject:indexPath];
        currentIndex = [idxSet indexGreaterThanIndex:currentIndex];
    }
    return indexPaths;
}

+ (void)setGradientColorToView:(UIView *)view
{
    //渐变背景：起点：#1b1c28    中点：#29253f   终点：#1e2137
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)Color_RGB(0x1b, 0x1c, 0x28).CGColor,
                       (id)Color_RGB(0x29, 0x25, 0x3f).CGColor,
                       (id)Color_RGB(0x1e, 0x21, 0x37).CGColor,
                       nil];
    
    [view.layer insertSublayer:gradient atIndex:0];
}

+ (void)setGradientColorToView:(UIView *)view
                     fromColor:(NSString *)fromColorHex
                       toColor:(NSString *)toColorHex
{
    [self setGradientColorToView:view fromUIColor:[self colorWithHexString:fromColorHex] toUIColor:[self colorWithHexString:toColorHex]];
}

+ (CAGradientLayer *)setGradientColorToView:(UIView *)view
                                fromUIColor:(UIColor *)fromColor
                                  toUIColor:(UIColor *)toColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(__bridge id)fromColor.CGColor,
                        (__bridge id)toColor.CGColor];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    [view.layer insertSublayer:gradient atIndex:0];
    return gradient;
}

+ (UIBarButtonItem *)negativeSpacer
{
    CGFloat width = -5;
    return [self negativeSpacerWithWidth:width];
}

+ (UIBarButtonItem *)negativeSpacerWithWidth:(CGFloat)width
{
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth:width];
    return spacer;
}

+ (void)setView:(UIView *)view withCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color
{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
    
    if (width > 0) {
        view.layer.borderColor = color.CGColor;
        view.layer.borderWidth = width;
    }
}

+ (void)setView:(UIView *)view withShadowRadius:(CGFloat)radius shadowOffset:(CGSize)offset shadowColor:(UIColor *)color
{
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = radius;
    view.layer.masksToBounds = NO;
}

+ (UIButton*)createRightButton:(NSString *)imgName
{
    return [self createRightButton:imgName forXOffset:0.0];
}

+ (UIButton*)createRightButton:(NSString *)imgName forXOffset:(CGFloat)xOffset
{
    UIImage *icon = [UIImage imageNamed:imgName];
    UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(xOffset, 0.0, kButtonWidthInItem, kButtonHeightInItem);
    [doneBtn setImage:icon forState:UIControlStateNormal];
    doneBtn.exclusiveTouch = YES;
    return doneBtn;
}

+ (void)centerButtonImageAndTitle:(UIButton *)btn
{
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = btn.titleLabel.frame.size;
    
    CGFloat totalHeight = btn.frame.size.height;
    
    btn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                           0.0f,
                                           0.0f,
                                           - titleSize.width);
    
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                           - imageSize.width,
                                           - (totalHeight - titleSize.height - 2),
                                           0.0f);
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    
    return [self colorWithHexString:stringToConvert alpha:1.f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha
{
    if (stringToConvert.length == 0 || stringToConvert.length > 7) {
        return nil;
    }
    NSString *string = stringToConvert;
    if ([string hasPrefix:@"#"]) {
        string = [string substringFromIndex:1];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned hexNum;
    if (![scanner scanHexInt: &hexNum]) {
        return nil;
    }
    
    int r = (hexNum >> 16) & 0xFF;
    int g = (hexNum >> 8) & 0xFF;
    int b = (hexNum) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (CGFloat)valueWithScreenWidth6p:(CGFloat)value
{
    if (IS_IPHONE_HEIGHT_OVER_736) {
        return ceil(1.15 * value);
    } else {
        return value;
    }
}

+ (CGFloat)valueWithScreenWidthScale:(CGFloat)value
{
    static CGFloat scale = -1.0;

    if (scale < 0) {
        
        if(IS_IPHONE_HEIGHT_667) {
            scale = 1.17;
        } else if (IS_IPHONE_HEIGHT_OVER_736) {
            scale = 1.28;
        } else if (!IS_IPAD){
            scale = [UIUtils screenWidthScale];
        } else {
            scale = 1.0;
        }
    }
    
    return ceil(value * scale);
}

+ (CGFloat)fontSizeWithScreenWidth6p:(CGFloat)fontSize {
    if (IS_IPHONE_HEIGHT_OVER_736) {
        return fontSize + 1;
    } else {
        return fontSize;
    }
}

+ (CGFloat)increaseFontSizeWithBase:(CGFloat)fontSize
{
    if (IS_IPHONE_HEIGHT_667) {
        return fontSize + 1;
    }else if (IS_IPHONE_HEIGHT_OVER_736) {
        return fontSize + 2;
    }else {
        return fontSize;
    }
}

+ (BOOL)isOverIPhoneXHeight
{
   double x = MAX(kScreenWidth, kScreenHeight);
    if (x >= 812) {
        return YES;
    }
    return NO;
}

@end
