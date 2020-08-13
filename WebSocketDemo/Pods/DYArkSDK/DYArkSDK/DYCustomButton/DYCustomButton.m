//
//  DYCustomButton.m
//  huhuAudio
//
//  Created by EasyinWan on 2019/8/2.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "DYCustomButton.h"
#import <UIView+DY.h>
#import <objc/runtime.h>
#import "Masonry.h"
#import <GPBDictionary.h>

static NSString * kDYCustomButtonLayer = @"kDYCustomButtonLayer";

@interface DYCustomButtonViewModel : NSObject
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL isNeedGradientSet;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) UIControlState controlState;
@end

@implementation DYCustomButtonViewModel
@end

@interface DYCustomButton ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL isNeedGradientSet;

@property (nonatomic, assign) CGSize preSize;
@property (nonatomic, assign) BOOL isNeedForceLayout;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) UIControlState controlState;

@property (nonatomic, strong) GPBInt64ObjectDictionary<DYCustomButtonViewModel *> *gradientSetting;

@end

@implementation DYCustomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self bgView];
        self.button.bounds = (CGRect){0.f, 0.f, frame.size.width, frame.size.height};
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self bgView];
        [self button];
    }
    return self;
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    self.button.tag = tag;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isNeedForceLayout ||
        !CGSizeEqualToSize(self.frame.size, self.preSize)) {
        self.preSize = self.frame.size;
        [self p_updateBackgroundColorAndTitileColor];
    }
    
}

- (void)p_updateBackgroundColorAndTitileColor
{
    self.isNeedForceLayout = NO;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerAllCorners
                                                           cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
    CAShapeLayer *layer = CAShapeLayer.layer;
    layer.frame = self.bounds;
    layer.path = bezierPath.CGPath;
    self.bgView.layer.mask = layer;
    
    if (self.isNeedGradientSet) {
        [self setupGradientLayerWithView:self.bgView
                              startColor:self.startColor?:[UIColor whiteColor]
                                endColor:self.endColor?:[UIColor whiteColor]
                               layerName:kDYCustomButtonLayer
                              isPortrait:NO];
    }
    
    [self setTitleColor:self.titleColor forState:UIControlStateNormal];
}

- (void)resetButtonWithGradientStartColor:(UIColor *)startColor
                                 endColor:(UIColor *)endColor
                              cornerRadio:(CGFloat)cornerRadius
                               titleColor:(UIColor *)titleColor
{
    if (!startColor || ![startColor isKindOfClass:UIColor.class]) {
        NSAssert(NO, @"invalid startColor");
        startColor = UIColor.whiteColor;
    }
    if (!endColor || ![endColor isKindOfClass:UIColor.class]) {
        NSAssert(NO, @"invalid endColor");
        endColor = UIColor.whiteColor;
    }
    if (!titleColor || ![titleColor isKindOfClass:UIColor.class]) {
        NSAssert(NO, @"invalid titleColor");
        titleColor = UIColor.blackColor;
    }
    
    self.startColor = startColor;
    self.endColor = endColor;
    self.cornerRadius = cornerRadius;
    self.titleColor = titleColor;
    self.isNeedGradientSet = YES;
    
    [self p_updateBackgroundColorAndTitileColor];
    
    if (titleColor) {
        DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:self.controlState];
        if (!viewModel) {
            [self setTitleColor:self.titleColor forState:UIControlStateNormal];
        }
        else {
            [self setTitleColor:self.titleColor forState:self.controlState];
        }
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setupBorderColor:(UIColor *)borderColor
{
    if (!borderColor || ![borderColor isKindOfClass:UIColor.class]) {
        NSAssert(NO, @"invalid borderColor");
        return;
    }
    
    self.button.layer.mask = nil;
    
    [self removeLayerWithView:self.button layerName:kDYCustomButtonLayer];
    
    self.button.layer.borderWidth = 1.f;
    self.button.layer.borderColor = borderColor.CGColor;
    self.button.layer.cornerRadius = self.button.frame.size.height * 0.5f;
}

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state
{
    if (!_gradientSetting) {
        _gradientSetting = [GPBInt64ObjectDictionary new];
    }
    DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:state];
    if (!viewModel) viewModel = [DYCustomButtonViewModel new];
    viewModel.title = title;
    [_gradientSetting setObject:viewModel forKey:state];
    
    [self.button setTitle:title forState:state];
}
- (void)setTitleFont:(nullable UIFont *)font
{
    self.button.titleLabel.font = font;
}
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state
{
    if (!_gradientSetting) {
        _gradientSetting = [GPBInt64ObjectDictionary new];
    }
    DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:state];
    if (!viewModel) viewModel = [DYCustomButtonViewModel new];
    viewModel.titleColor = color;
    [_gradientSetting setObject:viewModel forKey:state];
    
    [self.button setTitleColor:color forState:state];
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setButtonWithGradientStartColor:(UIColor *)startColor
                               endColor:(UIColor *)endColor
                            cornerRadio:(CGFloat)cornerRadius
                             titleColor:(UIColor *)titleColor
                      isNeedGradientSet:(BOOL)isNeedGradientSet
                        backgroundColor:(UIColor *)backgroundColor
                               forState:(UIControlState)state
{
    if (!_gradientSetting) {
        _gradientSetting = [GPBInt64ObjectDictionary new];
    }
    
    if (!isNeedGradientSet) {
        if (!backgroundColor ||
            !titleColor) {
            return;
        }
    }
    else {
        if (!startColor ||
            !endColor ||
            !titleColor) {
            return;
        }
    }
    
    DYCustomButtonViewModel *viewModel = [DYCustomButtonViewModel new];
    viewModel.startColor = startColor;
    viewModel.endColor = endColor;
    viewModel.cornerRadius = cornerRadius;
    viewModel.titleColor = titleColor;
    viewModel.isNeedGradientSet = isNeedGradientSet;
    viewModel.backgroundColor = backgroundColor;
    viewModel.controlState = state;
    [_gradientSetting setObject:viewModel forKey:state];
    
    if (titleColor) {
        [self setTitleColor:titleColor forState:state];
    }
    
    if (UIControlStateNormal == state) {
        if (!self.selected &&
            !self.highlighted) {
            self.button.selected = NO;
            self.button.highlighted = NO;
            [self resetGradientWithViewModel:viewModel];
        }
        return;
    }
    if (UIControlStateSelected == state) {
        if (self.selected) {
            self.button.selected = YES;
            self.button.highlighted = NO;
            [self resetGradientWithViewModel:viewModel];
        }
    }
    else if (UIControlStateHighlighted == state) {
        if (self.highlighted) {
            self.button.selected = NO;
            self.button.highlighted = YES;
            [self resetGradientWithViewModel:viewModel];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
        
    self.button.selected = selected;
    self.button.highlighted = NO;
    
    if (!selected) {
        DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:UIControlStateNormal];
        [self resetGradientWithViewModel:viewModel];
        return;
    }
    DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:UIControlStateSelected];
    [self resetGradientWithViewModel:viewModel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    self.button.selected = NO;
    self.button.highlighted = highlighted;
    
    if (!highlighted) {
        DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:UIControlStateNormal];
        [self resetGradientWithViewModel:viewModel];
        return;
    }
    DYCustomButtonViewModel *viewModel = [_gradientSetting objectForKey:UIControlStateHighlighted];
    [self resetGradientWithViewModel:viewModel];
}

