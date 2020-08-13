//
//  ChannelBarrageLabel.h
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelBarrageTypes.h"

#pragma mark - ChannelBarrageContextKey

extern NSString * const kCBContextLabelFontSize;
extern NSString * const kCBContextLabelOrigin;
extern NSString * const kCBContextCanvasBounds; //TODO:取消此Key
extern NSString * const kCBContextTimestamp;

#pragma mark - ChannelBarrageLabelAttribute

//TODO:调整此块代码

#define kCBLabelBackgroundColor [UIColor clearColor]
#define kCBLabelShadowColor     [UIColor colorWithWhite:0.0 alpha:0.75]
#define kCBLabelShadowOffset    CGSizeMake(1.0, 1.0)

extern const CGFloat kCBLabelPortraitSmallDimension;
extern const CGFloat kCBLabelPortraitNormalDimension;
extern const CGFloat kCBLabelPortraitLargeDimension;


extern const CGFloat kCBLabelSmallDimension;
extern const CGFloat kCBLabelNormalDimension;
extern const CGFloat kCBLabelLargeDimension;

extern const CGFloat kCBLabelBorderWidth;
extern const CGFloat kCBLabelMarginWithBorder;
extern const NSTextAlignment kCBLabelTextAlignment;

#pragma mark - CBLabelAppearance

@interface CBLabelAppearance : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, assign) CGFloat lastItemWidth;

@end

@interface CBLabelInfo : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, strong) NSString *name;

@end

#pragma mark - ChannelBarrageLabel

@interface ChannelBarrageItem : NSObject

@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, assign) CFTimeInterval timestamp;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, strong) CBLabelAppearance *appearance;
@property (nonatomic, strong) CBLabelInfo *info;

- (instancetype)initWithAppearance:(CBLabelAppearance *)appearance info:(CBLabelInfo *)info customInfo:(id)customInfo;

- (CGRect)itemFrame;
- (void)activeWithCanvasView:(UIView *)canvasView context:(NSDictionary *)context;
- (void)deactive;
- (void)updatePosY:(CGFloat)posY;

//[NOTE] 仅用于子类重写
- (void)activeWithAppearance:(CBLabelAppearance *)appearance context:(NSDictionary *)context;
- (ChannelBarrageViewLevel)viewLevel; //弹幕显示view层级，默认ChannelBarrageViewLevelBottom;
- (BOOL)needReport; //是否需要上报，默认yes

- (ChannelBarrageLineType)lineType;

@end
