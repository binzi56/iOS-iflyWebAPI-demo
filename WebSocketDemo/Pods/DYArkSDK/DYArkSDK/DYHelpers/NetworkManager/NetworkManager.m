//
//  NetworkManager.m
//  Kiwi
//
//  Created by lslin on 14-6-6.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import "NetworkManager.h"
#import "KiwiSDKMacro.h"
#import <notify_keys.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>

NSString * const kNotificationNetworkStatusChanged = @"kNotificationNetworkStatusChanged";
NSString * const kUserInfoNetworkStatus = @"kUserInfoNetworkStatus";

NSString * const kNotificationWiFiSSIDChanged = @"kNotificationWiFiSSIDChanged";
NSString * const kUserInfoWiFiSSID = @"kUserInfoWiFiSSID";

static void onNotifySCNetworkChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

@interface NetworkManager()

@property (nonatomic, strong) KiwiReachability *reachability;
@property (nonatomic, strong) NSString *ssid;

@end

@implementation NetworkManager

static NetworkManager *_networkModelInstance = nil;

+ (NetworkManager *)sharedObject
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkModelInstance = [[NetworkManager alloc] init];
    });
    return _networkModelInstance;
}

- (void)dealloc
{
    [_reachability stopNotifier];
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self));
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKiwiReachabilityChangedNotification object:nil];
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onReachabilityChanged:)
                                                     name:kKiwiReachabilityChangedNotification
                                                   object:nil];
        [self addWiFiSSIDChangeNotification];
        
        _reachability = [KiwiReachability reachabilityForInternetConnection];//[Reachability reachabilityWithHostName:@"www.baidu.com"];
        [_reachability startNotifier];
        [self updateWiFiSSID];
    }
    return self;
}

#pragma mark - public

- (KiwiNetworkStatus)networkStatus
{
    return [_reachability currentReachabilityStatus];
}

- (KiwiNetworkStatus)syncCurrentNetworkStatus
{
    return [_reachability syncCurrentReachabilityStatus];
}

- (BOOL)isWiFi
{
    return [_reachability currentReachabilityStatus] == KiwiNetworkStatusReachableViaWiFi;
}

- (BOOL)isWWAN
{
    return [_reachability currentReachabilityStatus] == KiwiNetworkStatusReachableViaWWAN;
}

- (BOOL)is2G
{
    KiwiNetworkAccessTechValue value = [self networkAccessTechValue];
    return value == KiwiNetworkAccessTechEdge || value == KiwiNetworkAccessTechGPRS;
}

- (BOOL)is3G
{
    KiwiNetworkAccessTechValue value = [self networkAccessTechValue];
    return (value != KiwiNetworkAccessTechUnknown)
    && (value != KiwiNetworkAccessTechLTE)
    && (value != KiwiNetworkAccessTechGPRS)
    && (value != KiwiNetworkAccessTechEdge);
}

- (BOOL)is4G
{
    KiwiNetworkAccessTechValue value = [self networkAccessTechValue];
    return value == KiwiNetworkAccessTechLTE;
}

- (NSString *)WiFiSSID
{
    return self.ssid;
}

- (NSString *)networkInfoNumberString
{
    NSString *resultNumStr = @"";
    
    KiwiNetworkStatus status = [self networkStatus];
    if (status == KiwiNetworkStatusReachableViaWiFi){
        //        resultVal = @"Wifi";
        resultNumStr = @"1";
    }
    else if (status == KiwiNetworkStatusReachableViaWWAN){
        resultNumStr = [NetworkManager sharedObject].networkCodeString;
        if ([NetworkManager sharedObject].is2G){
            resultNumStr = @"3";
        }
        else if ([NetworkManager sharedObject].is4G){
            resultNumStr = @"2";
        }
        else{
            resultNumStr = @"3";
        }
    }
    else{
        resultNumStr = @"4";
    }
    return resultNumStr;
}

- (NSString *)networkInfoDescription
{
    NSString *resultVal = @"";
    
    KiwiNetworkStatus status = [self networkStatus];
    if (status == KiwiNetworkStatusReachableViaWiFi){
        resultVal = @"Wifi";
    }
    else if (status == KiwiNetworkStatusReachableViaWWAN){
        resultVal = [NetworkManager sharedObject].networkCodeString;
        if ([NetworkManager sharedObject].is2G){
            resultVal = [NSString stringWithFormat:@"%@: 2G", resultVal];
        }
        else if ([NetworkManager sharedObject].is4G){
            resultVal = [NSString stringWithFormat:@"%@: 4G", resultVal];
        }
        else{
            resultVal = [NSString stringWithFormat:@"%@: 3G", resultVal];
        }
    }
    else{
        resultVal = @"No Network!";
    }
    return resultVal;
}

