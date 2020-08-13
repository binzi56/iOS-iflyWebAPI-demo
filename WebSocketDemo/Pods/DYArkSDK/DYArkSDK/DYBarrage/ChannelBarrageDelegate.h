////  ChannelBarrageDelegate.h
//  KiwiSDK
//
//  Created by Haisheng Ding on 2018/7/31.
//  Copyright © 2018年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChannleBarrageDelegate <NSObject>

@required

@optional
- (BOOL)isLowPerformanceDevice;
- (void)reportLostBarrageWithCount:(NSInteger)count;

- (CGFloat)barrageLabelSmallDimension;
- (CGFloat)barrageLabelNormalDimension;
- (CGFloat)barrageLabelLargeDimension;

- (CGFloat)barragePortraitLabelSmallDimension;
- (CGFloat)barragePortraitLabelNormalDimension;
- (CGFloat)barragePortraitLabelLargeDimension;

@end
