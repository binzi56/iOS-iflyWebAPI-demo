//
//  BundleUtils.h
//  WFSDK
//
//  Created by pengfeihuang on 16/9/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BundleUtils : NSObject

#pragma mark - Bundle methods

+ (NSBundle *)bundle;
+ (id)bundleInfoForKey:(NSString *)key;
+ (NSString *)bundleName;
+ (NSString *)bundleDisplayName;
+ (NSString *)bundlePath;

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


/**
 发布版本号转整型

 @return "1003001"
 */
+ (NSInteger)bundleAppVersionInteger;

@end
