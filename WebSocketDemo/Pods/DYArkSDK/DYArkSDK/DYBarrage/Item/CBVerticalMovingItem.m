//
//  ChannelBarrageLabel.m
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import "CBVerticalMovingItem.h"
#import "UILabel+KWS.h"

#import <HexColors/HexColors.h>

//TODO:重构：提取公用逻辑，简化代码
//TODO:支持nil时的默认值

static const NSUInteger kMaxTextLength = 30;

@implementation CBVerticalMovingItem

- (void)activeWithAppearance:(CBLabelAppearance *)appearance context:(NSDictionary *)context
{
    self.label.text = [self verticalTextForText:appearance.text];
    self.label.textColor = appearance.textColor;
    self.label.font = [UIFont boldSystemFontOfSize:[context[kCBContextLabelFontSize] floatValue]];
    self.label.numberOfLines = 0;
    
    CGSize labelSize = [self.label safeSizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    if (appearance.borderColor != nil) {
        labelSize.width += 2 * kCBLabelMarginWithBorder;
        
        self.label.layer.borderColor = appearance.borderColor.CGColor;
        self.label.layer.borderWidth = kCBLabelBorderWidth;
    }
    
    CGSize canvasSize = [context[kCBContextCanvasBounds] CGRectValue].size;
    labelSize.width = MIN(labelSize.width, canvasSize.width);
    labelSize.height = labelSize.height;
    
    const NSTimeInterval duration = [appearance.duration doubleValue];
    self.speed = (canvasSize.height + labelSize.height) / duration;
    
    CGPoint origin = [context[kCBContextLabelOrigin] CGPointValue];
    self.label.frame = CGRectMake(origin.x, origin.y, labelSize.width, labelSize.height);
    
    CGRect targetFrame = self.label.frame;
    targetFrame.origin.y = -CGRectGetHeight(targetFrame);
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.label.frame = targetFrame;
                     }
                     completion:^(BOOL finished) {
                         self.valid = NO;
                     }];
}

- (NSString *)verticalTextForText:(NSString *)text
{
    if ([text length] > kMaxTextLength) {
        text = [NSString stringWithFormat:@"%@…", [text substringToIndex:kMaxTextLength]];
    }
    
    NSMutableString *verticalText = [[NSMutableString alloc] init];
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              [verticalText appendString:[NSString stringWithFormat:@"%@\n", substring]];
                          }];
    return [verticalText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

@end
