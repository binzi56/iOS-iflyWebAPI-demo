//
//  AppDeviceUtils.m
//  HYCommon
//
//  Created by 刘刘智明 on 17/2/21.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "AppDeviceUtils.h"

#import "UIDevice+KWS.h"
#import "KiwiSDKMacro.h"
#import <mach/mach.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#import <sys/sysctl.h>

static bool _prevValidSent = false;
static bool _prevValidRecev = false;

int64_t _prevWiFiSent     = 0;
int64_t _prevWiFiReceived = 0;
int64_t _prevWWANSent     = 0;
int64_t _prevWWANReceived = 0;

int64_t _WiFiSent     = 0;
int64_t _WiFiReceived = 0;
int64_t _WWANSent     = 0;
int64_t _WWANReceived = 0;

double previousUpFlow = 0.0;
double previousDownFlow = 0.0;

@implementation AppDeviceUtils

+ (int)cpuCoreCount
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    return hostInfo.max_cpus;
}

+ (float)cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return 0.0f;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return 0.0f;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return 0.0f;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return (tot_cpu > 100.0f) ? 100.f : tot_cpu;
}

+ (double)currentThreadRunTime
{
    task_t port = mach_thread_self();
    struct task_thread_times_info startTime[TASK_INFO_MAX];
    mach_msg_type_number_t count = TASK_INFO_MAX;
    thread_info(port, TASK_THREAD_TIMES_INFO, (task_info_t)&startTime, &count);
    double time = ((double)(startTime->system_time.seconds+startTime->system_time.microseconds+startTime->user_time.seconds+startTime->user_time.microseconds))/NSEC_PER_MSEC;
    return time;
}

+ (double)currentThreadCpuUsage
{
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;
    
    task_t port = mach_thread_self();
    thread_info_count = THREAD_INFO_MAX;
    kern_return_t kr = thread_info(port, THREAD_BASIC_INFO,
                                   (thread_info_t)thinfo, &thread_info_count);
    if (kr != KERN_SUCCESS) {
        return 0.0f;
    }
    
    basic_info_th = (thread_basic_info_t)thinfo;
    return basic_info_th->cpu_usage;
}

+ (double)totalMemory
{
    static double totalMemory = 0;
    if (totalMemory < 1) {
        totalMemory = [[NSProcessInfo processInfo] physicalMemory] / (1024.0 * 1024.0);
    }
    return totalMemory;
}

+ (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

+ (double)totalUpStreamFlow
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int64_t WiFiSent = 0;
    int64_t WWANSent = 0;
    
    success = getifaddrs(&addrs) == 0;
    
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if (strcmp(cursor->ifa_name, "en0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                }
                if (strcmp(cursor->ifa_name, "pdp_ip0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    if (_prevValidSent == true) {
        _WiFiSent = WiFiSent - _prevWiFiSent;
        _WWANSent = WWANSent - _prevWWANSent;
        
    } else {
        //记录第一次启动监控的流量
        _prevValidSent = true;
        _prevWiFiSent = WiFiSent;
        _prevWWANSent = WWANSent;
    }
    
    return _WiFiSent / 1024.0 + _WWANSent / 1024.0;
}

+ (double)totalDownStreamFlow
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int64_t WiFiReceived = 0;
    int64_t WWANReceived = 0;
    
    success = getifaddrs(&addrs) == 0;
    
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if (strcmp(cursor->ifa_name, "en0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                if (strcmp(cursor->ifa_name, "pdp_ip0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    if (_prevValidRecev == true) {
        _WiFiReceived = WiFiReceived - _prevWiFiReceived;
        _WWANReceived = WWANReceived - _prevWWANReceived;
        
    } else {
        //记录第一次启动监控的流量
        _prevValidRecev = true;
        _prevWiFiReceived = WiFiReceived;
        _prevWWANReceived = WWANReceived;
    }
    
    return _WiFiReceived / 1024.0 + _WWANReceived / 1024.0;
}

+ (void)resetDownStreamFlow
{
    previousDownFlow = [AppDeviceUtils totalDownStreamFlow];
}

+ (void)resetUpStreamFlow
{
    previousUpFlow = [AppDeviceUtils totalUpStreamFlow];
}

+ (double)downStreamFlow
{
    return [AppDeviceUtils totalDownStreamFlow] - previousDownFlow;
}

+ (double)upStreamFlow
{
    return [AppDeviceUtils totalUpStreamFlow] - previousUpFlow;
}

#pragma mark Device

+ (NSString *)deviceSystemVersion
{
    return [[UIDevice currentDevice] hy_systemVersion];
}

+ (NSString *)deviceModelName
{
    return [[UIDevice currentDevice] machineModelName];
}

+ (NSString *)deviceModelNameWithoutSpace
{
    static NSString *name = nil;
    if (!name) {
        name = [[self deviceModelName] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    return name;
}

+ (NSString *)deviceUserName
{
    return [[UIDevice currentDevice] name];
}

+ (NSString *)getDeviceID
{
    NSString *huyaDeviceIDKey = @"HuyaDeviceID";
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:huyaDeviceIDKey];
    if (![deviceId length]) {
#warning TODO -- tobe fixed
//        deviceId = [UtilsHelper getDeviceID];
        if ([deviceId length]) {
            [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:huyaDeviceIDKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return deviceId;
}

+ (NSString *)systemBuildId
{
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [NSString stringWithUTF8String:buildBuffer];
    }
    return osBuildVersion;
}

#pragma mark - keycharin

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (id)loadKeyChain:(NSString *)chainKey
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:chainKey];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            KWSLogInfo(@"Unarchive of %@ failed: %@", chainKey, e);
        } @finally {
        }
    }
    
    if (keyData){
        CFRelease(keyData);
    }
    
    return ret;
}

+ (BOOL)addKeychain:(NSString*)chainKey data:(id)data
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:chainKey];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    return SecItemAdd((CFDictionaryRef)keychainQuery, NULL) == noErr;
}

+ (void)deleteKeychain:(NSString*)chainKey
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:chainKey];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
