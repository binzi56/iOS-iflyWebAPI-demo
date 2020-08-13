//
//  NetWorkUtils.h
//  KiwiSDK
//
//  Created by pengfeihuang on 16/6/7.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NetWorkUtilsDomain;

typedef NS_ENUM(int32_t, NetWorkUtilsError) {
    NetWorkUtilsErrorNoNetwork = -99999
};

@interface NetWorkUtils : NSObject

+ (BOOL)networkReachableNeedAlert;

+ (BOOL)networkReachable;

/**
 当前网络错误，如果有网络，则返回nil
 */
+ (NSError *)currentError;

//获取私网ip
//可以获取 4G 和 WiFi 2种情况下的私网ip
+ (NSString *)getLocalIPAddress:(BOOL)preferIPv4;

@end



@interface NSError (NetWorkUtils)

- (BOOL)isNetworkUtilsError;

@end