- (void)resetGradientWithViewModel:(DYCustomButtonViewModel *)viewModel
{
    if (!viewModel) return;
    
    self.isNeedForceLayout = YES;
    self.isNeedGradientSet = viewModel.isNeedGradientSet;
    self.cornerRadius = viewModel.cornerRadius;
    self.titleColor = viewModel.titleColor;
    self.controlState = viewModel.controlState;
    if (!viewModel.isNeedGradientSet) {
        [self.bgView removeLayerWithView:self.bgView layerName:kDYCustomButtonLayer];
        self.bgView.backgroundColor = viewModel.backgroundColor;
        [self setTitle:viewModel.title ?: @"" forState:UIControlStateNormal];
        [self setTitleColor:viewModel.titleColor forState:UIControlStateNormal];
        self.isNeedForceLayout = NO;
        return;
    }
    [self resetButtonWithGradientStartColor:viewModel.startColor
                                   endColor:viewModel.endColor
                                cornerRadio:viewModel.cornerRadius
                                 titleColor:viewModel.titleColor];
}

- (UIView *)bgView
{
    if (!_bgView) {
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        _bgView = view;
    }
    return _bgView;
}

- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = UIColor.clearColor;
        [self.bgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        _button = button;
    }
    return _button;
}

@end


@interface DYCustomControlWrapper : NSObject <NSCopying>

- (id)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic) UIControlEvents controlEvents;
@property (nonatomic, copy) void (^handler)(id sender);

@end

@implementation DYCustomControlWrapper

- (id)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents
{
    self = [super init];
    if (!self) return nil;

    self.handler = handler;
    self.controlEvents = controlEvents;

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[DYCustomControlWrapper alloc] initWithHandler:self.handler forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender
{
    self.handler(sender);
}

@end

static const void *DYCustomControlHandlersKey = &DYCustomControlHandlersKey;

@implementation DYCustomButton (BlocksKit)

- (void)bk_addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents
{
    NSParameterAssert(handler);
    
    NSMutableDictionary *events = objc_getAssociatedObject(self, DYCustomControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, DYCustomControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSMutableSet *handlers = events[key];
    if (!handlers) {
        handlers = [NSMutableSet set];
        events[key] = handlers;
    }
    
    DYCustomControlWrapper *target = [[DYCustomControlWrapper alloc] initWithHandler:handler forControlEvents:controlEvents];
    [handlers addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
}

- (void)bk_removeEventHandlersForControlEvents:(UIControlEvents)controlEvents
{
    NSMutableDictionary *events = objc_getAssociatedObject(self, DYCustomControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, DYCustomControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSSet *handlers = events[key];

    if (!handlers)
        return;

    [handlers enumerateObjectsUsingBlock:^(id sender, BOOL *stop) {
        [self.button removeTarget:sender action:NULL forControlEvents:controlEvents];
    }];

    [events removeObjectForKey:key];
}

- (BOOL)bk_hasEventHandlersForControlEvents:(UIControlEvents)controlEvents
{
    NSMutableDictionary *events = objc_getAssociatedObject(self, DYCustomControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, DYCustomControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSNumber *key = @(controlEvents);
    NSSet *handlers = events[key];
    
    if (!handlers)
        return NO;
    
    return !!handlers.count;
}

@end
