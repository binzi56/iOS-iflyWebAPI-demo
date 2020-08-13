////  HYOOMDetector.h
//  kiwi
//
//  Created by Haisheng Ding on 2018/5/10.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HYTerminateType) {
    HYTerminateTypeUnknown = -1,
    HYTerminateTypeAppLaunchAfterFirstInstall = 0, //首次安装后启动
    HYTerminateTypeAppUpgrade = 1, //app升级
    HYTerminateTypeCrash = 2, //crash
    HYTerminateTypeExit = 3, //程序主动exit
    HYTerminateTypeTerminate = 4, //用户强杀
    HYTerminateTypeOSUpgrade = 5, //系统升级
    HYTerminateTypeDeviceReboot = 6, //设备重启
    HYTerminateTypeActiveFoom = 7, //app 在Active状态时发生oom
    HYTerminateTypeInactiveFoom = 8, //app 在Inactive状态时发生oom
    HYTerminateTypeBoom = 9 //app 在background状态时发生oom
};

@interface HYOOMDetector : NSObject

/**
 * 启动OOM监控
 * @note OOM监控依赖APP状态，建议在application:didFinishLaunchingWithOptions:调用该方法，该方法为异步接口。
 * @param handle 上一次app退出状态回调，handle在子线程调用
 */
+ (void)startDetectWithLastStatusHandle:(void(^)(HYTerminateType terminateType,NSString* warningInfo))handle;

/**
 * 记录Exit状态，程序调用exit()时调用该方法记录状态
 */
+ (void)logExit;

/**
 * 记录Crash状态，程序调用crash时调用该方法记录状态
 */
+ (void)logCrash;

/**
 * 获取TerminateType字符串
 * @param terminateType APP终止类型
 */
+ (NSString*)stringFromTerminateType:(HYTerminateType)terminateType;

@end
