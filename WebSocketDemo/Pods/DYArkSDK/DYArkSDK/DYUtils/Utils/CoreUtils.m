//
//  CoreUtils.m
//  yysdk
//
//  Created by 王 金华 on 12-9-7.
//  Copyright (c) 2012年 com.mewe.party. All rights reserved.
//

#import "CoreUtils.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <netinet/in.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <errno.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <ifaddrs.h>
#import <sys/utsname.h>

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NSArray+DY.h"

#if !defined(IFT_ETHER)
#define IFT_ETHER 0x6
#endif

@implementation TagContent

@end

@implementation CoreUtils

+ (NSString *)getMacAddress
{
    static NSMutableString *macAddress = nil;
    
    if ([macAddress length] > 0) {
        return macAddress;
    }
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSInteger systemMainVersion = [[currentDevice systemVersion] integerValue];
    if ( systemMainVersion < 6 )
    {
        do
        {
            struct ifaddrs* addrs;
            if ( getifaddrs( &addrs ) )
                break;
            
            const struct ifaddrs *cursor = addrs;
            while ( cursor )
            {
                if ( ( cursor->ifa_addr->sa_family == AF_LINK )
                    && strcmp( "en0",  cursor->ifa_name ) == 0
                    && ( ( ( const struct sockaddr_dl * )cursor->ifa_addr)->sdl_type == IFT_ETHER ) )
                {
                    const struct sockaddr_dl *dlAddr = ( const struct sockaddr_dl * )cursor->ifa_addr;
                    const uint8_t *base = ( const uint8_t * )&dlAddr->sdl_data[dlAddr->sdl_nlen];
                   
                    macAddress = [[NSMutableString alloc] initWithCapacity:64];
                    
                    for ( int i = 0; i < dlAddr->sdl_alen; i++ )
                    {
                        [macAddress appendFormat:@"%02x", base[i]];
                    }
                    
                    break;
                }
                cursor = cursor->ifa_next;
            }
            freeifaddrs(addrs);
        } while (NO);
    }
    else
    {
        do {
            NSUUID *uuid = [currentDevice identifierForVendor];
            if (uuid == nil) {
                break;
            }
            NSString *uuidStr = [uuid UUIDString];
            if (uuidStr == nil) {
                break;
            }
            macAddress = [NSMutableString stringWithFormat:@"%@", uuidStr];
            
        } while (false);
    }
    
    if (macAddress == nil) {
        macAddress = [NSMutableString stringWithString:@""];
    }
    
    return macAddress;
}

+ (NSString *)readPList:(NSString *)plistFileName valueForKey:(NSString *)key
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"];
    NSMutableDictionary *array=[NSMutableDictionary dictionaryWithContentsOfFile:path];
    return [array objectForKey:key];
}

+ (NSString *)getAppIdentifier
{
    static NSString *appIdentifier;
    
    if (!appIdentifier) {
        appIdentifier = [CoreUtils readPList:@"Info" valueForKey:@"CFBundleIdentifier"];
        if (!appIdentifier) {
            appIdentifier = @"";
            //WFLogError(@"Failed to read App Identifier, please check your plist file");
        }
    }
    
    return appIdentifier;
}

+ (NSString *)getAppVersion
{
    static NSString *appVersion;
    
    if (!appVersion) {
        appVersion = [CoreUtils readPList:@"Info" valueForKey:@"CFBundleShortVersionString"];
        if (!appVersion) {
            appVersion = @"";
            //WFLogError(@"Failed to read App version, please check your plist file");
        }
    }
    
    return appVersion;
}

+ (NSArray *)extractContentsBetweenTags:(NSString *)sourceString openingTag:(NSString *)openingTag closingTag:(NSString *)closingTag
{
    if (![sourceString length] || ![openingTag length] || ![closingTag length])
        return nil;

    NSMutableArray *contentList = [[NSMutableArray alloc] init];
    NSUInteger sourceStringLength = [sourceString length];
    
    NSRange openingTagRange = [sourceString rangeOfString:openingTag options:NSLiteralSearch];
    while (NSNotFound != openingTagRange.location) {
        int openingTagCount = 1;
        NSRange searchingRange = NSMakeRange(NSMaxRange(openingTagRange), sourceStringLength - NSMaxRange(openingTagRange));
        NSRange closeingTagRange = NSMakeRange(NSNotFound, 0);
        
        while (openingTagCount > 0) {
            closeingTagRange = [sourceString rangeOfString:closingTag options:NSLiteralSearch range:searchingRange];
            if (NSNotFound == closeingTagRange.location)
                break;
            
            NSRange anotherOpeningTagRange = [sourceString rangeOfString:openingTag options:NSLiteralSearch range:searchingRange];
            if ((NSNotFound != anotherOpeningTagRange.location) && (anotherOpeningTagRange.location < closeingTagRange.location)) {
                openingTagCount ++;
                searchingRange = NSMakeRange(NSMaxRange(anotherOpeningTagRange), sourceStringLength - NSMaxRange(anotherOpeningTagRange));
            } else {
                openingTagCount --;
            }
        }
        
        if (NSNotFound == closeingTagRange.location)
            break;
        
        TagContent *content = [[TagContent alloc] init];
        content.range = NSMakeRange(openingTagRange.location, NSMaxRange(closeingTagRange) - openingTagRange.location);
        NSRange contentRange = NSMakeRange(NSMaxRange(openingTagRange), closeingTagRange.location - NSMaxRange(openingTagRange));
        content.content = [sourceString substringWithRange:contentRange];
        [contentList addObject:content];
        NSRange remainedRange = NSMakeRange(NSMaxRange(closeingTagRange), sourceStringLength - NSMaxRange(closeingTagRange));
        openingTagRange = [sourceString rangeOfString:openingTag options:NSLiteralSearch range:remainedRange];
    }
    
    if ([contentList count] > 0) {
        return contentList;
    } else {
        return nil;
    }
}

