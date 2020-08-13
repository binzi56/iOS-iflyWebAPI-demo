//
//  apputils.h
//  ipadyy
//
//  Created by lslin on 13-1-30.
//  Copyright (c) 2013年 YY.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KiwiSDKMacro.h"

@class ALAssetsLibrary;

@interface AppUtils : NSObject

@property (nonatomic, copy) NSString * version;

WF_AS_SINGLETION(AppUtils);

#pragma mark - Bundle methods

+ (NSBundle *)bundle;
+ (id)bundleInfoForKey:(NSString *)key;
+ (NSString *)bundleName;
+ (NSString *)bundleDisplayName;
+ (NSString *)bundlePath;

+ (void)setBundleDisplayName:(NSString *)bundleDisplayName;

/**
 * app的bundleId
 */
+ (NSString *)bundleIdentifier;

/**
 * 完整版本号，对应XCode-Info-Version + Build，内部版本应该显示这个。
 * @return "1.3.0.187"
 */
+ (NSString *)bundleFullVersion;

/**
 * 发布版本号，对应XCode-Info-Version，对于外发版本应该显示这个。
 * @return "1.3.0"
 */
+ (NSString *)bundleAppVersion;

/**
 * 构建版本号，对应XCode-Info-Build
 * @return "187"
 */
+ (NSString *)bundleBuildVersion;

/*
 * 临时兼容老的版本判断逻辑
 */
+ (NSNumber *)bundleAppVersionNumber;

+ (NSString*)appClient;

/**
 * 获取当前平台字符串：ios、ipad，通过  "+ (NSString *)platformString"  方法返回
 * 对于Kiwi、KiwiHD 可以不需要设置，已经通过BundleID自动设置
 * 其它的项目，可以通过调用这个方法来设置platformString的返回值
 */
+ (void)setupPlatformString:(NSString *)platformString;

/**
 * 获取当前平台字符串：ios、ipad
 */
+ (NSString *)platformString;

/**
 * 统计上报版本号
 * @return 内部版本 -> "1.3.0.187"; 外发版本 -> "1.3.0"
 */
+ (NSString *)bundleStatisticVersion;

#pragma mark - url

+ (BOOL)openURL:(NSString *)url;

#pragma mark - lang

+ (NSString *)currentLanguage;

#pragma mark - device

/**
 * 相机是否可用
 */
+ (BOOL)isCameraAvailable;

/**
 * 照片库是否可用
 */
+ (BOOL)isAssetsLibraryAvailable;

/**
 * 相册资源库
 */
+ (ALAssetsLibrary *)assetsLibrary;

/**
 * @brief  检查obj上次触发事件和当前时间的间隔是否大于最小间隔interval
 * @return 如果间隔大于interval，则返回YES，并且把事件触发时间更新为当前时间；否则返回NO
 * @note 如果obj为nil，返回YES，不做间隔检测
 */
+ (BOOL)lastTriggerDateOfObject:(id)obj greatThanInterval:(NSTimeInterval)interval;

/**
 *  @brief  生成1-50的随机数
 */
+ (int)randomIntBetween1And50ForSubSid:(uint32_t)subSid;

/**
 * 清除某个域下的cookie
 */
+ (void)clearCookie:(NSString*)domain;

/**
 * 根据字符串生成hash值
 */
+ (uint32_t)hashCodeForString:(NSString *)string;

/**
 * 判断用户当前是否启用了推送通知
 */
+ (BOOL)isUserNotificationEnabled;

+ (NSString *)appInfoForLog;

+ (void)dumpAppInfo;

+ (BOOL)isJailbroken;


/**
 获取进程启动时间戳
 */
+ (int64_t)processStartTimestamp;

@end
