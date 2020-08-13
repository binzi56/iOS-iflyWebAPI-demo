//
//  ChannelBarrageLabel.m
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import "CBFlashItem.h"
#import "UILabel+KWS.h"

#import <HexColors/HexColors.h>

//TODO:重构：提取公用逻辑，简化代码
//TODO:支持nil时的默认值

static const NSUInteger kCBFlashItemFlashTimes       = 3;
static const NSTimeInterval kCBFlashItemFadeDuration = 0.5;

@interface CBFlashItem ()

@property (nonatomic, assign) CGFloat duration;

@end

@implementation CBFlashItem

- (void)activeWithAppearance:(CBLabelAppearance *)appearance context:(NSDictionary *)context
{
    self.duration = [appearance.duration doubleValue];
    
    self.label.text = appearance.text;
    self.label.textColor = appearance.textColor;
    self.label.font = [UIFont boldSystemFontOfSize:[context[kCBContextLabelFontSize] floatValue]];
    
    CGSize labelSize = [self.label safeSizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    if (appearance.borderColor != nil) {
        labelSize.width += 2 * kCBLabelMarginWithBorder;
        
        self.label.layer.borderColor = appearance.borderColor.CGColor;
        self.label.layer.borderWidth = kCBLabelBorderWidth;
    }
    
    CGSize canvasSize = [context[kCBContextCanvasBounds] CGRectValue].size;
    labelSize.width = MIN(labelSize.width, canvasSize.width);
    labelSize.height = MIN(labelSize.height, canvasSize.height);
    
    CGPoint origin = [context[kCBContextLabelOrigin] CGPointValue];
    origin.x = MIN(origin.x, canvasSize.width - labelSize.width);
    origin.y = MIN(origin.y, canvasSize.height - labelSize.height);
    self.label.frame = CGRectMake(origin.x, origin.y, labelSize.width, labelSize.height);
    
    [self runWithTimes:kCBFlashItemFlashTimes];
}

- (void)runWithTimes:(NSUInteger)times
{
    if (times == 0) {
        self.valid = NO;
        return;
    }
    
    const NSUInteger remainingTimes = times - 1;
    //[NOTE] 直接用UIViewAnimationOptionAutoreverse，在动画执行完成时alpha为目标的1.0而淡出后突然显示
    self.label.alpha = 0.0;
    [UIView animateWithDuration:kCBFlashItemFadeDuration animations:^{
        self.label.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kCBFlashItemFadeDuration animations:^{
            self.label.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self runWithTimes:remainingTimes];
        }];
    }];
}

@end