+ (NSString *)getCarrierName
{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* sp = [networkInfo subscriberCellularProvider];
    return [sp carrierName];
}

+ (NSString*)SPCode
{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* sp = [networkInfo subscriberCellularProvider];
    return [sp mobileNetworkCode];
}

+ (NSString*)CountryCode
{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* sp = [networkInfo subscriberCellularProvider];
    return [sp mobileCountryCode];
}

+ (CarrierType)getCarrierType
{
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* sp = [networkInfo subscriberCellularProvider];
    
    NSString *carrierName = [sp carrierName];
    if (!carrierName)
        return CARRIER_UNKNOWN;
    
	if ([carrierName rangeOfString:@"联通"].location != NSNotFound)
        return CARRIER_UNICOM;
    
    if ([carrierName rangeOfString:@"移动"].location != NSNotFound)
        return CARRIER_CMCC;
    
    if ([carrierName rangeOfString:@"电信"].location != NSNotFound)
        return CARRIER_CTL;
    
    NSString* countryCode = [sp mobileCountryCode];
    NSString* spCode = [sp mobileNetworkCode];
    
    if (countryCode == nil || spCode == nil)
        return CARRIER_UNKNOWN;
    
    if ([countryCode rangeOfString:@"460"].location == NSNotFound)
        return CARRIER_UNKNOWN;
    
    if ([spCode rangeOfString:@"01"].location != NSNotFound
        || [spCode rangeOfString:@"06"].location != NSNotFound)
        return CARRIER_UNICOM;
    
    if ([spCode rangeOfString:@"00"].location != NSNotFound
        || [spCode rangeOfString:@"02"].location != NSNotFound
        || [spCode rangeOfString:@"07"].location != NSNotFound)
        return CARRIER_CMCC;

    if ([spCode rangeOfString:@"03"].location != NSNotFound
        || [spCode rangeOfString:@"05"].location != NSNotFound)
        return CARRIER_CTL;
    
    return CARRIER_UNKNOWN;
}

+ (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *originalModel = [NSString stringWithCString:systemInfo.machine
                                                 encoding:NSUTF8StringEncoding];
    return [originalModel stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

+ (NSString *)getOSVersion
{
    UIDevice *device = [UIDevice currentDevice];
    return device.systemVersion;
}

+ (int64_t)convertVersionToInt:(NSString *)ver {
    if (ver == nil ) {
        return 0;
    }
    
    NSArray* component = [ver componentsSeparatedByString:@"."];
    int64_t retValue = 0;
    if ([component count] == 3 ) {
        int i1 = [[component safeObjectAtIndex:0] intValue];
        int i2 = [[component safeObjectAtIndex:1] intValue];
        int i3 = [[component safeObjectAtIndex:2] intValue];
        NSString* intStr = [NSString stringWithFormat:@"%d%06d%06d",i1,i2,i3];
        retValue = [intStr longLongValue];
    }
    
    return retValue;
}

+ (NSString *)findXmlTag:(NSString *)src start:(NSString *)start end:(NSString *)end {
    NSRange platformStart = [src rangeOfString:start];
    NSRange platformEnd = [src rangeOfString:end];
    if (platformStart.location == NSNotFound
        ||platformEnd.location == NSNotFound
        ) {
        return nil;
    }
    if (platformEnd.location <= platformStart.location + [start length]) {
        return nil;
    }
    
    return [src substringWithRange:NSMakeRange(platformStart.location+[start length], platformEnd.location - platformStart.location - [start length])];
}

+(NSString *)getIPWithHostName:(const NSString *)hostName
{
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    @try {
        phot = gethostbyname(hostN);
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    if (phot == NULL) {
        return @"";
    }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

@end
