//
//  UIView+BottomLine.m
//  kiwi
//
//  Created by hpf1908 on 14/10/31.
//  Copyright (c) 2014年 com.mewe.party. All rights reserved.
//

#import "UIView+DY.h"
#import "NSObject+YYAdd.h"
#import "UIGestureRecognizer+BlocksKit.h"


@implementation UIView (WFBottomLine)

- (void)drawBottomLineInRect:(CGRect)rect
{
    //画底部分割线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.800 alpha:1.000].CGColor);
    
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, rect.origin.x, h);
    CGContextAddLineToPoint(context, w, h);
    CGContextStrokePath(context);
}

@end


@implementation UIView (WFLoadNib)

+ (id)viewWithNibName:(NSString *)name
{
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil] lastObject];
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
}


+ (instancetype)viewFromNib
{
    return [UIView viewWithNibName:NSStringFromClass([self class])];
}

@end

@implementation UIView (WFLiveRound)

- (void)setRoundCorner {
    [self setRoundCornerWithBorderWidth:0 borderColor:nil];
}

- (void)setRoundCornerWithBorderWidth:(CGFloat)width borderColor:(UIColor *)color {
    [self setCornerRadius:(self.frame.size.height / 2.0) borderWidth:width borderColor:color];
}

- (void)setCornerRadius:(CGFloat)radius {
    [self setCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (void)setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    
    if (width > 0 && color) {
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = width;
    }
}

-(CGFloat)wf_cornerRadius{
    return self.layer.cornerRadius;
}
-(void)setWf_cornerRadius:(CGFloat)wf_cornerRadius{
    self.layer.cornerRadius = wf_cornerRadius;
}

-(CGFloat)wf_borderWidth{
    return self.layer.borderWidth;
}




-(void)setWf_borderWidth:(CGFloat)wf_borderWidth{
    self.layer.borderWidth = wf_borderWidth;
}

-(UIColor*)wf_borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

-(void)setWf_borderColor:(UIColor* )wf_borderColor{
    self.layer.borderColor = wf_borderColor.CGColor;
}

@end

@implementation UIView (WFLineLayer)
- (void)wf_addLineLayerWithX:(CGFloat)x
                           Y:(CGFloat)y
                       Width:(CGFloat)width
                      Height:(CGFloat)height
                       Color:(UIColor *)color{
    CALayer * lineLayer = [CALayer layer];
    lineLayer.position = CGPointMake(x, y);
    lineLayer.anchorPoint = CGPointZero;
    lineLayer.bounds = CGRectMake(0, 0, width, height);
    lineLayer.backgroundColor = color.CGColor;
    [self.layer addSublayer:lineLayer];
}

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor
                         layerName:(NSString *)layerName
                        isPortrait:(BOOL)isPortrait
{
    return [self setupGradientLayerWithView:view
                          startColor:startColor
                            endColor:endColor
                           layerName:layerName
                          isPortrait:isPortrait
                    formerProportion:0.5];
}

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                        startColor:(UIColor *)startColor
                          endColor:(UIColor *)endColor
                         layerName:(NSString *)layerName
                        isPortrait:(BOOL)isPortrait
                  formerProportion:(CGFloat)formerProportion
{
    if (!view || !layerName.length) return nil;
    
    [self removeLayerWithView:view layerName:layerName];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.name = layerName;
    gradientLayer.frame = view.bounds;
    [view.layer insertSublayer:gradientLayer atIndex:0];
    gradientLayer.startPoint = isPortrait ? CGPointMake(0, 0) : CGPointMake(0, 0);
    gradientLayer.endPoint = isPortrait ? CGPointMake(0, 1) : CGPointMake(1, 0);
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,
                             (__bridge id)endColor.CGColor];
    
    gradientLayer.locations = @[@(formerProportion), @(1.0f)];
    return gradientLayer;
}

- (CAGradientLayer *)setupGradientLayerWithView:(UIView *)view
                                     startColor:(UIColor *)startColor
                                       endColor:(UIColor *)endColor
                                      layerName:(NSString *)layerName
                                     startPoint:(CGPoint)startPoint
                                       endPoint:(CGPoint)endPoint
{
    if (!view || !layerName.length) return nil;
    
    [self removeLayerWithView:view layerName:layerName];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.name = layerName;
    gradientLayer.frame = view.bounds;
    [view.layer insertSublayer:gradientLayer atIndex:0];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,
                             (__bridge id)endColor.CGColor];
    
    gradientLayer.locations = @[@(0.f), @(1.0f)];
    return gradientLayer;
}

- (void)removeLayerWithView:(UIView *)view
                  layerName:(NSString *)layerName
{
    if (!view || !layerName.length) return;
    
    [view.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:layerName]) {
            [obj removeFromSuperlayer];
            *stop = YES;
        }
    }];
}

@end

#pragma mark - DYPopMask

static char const * const dy_popMaskPreferenceKey = "dy_popMaskPreference";
static char const * const dy_popMaskAnimationStatesKey = "dy_popMaskAnimationStates";
static char const * const dy_popMaskViewKey = "dy_popMaskViewKey";
static char const * const dy_popMaskDismissBlockKey = "dy_popMaskDismissBlock";

@implementation DYPopMaskPreference
@end

/// NOTE:动画状态
@interface DYPopMaskAnimationStates : NSObject
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isDissmissing;
@end
@implementation DYPopMaskAnimationStates
@end


