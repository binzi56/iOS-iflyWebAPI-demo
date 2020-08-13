//
//  apputils.m
//  ipadyy
//
//  Created by lslin on 13-1-30.
//  Copyright (c) 2013年 YY.com. All rights reserved.
//

#import "AppUtils.h"
#import "AppDeviceUtils.h"
#import "VersionHelper.h"
#import "NetworkManager.h"
#include <sys/sysctl.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KiwiSDKMacro.h"

static NSString *_bundleDisplayName = @"";

@implementation AppUtils

WF_DEF_SINGLETION(AppUtils);

#pragma mark Bundle

+ (NSBundle *)bundle
{
    return [NSBundle mainBundle];
}

+ (id)bundleInfoForKey:(NSString *)key
{
    return [[AppUtils bundle] objectForInfoDictionaryKey:key];
}

+ (NSString *)bundleName
{
    return [AppUtils bundleInfoForKey:@"CFBundleName"];
}

+ (NSString *)bundleDisplayName
{
    if (_bundleDisplayName.length) {
        return _bundleDisplayName;
    }
    return [AppUtils bundleInfoForKey:@"CFBundleDisplayName"];
}

+ (void)setBundleDisplayName:(NSString *)bundleDisplayName
{
    _bundleDisplayName = bundleDisplayName;
}

+ (NSString *)bundlePath
{
    return [[AppUtils bundle] bundlePath];
}

+ (NSString *)bundleIdentifier
{
    return [[AppUtils bundle] bundleIdentifier];
}

+ (NSString *)bundleFullVersion
{
    return [NSString stringWithFormat:@"%@.%@", [AppUtils bundleAppVersion], [AppUtils bundleBuildVersion]];
}

+ (NSString *)bundleAppVersion
{
    return [self sharedInstance].version?[self sharedInstance].version:[AppUtils bundleInfoForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleBuildVersion
{
    return [AppUtils bundleInfoForKey:@"CFBundleVersion"];
}

+ (NSNumber *)bundleAppVersionNumber
{
    NSString* appVersion = [AppUtils bundleAppVersion];
    NSArray* versionArr = [appVersion componentsSeparatedByString:@"."];
    NSString* versionCode = [NSString stringWithFormat:@"%@.%@%@",versionArr[0],versionArr[1],versionArr[2]];
    return [NSNumber numberWithFloat:[versionCode floatValue]];
}

+ (NSString*)appClient
{
    NSString* system = [[UIDevice currentDevice] hy_systemVersion];
    NSString* device = [UIDevice currentDevice].machineModelName;
    NSString* appVersion = [AppUtils bundleAppVersion];
    NSString* bundleBuildVersion = [AppUtils bundleBuildVersion];
    return [NSString stringWithFormat:@"ios;%@;%@;%@;%@",system,device,appVersion,bundleBuildVersion];
}

+ (NSString *)bundleStatisticVersion
{
    return [AppUtils bundleAppVersion];
}

static NSString * _gPlatformString = @"";
+ (void)setupPlatformString:(NSString *)platformString
{
    _gPlatformString = platformString;
}

+ (NSString *)platformString
{
    static NSString * const KiwiBundleID = @"com.yy.kiwi";
    static NSString * const KiwiEnterpriseBundleID = @"com.huya.enterprise.kiwi";
    static NSString * const KiwiHDBundleID = @"com.yy.kiwihd";
    static NSString * const KiwiHDEnterpriseBundleID = @"com.huya.enterprise.kiwihd";
    static NSString * const iOSPlatform = @"ios";
    static NSString * const iPadPlatform = @"ipad";
    
    if ([_gPlatformString length] > 0){
        return _gPlatformString;
    }
    
    NSString* bundleId = [AppUtils bundleIdentifier];
    if ([bundleId isEqualToString:KiwiBundleID]){
        return iOSPlatform;
    } else if ([bundleId isEqualToString:KiwiHDBundleID]) {
        return iPadPlatform;
    } else if ([bundleId isEqualToString:KiwiEnterpriseBundleID]){
        return iOSPlatform;
    } else if ([bundleId isEqualToString:KiwiHDEnterpriseBundleID]){
        return iPadPlatform;
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            return iOSPlatform;
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return iPadPlatform;
        } else {
            KWSLogInfo(@"platformString return empty");
            NSAssert(NO, @"platformString return empty");
            return @"";
        }
    }
}

#pragma mark url

+ (BOOL)openURL:(NSString *)url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    if (!ret) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:L(@"CouldNotOpen")
                                                            message:url
                                                           delegate:nil
                                                  cancelButtonTitle:L(@"Cancel")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    return ret;
}

#pragma mark lang

+ (NSString *)currentLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* curLang = [languages objectAtIndex:0];
    
    return curLang;
}

#pragma mark - device

