//
//  DYCustomButton.h
//  huhuAudio
//
//  Created by EasyinWan on 2019/8/2.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYCustomButton : UIView

@property (nonatomic, readonly, strong) UIButton *button;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL highlighted;

- (void)resetButtonWithGradientStartColor:(UIColor *)startColor
                                 endColor:(UIColor *)endColor
                              cornerRadio:(CGFloat)cornerRadius
                               titleColor:(UIColor *)titleColor;

- (void)setupBorderColor:(UIColor *)borderColor;

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
- (void)setTitleFont:(nullable UIFont *)font;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)setButtonWithGradientStartColor:(UIColor *)startColor
                               endColor:(UIColor *)endColor
                            cornerRadio:(CGFloat)cornerRadius
                             titleColor:(UIColor *)titleColor
                      isNeedGradientSet:(BOOL)isNeedGradientSet
                        backgroundColor:(UIColor *)backgroundColor
                               forState:(UIControlState)state;

@end

@interface DYCustomButton (BlocksKit)

- (void)bk_addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

- (void)bk_removeEventHandlersForControlEvents:(UIControlEvents)controlEvents;

- (BOOL)bk_hasEventHandlersForControlEvents:(UIControlEvents)controlEvents;

@end