@implementation UIView (DYPopMask)

- (void)dy_popMask
{
    [self dy_popMaskAtSuperView:nil];
}

- (void)dy_popMaskAtSuperView:(UIView *)superView;
{
    if (self.dy_popMaskAnimationStates.isShowing) return;
    self.dy_popMaskAnimationStates.isShowing = YES;
    
    if(!superView || ![superView isKindOfClass:[UIView class]])
    {
        superView = [UIApplication sharedApplication].delegate.window;
    }
    
    [superView addSubview:self.dy_popMaskView];
    [superView addSubview:self];
    
    CGRect preRect = self.frame;
    CGFloat preAlpha = self.alpha;
    self.frame = self.dy_popMaskPreference.initialFrame;
    self.alpha = self.dy_popMaskPreference.initialAlpha;
    self.dy_popMaskView.alpha = 0.f;
    [UIView animateWithDuration:self.dy_popMaskPreference.animateDuration
                     animations:^{
                         self.frame = preRect;
                         self.alpha = preAlpha;
                         self.dy_popMaskView.alpha = 1.f;
                     } completion:^(BOOL finished) {
                         self.dy_popMaskAnimationStates.isShowing = NO;
                     }];
}

- (void)dy_popMaskDismiss
{
    if (self.dy_popMaskAnimationStates.isDissmissing) return;
    self.dy_popMaskAnimationStates.isDissmissing = YES;
    
    [UIView animateWithDuration:self.dy_popMaskPreference.animateDuration
                     animations:^{
                         self.frame = self.dy_popMaskPreference.initialFrame;
                         self.alpha = self.dy_popMaskPreference.initialAlpha;
                         self.dy_popMaskView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         self.dy_popMaskAnimationStates.isDissmissing = NO;
                         [self.dy_popMaskView removeFromSuperview];
                         [self removeFromSuperview];
                         if (self.dy_popMaskDismissBlock) {
                             self.dy_popMaskDismissBlock();
                         }
                     }];
}

#pragma mark -- getter & setter
// NOTE: PopMaskPreference
- (void)setDy_popMaskPreference:(DYPopMaskPreference *)dy_popMaskPreference
{
    if (!dy_popMaskPreference || ![dy_popMaskPreference isKindOfClass:[DYPopMaskPreference class]]) return;
    [self setAssociateValue:dy_popMaskPreference withKey:(void *)dy_popMaskPreferenceKey];
}
- (DYPopMaskPreference *)dy_popMaskPreference
{
    DYPopMaskPreference * popMaskPreference = [self getAssociatedValueForKey:(void *)dy_popMaskPreferenceKey];
    if (!popMaskPreference) {
        popMaskPreference = [DYPopMaskPreference new];
        popMaskPreference.animateDuration = 0.f;
        popMaskPreference.initialAlpha = self.alpha;
        popMaskPreference.initialFrame = self.frame;
        [self setAssociateValue:popMaskPreference withKey:(void *)dy_popMaskPreferenceKey];
    }
    return popMaskPreference;
}

// NOTE: PopMaskAnimationStates
- (void)setDy_popMaskAnimationStates:(DYPopMaskAnimationStates *)dy_popMaskAnimationStates
{
    if (!dy_popMaskAnimationStates || ![dy_popMaskAnimationStates isKindOfClass:[DYPopMaskAnimationStates class]]) return;
    [self setAssociateValue:dy_popMaskAnimationStates withKey:(void *)dy_popMaskAnimationStatesKey];
}
- (DYPopMaskAnimationStates *)dy_popMaskAnimationStates
{
    DYPopMaskAnimationStates * popMaskAnimationStates = [self getAssociatedValueForKey:(void *)dy_popMaskAnimationStatesKey];
    if (!popMaskAnimationStates) {
        popMaskAnimationStates = [DYPopMaskAnimationStates new];
        [self setAssociateValue:popMaskAnimationStates withKey:(void *)dy_popMaskAnimationStatesKey];
    }
    return popMaskAnimationStates;
}

// NOTE: PopMaskView
- (void)setDy_popMaskView:(UIView *)dy_popMaskView
{
    if (!dy_popMaskView || ![dy_popMaskView isKindOfClass:[UIView class]]) return;
    [self setAssociateValue:dy_popMaskView withKey:(void *)dy_popMaskViewKey];
}
- (UIView *)dy_popMaskView
{
    UIView * popMaskView = [self getAssociatedValueForKey:(void *)dy_popMaskViewKey];
    if (!popMaskView) {
        popMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        popMaskView.alpha = 0.f;
        __weak __typeof__(self) __weak_self__ = self;
        [popMaskView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [__weak_self__ dy_popMaskDismiss];
        }]];
        [popMaskView addGestureRecognizer:[UIPanGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateBegan) [__weak_self__ dy_popMaskDismiss];
        }]];
        [self setAssociateValue:popMaskView withKey:(void *)dy_popMaskViewKey];
    }
    return popMaskView;
}
// NOTE: PopMaskDismissBlock
- (void)setDy_popMaskDismissBlock:(void (^)(void))dy_popMaskDismissBlock
{
    [self setAssociateValue:dy_popMaskDismissBlock withKey:(void *)dy_popMaskDismissBlockKey];
}

- (void (^)(void))dy_popMaskDismissBlock
{
    return [self getAssociatedValueForKey:(void *)dy_popMaskDismissBlockKey];
}

@end
