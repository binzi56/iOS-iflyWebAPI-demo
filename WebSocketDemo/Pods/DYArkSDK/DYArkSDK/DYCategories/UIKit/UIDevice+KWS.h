//
//  UIDevice+KWS.h
//  KiwiSDK
//
//  Created by 赵瑜瑜 on 16/6/12.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DYScreenType)
{
    DYScreenTypeUndefined   = 0,
    DYScreenTypeIpadClassic = 1,//iPad 1,2,mini
    DYScreenTypeIpadRetina  = 2,//iPad 3以上,mini2以上
    DYScreenTypeIpadPro     = 3,//iPad Pro
    DYScreenTypeClassic     = 4,//3gs及以下
    DYScreenTypeRetina      = 5,//4&4s
    DYScreenTypeRetina4Inch = 6,//5&5s&5c
    DYScreenTypeIphone6     = 7,//6或者6+放大模式
    DYScreenTypeIphone6Plus = 8,//6+
    DYScreenTypeIphoneX     = 9,//iphone X
    DYScreenTypeIphoneXR    = 10,//iphone XR
};

@interface UIDevice (KWS)

@property (nonatomic, readonly) NSString *machineModel;
@property (nonatomic, readonly) NSString *machineModelName;

- (BOOL)isLowPerformanceDevice;

- (NSString*)hy_systemVersion;

- (BOOL)isIPhone4sOrLower;

- (BOOL)isIPhone5sOrLower;

- (BOOL)isIPhone6OrLower;

- (BOOL)isLowerThanIPad3;

- (BOOL)isIPhoneLowerThan:(NSString *)modelName;

- (BOOL)isIPadLowerThan:(NSString *)modelName;

- (BOOL)isARM64;

@end



@interface UIDevice (DYAdd)

/**
 * 判断当前屏幕类型
 *
 * @return DYScreenType 当前屏幕的类型
 */
- (DYScreenType)screenType;

/**
 * 判断当前屏幕是否为4英寸Retina屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isRetina4Inch;

/**
 * 判断当前屏幕是否为iphone6尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isIPhone6;

/**
 * 判断当前屏幕是否为iphone6Plus尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isIPhone6Plus;

/**
 * 判断当前屏幕是否为 iphoneX 尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isIPhoneX;

/**
 * 判断当前屏幕是否为 iphoneXR 尺寸屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isIPhoneXR;

/**
 * 判断当前屏幕是否为刘海屏
 *
 * @return BOOL类型YES or NO.
 */
- (BOOL)dy_isNotch;

- (CGFloat)dy_safeBottom;
@end
