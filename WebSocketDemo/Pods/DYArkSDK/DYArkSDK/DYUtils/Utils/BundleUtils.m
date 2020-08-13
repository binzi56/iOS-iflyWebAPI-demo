//
//  BundleUtils.m
//  WFSDK
//
//  Created by pengfeihuang on 16/9/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "BundleUtils.h"

@implementation BundleUtils

#pragma mark Bundle

+ (NSBundle *)bundle
{
    return [NSBundle mainBundle];
}

+ (id)bundleInfoForKey:(NSString *)key
{
    return [[BundleUtils bundle] objectForInfoDictionaryKey:key];
}

+ (NSString *)bundleName
{
    return [BundleUtils bundleInfoForKey:@"CFBundleName"];
}

+ (NSString *)bundleDisplayName
{
    return [BundleUtils bundleInfoForKey:@"CFBundleDisplayName"];
}

+ (NSString *)bundlePath
{
    return [[BundleUtils bundle] bundlePath];
}

+ (NSString *)bundleFullVersion
{
    return [NSString stringWithFormat:@"%@.%@", [BundleUtils bundleAppVersion], [BundleUtils bundleBuildVersion]];
}

+ (NSString *)bundleAppVersion
{
    return [BundleUtils bundleInfoForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleBuildVersion
{
    return [BundleUtils bundleInfoForKey:@"CFBundleVersion"];
}

+ (NSInteger)bundleAppVersionInteger
{
    NSArray *versions = [[self bundleAppVersion] componentsSeparatedByString:@"."];
    NSInteger version = 0;
    for (NSString *str in versions) {
        NSInteger value = [str integerValue];
        if (version == 0) {
            version = value;
        } else {
            version = version * 1000 + value;
        }
    }
    return version;
}

@end
