//
//  ChannelBarrageTypes.h
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

//TODO:取消关闭状态
//TODO:考虑字体与行高的对应关系

typedef NS_ENUM(NSUInteger, ChannelBarrageMode) {
    ChannelBarrageModeClosed = 0,  /**< 弹幕关闭 */
    ChannelBarrageModeNormal,      /**< 弹幕开启-普通模式（全屏） */
    ChannelBarrageModeSimple,      /**< 弹幕开启-精简模式（2行） */
};

typedef NS_ENUM(NSUInteger, ChannelBarrageFontSize) {
    ChannelBarrageFontSizeLarge = 0,
    ChannelBarrageFontSizeNormal,
    ChannelBarrageFontSizeSmall
};


typedef NS_ENUM(NSUInteger, ChannelBarrageViewLevel) {
    ChannelBarrageViewLevelBottom = 0,
    ChannelBarrageViewLevelTop = 1,
};

typedef NS_ENUM(NSUInteger, ChannelBarrageLineType) {
    ChannelBarrageLineTypeSingle,
    ChannelBarrageLineTypeDouble,
    ChannelBarrageLineTypeDefault,
};
