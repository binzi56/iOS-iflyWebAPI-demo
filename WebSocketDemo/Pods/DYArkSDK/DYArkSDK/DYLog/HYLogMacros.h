//
//  HYLogMacros.h
//  KiwiSDK
//
//  Created by pengfeihuang on 16/9/7.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYLog.h"

#define HY_LOG_MACRO(level, moduleName, format, ...) \
    HY_LOG_INTERNAL(level, moduleName, format, ##__VA_ARGS__)
#define HY_LOG_IMMEDIATELY_MACRO(level, moduleName, format, ...) \
    HY_LOG_IMMEDIATELY_INTERNAL(level, moduleName, format, ##__VA_ARGS__)

#define HY_LOG_ERROR(module, format, ...) HY_LOG_MACRO(HYLogLevelError, module, format, ##__VA_ARGS__)
#define HY_LOG_WARNING(module, format, ...) HY_LOG_MACRO(HYLogLevelWarn, module, format, ##__VA_ARGS__)
#define HY_LOG_INFO(module, format, ...) HY_LOG_MACRO(HYLogLevelInfo, module, format, ##__VA_ARGS__)
#define HY_LOG_DEBUG(module, format, ...) HY_LOG_MACRO(HYLogLevelDebug, module, format, ##__VA_ARGS__)

#define HY_LOG_INFO_IMMEDIATELY(module, format, ...) HY_LOG_IMMEDIATELY_MACRO(HYLogLevelInfo, module, format, ##__VA_ARGS__)

#pragma mark - module define

#define kDefaultModule @"HY-Default"
#define kChargeModule  @"HY-Charge"
#define kMediaModule   @"HY-Media"
#define kWebModule     @"HY-Web"
#define kYYSDKModule   @"YYSDK"
#define kHYSDKModule   @"HYSDK"

#define KWSLogError(frmt, ...)  \
    HY_LOG_ERROR(kDefaultModule, frmt, ##__VA_ARGS__)

#define KWSLogWarn(frmt, ...)  \
    HY_LOG_WARNING(kDefaultModule, frmt, ##__VA_ARGS__)

#define KWSLogInfo(frmt, ...)  \
    HY_LOG_INFO(kDefaultModule, frmt, ##__VA_ARGS__)

#define KWSLogDebug(frmt, ...)  \
    HY_LOG_DEBUG(kDefaultModule, frmt, ##__VA_ARGS__)

#define DYLogError KWSLogError
#define DYLogWarn  KWSLogWarn
#define DYLogInfo  KWSLogInfo
#define DYLogDebug KWSLogDebug

#define DYLogInfoMedia KWSLogInfo

#pragma mark - macro context submodule

#define KWSLogErrorChargeModule(frmt, ...)  \
    HY_LOG_ERROR(kChargeModule, frmt, ##__VA_ARGS__);

#define KWSLogWarnChargeModule(frmt, ...)  \
        HY_LOG_WARNING(kChargeModule, frmt, ##__VA_ARGS__);

#define KWSLogInfoChargeModule(frmt, ...)  \
        HY_LOG_INFO(kChargeModule, frmt, ##__VA_ARGS__);

#define KWSLogDebugChargeModule(frmt, ...)  \
        HY_LOG_DEBUG(kChargeModule, frmt, ##__VA_ARGS__);

#pragma mark - macro submodule
//
//#define KWSLogErrorSubModule(submodule, frmt, ...)  \
//        KWSLogCustom(KWSLogContextDefault, nil, submodule, DDLogFlagError, frmt, ##__VA_ARGS__);
//
//#define KWSLogWarnSubModule(submodule, frmt, ...)  \
//        KWSLogCustom(KWSLogContextDefault, nil, submodule, DDLogFlagWarning, frmt, ##__VA_ARGS__);
//
//#define KWSLogInfoSubModule(submodule, frmt, ...)  \
//        KWSLogCustom(KWSLogContextDefault, nil, submodule, DDLogFlagInfo, frmt, ##__VA_ARGS__);
//
//#define KWSLogDebugSubModule(submodule, frmt, ...)  \
//        KWSLogCustom(KWSLogContextDefault, nil, submodule, DDLogFlagDebug, frmt, ##__VA_ARGS__);

#pragma mark - macro media(进频道、音视频相关专用)

#define KWSLogErrorMedia(frmt, ...)  \
    HY_LOG_ERROR(kMediaModule, frmt, ##__VA_ARGS__);

#define KWSLogWarnMedia(frmt, ...)  \
    HY_LOG_WARNING(kMediaModule, frmt, ##__VA_ARGS__);

#define KWSLogInfoMedia(frmt, ...)  \
    HY_LOG_INFO(kMediaModule, frmt, ##__VA_ARGS__);

#define KWSLogInfoHySdk(frmt, ...)  \
    HY_LOG_INFO(kHYSDKModule, frmt, ##__VA_ARGS__);

#pragma mark - YYSDK log

#define KWSLOGYYSDK(level, format, ...) \
    HY_LOG_SIMPLE_INTERNAL(level, kYYSDKModule, format, ##__VA_ARGS__)

#pragma mark - Web log

//#define KWSLogInfoWeb(frmt, ...)  \
//HY_LOG_INFO(kWebModule, frmt, ##__VA_ARGS__);

#define KWSLOGHYSDK(level, format, ...) \
    HY_LOG_SIMPLE_INTERNAL(level, kHYSDKModule, format, ##__VA_ARGS__)

#pragma mark - macro immediately(立即写 log，崩溃前调用)

#define KWSLogInfoImmediately(frmt, ...)  \
HY_LOG_INFO_IMMEDIATELY(kDefaultModule, frmt, ##__VA_ARGS__)
