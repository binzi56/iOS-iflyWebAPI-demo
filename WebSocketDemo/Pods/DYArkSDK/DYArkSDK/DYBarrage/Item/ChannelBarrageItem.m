//
//  ChannelBarrageLabel.m
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import "ChannelBarrageItem.h"
#import "UIView+YYAdd.h"

#import <HexColors/HexColors.h>

//TODO:dealloc时检查view的superview是否还在
//TODO:重构：提取公用逻辑，简化代码

NSString * const kCBContextLabelFontSize = @"kCBContextLabelFontSize";
NSString * const kCBContextLabelOrigin  = @"kCBContextLabelOrigin";
NSString * const kCBContextCanvasBounds = @"kCBContextCanvasBounds";
NSString * const kCBContextTimestamp    = @"kCBContextTimestamp";

const CGFloat kCBLabelSmallDimension        = 16.0;
const CGFloat kCBLabelNormalDimension       = 18.0;
const CGFloat kCBLabelLargeDimension        = 21.0;

const CGFloat kCBLabelPortraitSmallDimension  = 18;
const CGFloat kCBLabelPortraitNormalDimension = 21;
const CGFloat kCBLabelPortraitLargeDimension  = 23;

const CGFloat kCBLabelBorderWidth           = 2.0;
const CGFloat kCBLabelMarginWithBorder      = 2.0; //带边框的Label两端与边框线间留白
const NSTextAlignment kCBLabelTextAlignment = NSTextAlignmentCenter;

#pragma mark - CBLabelAppearance

@implementation CBLabelAppearance

@end

#pragma mark - CBLabelInfo
@implementation CBLabelInfo

@end

#pragma mark - ChannelBarrageLabel

@interface ChannelBarrageItem ()


@property (nonatomic, strong) UILabel *label;

@end

@implementation ChannelBarrageItem

#pragma mark LifeCycle

- (instancetype)initWithAppearance:(CBLabelAppearance *)appearance info:(CBLabelInfo *)info customInfo:(id)customInfo
{
    self = [super init];
    if (self) {
        _appearance = appearance;
        _info = info;
    }
    return self;
}

#pragma mark Property

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = kCBLabelBackgroundColor;
        _label.textAlignment = kCBLabelTextAlignment;
        _label.shadowColor = kCBLabelShadowColor;
        _label.shadowOffset = kCBLabelShadowOffset;
    }
    return _label;
}

#pragma mark Public

- (CGRect)itemFrame
{
    return [_label.layer.presentationLayer frame];
}

- (void)activeWithCanvasView:(UIView *)canvasView context:(NSDictionary *)context
{
    self.valid = YES;
    
    [canvasView addSubview:self.label];
    
    self.timestamp = [context[kCBContextTimestamp] doubleValue];
    
    [self activeWithAppearance:self.appearance context:context];
    self.appearance = nil;
}

- (void)deactive
{
    if (_label.superview != nil) {
        [_label removeFromSuperview];
    }
}

- (void)updatePosY:(CGFloat)posY
{
    if (_label) {
        _label.top = posY - _label.height / 2;
    }
}

#pragma mark Protected

- (void)activeWithAppearance:(CBLabelAppearance *)appearance context:(NSDictionary *)context
{
    //Nothing
}

- (ChannelBarrageViewLevel)viewLevel {
    return ChannelBarrageViewLevelBottom;
}

- (BOOL)needReport {
    return YES;
}

- (ChannelBarrageLineType)lineType
{
    return ChannelBarrageLineTypeDefault;
}

@end
