//
//  ChannelBarrageDispatcher.h
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelBarrageTypes.h"
#import "ChannelBarrageDelegate.h"

static const NSTimeInterval kNormalBarrageDuration          = 8.5; //普通弹幕9秒跑完
static const NSTimeInterval kNormalPortraitBarrageDuration  = 6.0; //横屏6秒跑完

@class ChannelBarrageItem;

@protocol ChannelBarrageDispatcher <NSObject>

@property (nonatomic, assign) ChannelBarrageFontSize fontSize;
@property (nonatomic, assign) BOOL portrait;
@property (nonatomic, weak) id<ChannleBarrageDelegate> delegate;
- (instancetype)initWithCanvasView:(UIView *)canvasView mode:(ChannelBarrageMode)mode fontSize:(ChannelBarrageFontSize)fontSize portrait:(BOOL)isPortrait;

- (void)prependItem:(ChannelBarrageItem *)item;
- (void)appendItem:(ChannelBarrageItem *)item;
- (void)clearItems;
- (NSUInteger)getItemCountInSixthLine;

- (void)updateWithTime:(CFTimeInterval)time interval:(CFTimeInterval)interval;
- (NSTimeInterval)itemDuration;

@end