- (NSString*)netWorkStatusString
{
    switch (self.networkStatus) {
        case KiwiNetworkStatusNone:
        case KiwiNetworkStatusNotReachable:
            return @"KiwiNetworkStatusNotReachable";
        case KiwiNetworkStatusReachableViaWiFi:
            return @"KiwiNetworkStatusReachableViaWiFi";
        case KiwiNetworkStatusReachableViaWWAN:
            return @"KiwiNetworkStatusReachableViaWWAN";
        default:
            break;
    }
}

- (BOOL)isReachable
{
    return self.networkStatus == KiwiNetworkStatusReachableViaWiFi || self.networkStatus == KiwiNetworkStatusReachableViaWWAN;
}

// 参考 : https://en.wikipedia.org/wiki/Mobile_country_code
- (KiwiNetworkCode)networkCode
{
    if (self.networkStatus != KiwiNetworkStatusReachableViaWWAN) {
        return KiwiNetworkCodeUnknown;
    }
    
    return [self mobileNetworkCode];
}

- (KiwiNetworkCode)mobileNetworkCode
{
    CTTelephonyNetworkInfo* info = [CTTelephonyNetworkInfo new];
    CTCarrier* carrier = [info subscriberCellularProvider];
    
    if (carrier == nil) {
        KWSLogInfo(@"CTCarrier is nil");
        return KiwiNetworkCodeUnknown;
    }
    
    NSString* code = [carrier mobileNetworkCode];
    NSString* name = [carrier carrierName];
    KWSLogInfo(@"get CTCarrier sucess, code = %@, name = %@",code,name);
    
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"] || [code isEqualToString:@"08"]) {
        return KiwiNetworkCodeChinaMobile;
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"] || [code isEqualToString:@"09"]) {
        return KiwiNetworkCodeChinaUnion;
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"] || [code isEqualToString:@"11"]) {
        return KiwiNetworkCodeChinaTelecon;
    } else if ([code isEqualToString:@"20"]) {
        return KiwiNetworkCodeChinaTietong;
    } else {
        return KiwiNetworkCodeUnknown;
    }
}

- (NSString *)networkCodeString
{
    KiwiNetworkCode code = [self networkCode];
    NSString *codeString = self.networkStatus == KiwiNetworkStatusReachableViaWiFi ? @"wifi" : @"";
    
    switch (code) {
        case KiwiNetworkCodeChinaMobile:
            codeString = @"中国移动";
            break;
        case KiwiNetworkCodeChinaUnion:
            codeString = @"中国联通";
            break;
        case KiwiNetworkCodeChinaTelecon:
            codeString = @"中国电信";
            break;
        case KiwiNetworkCodeChinaTietong:
            codeString = @"中国铁通";
            break;
        default:
            break;
    }
    
    return codeString;
}

- (NSString *)networkTypeString
{
    NSString *resultVal = @"None";
    
    KiwiNetworkStatus status = [self networkStatus];
    if (status == KiwiNetworkStatusReachableViaWiFi){
        resultVal = @"WiFi";
    } else if (status == KiwiNetworkStatusReachableViaWWAN){
        if ([NetworkManager sharedObject].is2G){
            resultVal = @"2G";
        }
        else if ([NetworkManager sharedObject].is4G){
            resultVal = @"4G";
        }
        else{
            resultVal = @"3G";
        }
    }
    return resultVal;
}

