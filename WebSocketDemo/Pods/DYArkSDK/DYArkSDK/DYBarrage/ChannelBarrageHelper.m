//
//  ChannelBarrageHelper.m
//  kiwi
//
//  Created by 潘志勇 on 2018/1/30.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import "ChannelBarrageHelper.h"
#import "KiwiSDKMacro.h"
#import "UiUtils.h"

@implementation ChannelBarrageHelper

const CGFloat kBarrageFontSizeSmall          = 15.0;
const CGFloat kBarrageFontSizeNormal         = 17.0;
const CGFloat kBarrageFontSizeLarge          = 18.0;

const CGFloat kDefaultBarrageAlpha           = 0.75;
const CGFloat kMinBarrageAlpha               = 0.05;

+ (CGFloat)actualBarrageFontSizeWithFont:(ChannelBarrageFontSize)font videoVertical:(BOOL)videoVertical
{
    CGFloat actualFontSize = font == ChannelBarrageFontSizeSmall ? kBarrageFontSizeSmall : (font == ChannelBarrageFontSizeNormal ? kBarrageFontSizeNormal : kBarrageFontSizeLarge);
    //竖屏字号小1
    if (videoVertical) {
        actualFontSize -= 1;
    }
    
    //全屏弹幕在plus上增加一号字
    //竖屏弹幕小弹幕在plus上增加一号字
    if (!videoVertical || font == ChannelBarrageFontSizeSmall) {
        if (IS_IPHONE_HEIGHT_OVER_736) { //竖屏&6+上，大一号
            actualFontSize += 1;
        }
    }
    return actualFontSize;
}

@end
