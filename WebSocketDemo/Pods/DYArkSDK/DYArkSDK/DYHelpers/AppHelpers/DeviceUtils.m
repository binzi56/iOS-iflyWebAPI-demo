//
//  DeviceUtils.m
//  KiwiSDK
//
//  Created by Gideon on 2017/11/24.
//  Copyright © 2017年 YY.Inc. All rights reserved.
//

#import "DeviceUtils.h"

@implementation DeviceUtils

+ (NSString *)uniqueDeviceId
{
    static NSString *deviceId = nil;
    
    if ([deviceId length] > 0) {
        return deviceId;
    }
    
    NSUUID *idfv = [[UIDevice currentDevice] identifierForVendor];
    if (idfv == nil) {
        return @"";
    }
    NSString *uuid = [idfv UUIDString];
    if (uuid == nil) {
        return @"";
    }
    deviceId = uuid;
    
    return deviceId;
}

@end
