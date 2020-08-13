//
//  UIView+BottomLine.h
//  kiwi
//
//  Created by hpf1908 on 14/10/31.
//  Copyright (c) 2014年 com.mewe.party. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WFBottomLine)

- (void)drawBottomLineInRect:(CGRect)rect;

@end

@interface UIView (WFLoadNib)

+ (id)viewWithNibName:(NSString *)name;
+ (UINib *)nib;
+ (instancetype)viewFromNib;

@end


@interface UIView (WFLiveRound)

@property (nonatomic, assign) IBInspectable CGFloat wf_cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat wf_borderWidth;
@property (nonatomic, assign) IBInspectable UIColor* wf_borderColor;


- (void)setRoundCorner;

- (void)setRoundCornerWithBorderWidth:(CGFloat)width borderColor:(UIColor *)color;

- (void)setCornerRadius:(CGFloat)radius;

- (void)setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color;

@end

@interface UIView (WFLineLayer)
- (void)wf_addLineLayerWithX:(CGFloat)x
                           Y:(CGFloat)y
                       Width:(CGFloat)width
                      Height:(CGFloat)height
                       Color:(UIColor *)color;

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor
                         layerName:(NSString *)layerName
                        isPortrait:(BOOL)isPortrait;

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor
                         layerName:(NSString *)layerName
                        isPortrait:(BOOL)isPortrait
                  formerProportion:(CGFloat)formerProportion;

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                                     startColor:(UIColor *)startColor
                                       endColor:(UIColor *)endColor
                                      layerName:(NSString *)layerName
                                     startPoint:(CGPoint)startPoint
                                       endPoint:(CGPoint)endPoint;

- (void)removeLayerWithView:(UIView *)view
                  layerName:(NSString *)layerName;

@end

#pragma mark - DYPopMask

/// NOTE:动画偏好值
@interface DYPopMaskPreference : NSObject

@property (nonatomic, assign) NSTimeInterval animateDuration;
@property (nonatomic, assign) CGFloat initialAlpha;
@property (nonatomic, assign) CGRect initialFrame;

@end

@interface UIView (DYPopMask)

@property (nonatomic, strong) DYPopMaskPreference * dy_popMaskPreference;
@property (nonatomic, strong) UIView * dy_popMaskView;
@property (nonatomic, copy) void (^dy_popMaskDismissBlock)(void);

- (void)dy_popMask;
- (void)dy_popMaskAtSuperView:(UIView *)superView;
- (void)dy_popMaskDismiss;

@end
