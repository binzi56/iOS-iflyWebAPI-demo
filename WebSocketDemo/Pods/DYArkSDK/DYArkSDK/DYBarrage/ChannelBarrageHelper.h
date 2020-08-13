//
//  ChannelBarrageHelper.h
//  kiwi
//
//  Created by 潘志勇 on 2018/1/30.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelBarrageTypes.h"

extern const CGFloat kDefaultBarrageAlpha;
extern const CGFloat kMinBarrageAlpha;

@interface ChannelBarrageHelper : NSObject

/**
 根据弹幕的大、中、小类型生成真正的弹幕大小
 @param videoVertical 是否是竖屏
 */
+ (CGFloat)actualBarrageFontSizeWithFont:(ChannelBarrageFontSize)font videoVertical:(BOOL)videoVertical;

@end