+ (BOOL)isCameraAvailable
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        
        return YES;
        
    } else {
        
        NSString *message = [NSString stringWithFormat:L(@"CameraPermissionTip"), [AppUtils bundleDisplayName]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:L(@"OK") otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

+ (BOOL)isAssetsLibraryAvailable
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusAuthorized || authStatus == ALAuthorizationStatusNotDetermined) {
        return YES;
    } else {
        
        NSString *message = [NSString stringWithFormat:L(@"AlbumPermissionTip"), [AppUtils bundleDisplayName]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:L(@"OK") otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

+ (ALAssetsLibrary *)assetsLibrary
{
    static ALAssetsLibrary *library = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    
    return library;
}

+ (BOOL)lastTriggerDateOfObject:(id)obj greatThanInterval:(NSTimeInterval)interval
{
    if (!obj) {
        KWSLogInfo(@"[Kiwi: AppUtils] lastTriggerDateOfObject:greatThanInterval: obj is nil, return YES");
        return YES;
    }
    
    static NSMapTable *mapTable = nil;
    
    if (!mapTable) {
        mapTable = [NSMapTable weakToStrongObjectsMapTable];
    }
    
    NSDate *date = [mapTable objectForKey:obj];
    
    if (!date || fabs([date timeIntervalSinceNow]) > interval) {
        //之前没记录，或者时间间隔已大于interval，更新为当前时间
        [mapTable setObject:[NSDate date] forKey:obj];
        return YES;
    } else {
        return NO;
    }
}

+ (int)randomIntBetween1And50ForSubSid:(uint32_t)subSid
{
    //使用NSCache保证对应同一subSid多次取出的随机数是一样的
    static NSCache *randomIntCache = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        randomIntCache = [[NSCache alloc] init];
    });
    
    if ([randomIntCache objectForKey:NSStringFromUInt32(subSid)]) {
        return [[randomIntCache objectForKey:NSStringFromUInt32(subSid)] intValue];
    }
    
    
    int random = arc4random_uniform(51);
    
    if (random == 0) {
        random = 1;
    }
    
    [randomIntCache setObject:@(random) forKey:NSStringFromUInt32(subSid)];
    
    return random;
}

+ (void)clearCookie:(NSString*)domain
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain rangeOfString:domain].location != NSNotFound) {
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (uint32_t)hashCodeForString:(NSString *)string
{
    uint32_t hash = 0;
    NSUInteger length = [string length];
    for (NSUInteger i = 0; i < length; ++i) {
        hash = 31 * hash + [string characterAtIndex:i];
    }
    return hash;
}

+ (BOOL)isUserNotificationEnabled
{
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)appInfoForLog
{
    return [NSString stringWithFormat:@"Bundle: %@, AppVer: %@, Beta:%@, SysVer: %@, DeviceName: %@, DeviceModel: %@, Network: %@, Jailbroken: %d, Locale: %@, AppState: %lld", [AppUtils bundleIdentifier], [AppUtils bundleFullVersion],[VersionHelper isBeta]? @"YES":@"NO" ,[AppDeviceUtils deviceSystemVersion], [AppDeviceUtils deviceUserName], [AppDeviceUtils deviceModelName], [[NetworkManager sharedObject] networkInfoDescription], [AppUtils isJailbroken], [NSLocale currentLocale].localeIdentifier, (long long)[[UIApplication sharedApplication] applicationState]];
}

+ (void)dumpAppInfo
{
    KWSLogInfo(@"{App} %@", [AppUtils appInfoForLog]);
}

+ (BOOL)isJailbroken
{
    static NSNumber *jailbroken = nil;
    static dispatch_once_t jailToken;
    
    dispatch_once(&jailToken, ^{
        jailbroken = @([AppUtils getJailbrokenResult]);
    });
    
    return [jailbroken boolValue];
}

+ (BOOL)getJailbrokenResult
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    FILE *file = fopen("/Applications/Cydia.app", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    
    file = fopen("/bin/bash", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/usr/sbin/sshd", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/etc/apt", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    file = fopen("/usr/bin/ssh", "r");
    if (file) {
        fclose(file);
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@"/Applications/Cydia.app"]) {
        return YES;
    }
    else if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return YES;
    }
    else if ([fileManager fileExistsAtPath:@"/bin/bash"]) {
        return YES;
    }
    else if ([fileManager fileExistsAtPath:@"/usr/sbin/sshd"]) {
        return YES;
    }
    else if ([fileManager fileExistsAtPath:@"/etc/apt"]) {
        return YES;
    }
    else if ([fileManager fileExistsAtPath:@"/usr/bin/ssh"]) {
        return YES;
    }
    
    // Omit logic below since they show warnings in the device log on iOS 9 devices.
    if (NSFoundationVersionNumber > 1144.17) {// NSFoundationVersionNumber_iOS_8_4
        return NO;
    }
    
    // Check if the app can access outside of its sandbox
    NSError *error = nil;
    NSString *string = @".";
    [string writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        return YES;
    }
    else {
        [fileManager removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    
    // Check if the app can open a Cydia's URL scheme
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]) {
        return YES;
    }
#endif
    
    return NO;
}

+ (int64_t)processStartTimestamp
{
    pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
    struct kinfo_proc proc;
    size_t size = sizeof(proc);
    sysctl(mib, 4, &proc, &size, NULL, 0);
    int64_t sec = proc.kp_proc.p_starttime.tv_sec;
    int64_t usec = proc.kp_proc.p_starttime.tv_usec;
    return sec * 1000 + usec / 1000;
}

@end