- (KiwiNetworkAccessTechValue)networkAccessTechValue
{
    //todo:hjm
    if (self.networkStatus != KiwiNetworkStatusReachableViaWWAN){
        return KiwiNetworkAccessTechUnknown;
    }
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *networkAccessTechValue = [networkInfo currentRadioAccessTechnology];
    
    if (!networkAccessTechValue){
        return KiwiNetworkAccessTechUnknown;
    }
    
    //按照占有率从高到低
    if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyLTE]){
        return KiwiNetworkAccessTechLTE;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyWCDMA]){
        return KiwiNetworkAccessTechWCDMA;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyEdge]){
        return KiwiNetworkAccessTechEdge;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyGPRS]){
        return KiwiNetworkAccessTechGPRS;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyHSDPA]){
        return KiwiNetworkAccessTechHSDPA;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyHSUPA]){
        return KiwiNetworkAccessTechHSUPA;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyCDMA1x]){
        return KiwiNetworkAccessTechCDMA1x;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
        return KiwiNetworkAccessTechCDMAEVDORev0;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
        return KiwiNetworkAccessTechCDMAEVDORevA;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
        return KiwiNetworkAccessTechCDMAEVDORevB;
    }
    else if ([networkAccessTechValue isEqualToString:CTRadioAccessTechnologyeHRPD]){
        return KiwiNetworkAccessTechHRPD;
    }
    else{
        return KiwiNetworkAccessTechUnknown;
    }
}

- (NSString *)networkAccessTechValueString
{
    KiwiNetworkAccessTechValue value = [self networkAccessTechValue];
    NSString *valueString = @"";
    
    switch (value) {
        case KiwiNetworkAccessTechGPRS:
            valueString = @"GPRS";
            break;
        case KiwiNetworkAccessTechEdge:
            valueString = @"Edge";
            break;
        case KiwiNetworkAccessTechWCDMA:
            valueString = @"WCDMA";
            break;
        case KiwiNetworkAccessTechHSDPA:
            valueString = @"HSDPA";
            break;
        case KiwiNetworkAccessTechHSUPA:
            valueString = @"HSUPA";
            break;
        case KiwiNetworkAccessTechCDMA1x:
            valueString = @"CDMA1x";
            break;
        case KiwiNetworkAccessTechCDMAEVDORev0:
            valueString = @"CDMAEVDORev0";
            break;
        case KiwiNetworkAccessTechCDMAEVDORevA:
            valueString = @"CDMAEVDORevA";
            break;
        case KiwiNetworkAccessTechCDMAEVDORevB:
            valueString = @"CDMAEVDORevB";
            break;
        case KiwiNetworkAccessTechHRPD:
            valueString = @"HRPD";
            break;
        case KiwiNetworkAccessTechLTE:
            valueString = @"LTE";
            break;
        default:
            break;
    }
    return valueString;
}


#pragma mark - Notification

- (void)addWiFiSSIDChangeNotification
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onNotifySCNetworkChange,
                                    CFSTR(kNotifySCNetworkChange),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
}

- (void)onReachabilityChanged:(NSNotification *)notification
{
    KiwiReachability* curReach = [notification object];
    [self postNetworkStatusChangedNotification:curReach];
}

- (void)postNetworkStatusChangedNotification:(KiwiReachability *)reach
{
    KiwiNetworkStatus status = [reach currentReachabilityStatus];
    NSDictionary *userInfo = @{kUserInfoNetworkStatus : @(status)};
    
    KWSLogInfo(@"[Kiwi:NetworkManager] Network status: %u", status);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkStatusChanged object:nil userInfo:userInfo];
}

#pragma mark - Private

- (void)updateWiFiSSID
{
    NSString *ssid = nil;
    NSArray *interFaceNames = (__bridge_transfer id)(CNCopySupportedInterfaces());
    for (NSString *name in interFaceNames) {
        NSDictionary *info = (__bridge_transfer id)(CNCopyCurrentNetworkInfo((__bridge CFStringRef)name));
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    KWSLogInfo(@"SSID %@", ssid);
    
    if (![_ssid isEqualToString:ssid]) {
        self.ssid = ssid;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:ssid, kUserInfoWiFiSSID, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWiFiSSIDChanged object:nil userInfo:userInfo];
    }
}

@end

static void onNotifySCNetworkChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString* notifyName = (__bridge NSString*)name;
    if ([notifyName isEqualToString:(__bridge NSString *)CFSTR(kNotifySCNetworkChange)]) {
        KWSLogInfo(@"");
        //kNotifySCNetworkChange通知会一下子来很多次，先延时处理，避免频繁更新ssid
        [NSObject cancelPreviousPerformRequestsWithTarget:[NetworkManager sharedObject] selector:@selector(updateWiFiSSID) object:nil];
        [[NetworkManager sharedObject] performSelector:@selector(updateWiFiSSID) withObject:nil afterDelay:1.0];
    }
}
