//
//  NetworkManager.h
//  Kiwi
//
//  Created by lslin on 14-6-6.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import "KiwiReachability.h"

typedef NS_ENUM(NSUInteger, KiwiNetworkCode) {
    KiwiNetworkCodeUnknown = 0,
    KiwiNetworkCodeChinaMobile,
    KiwiNetworkCodeChinaUnion,
    KiwiNetworkCodeChinaTelecon,
    KiwiNetworkCodeChinaTietong
};

typedef NS_ENUM(NSUInteger, KiwiNetworkAccessTechValue) {
    KiwiNetworkAccessTechUnknown = 0,
    KiwiNetworkAccessTechGPRS,
    KiwiNetworkAccessTechEdge,
    KiwiNetworkAccessTechWCDMA,
    KiwiNetworkAccessTechHSDPA,
    KiwiNetworkAccessTechHSUPA,
    KiwiNetworkAccessTechCDMA1x,
    KiwiNetworkAccessTechCDMAEVDORev0,
    KiwiNetworkAccessTechCDMAEVDORevA,
    KiwiNetworkAccessTechCDMAEVDORevB,
    KiwiNetworkAccessTechHRPD,
    KiwiNetworkAccessTechLTE
};

/**
 * 网络状态变化的通知
 *
 * 字典参数:
 * @li 键值: @ref kUserInfoNetworkStatus
 *     类型: NSNumber
 *     取值: @ref NetworkStatus
 */
extern NSString * const kNotificationNetworkStatusChanged;
extern NSString * const kUserInfoNetworkStatus;

/*
 wifi ssid 变更通知
 */
extern NSString * const kNotificationWiFiSSIDChanged;
extern NSString * const kUserInfoWiFiSSID;

/**
 * 用来获取当前网络状态的类. 通过属性@ref networkState 可以查询到当前的网络状态，另外网络状态的变化
 * 会通过@ref NetworkStateNotification 主动通知出来
 */
@interface NetworkManager : NSObject

@property (readonly) KiwiNetworkStatus networkStatus; /**< 当前网络状态 */
@property (readonly) BOOL isWiFi; /**< 是否WiFi连接 */
@property (readonly) BOOL isWWAN; /**< 是否3G/4G/GPRS连接 */

@property (readonly) BOOL is2G;
@property (readonly) BOOL is3G;
@property (readonly) BOOL is4G;

/**
 * 获取NetworkManager的单例对象
 * @return 返回单例对象
 */
+ (NetworkManager *)sharedObject;

- (NSString *)WiFiSSID;

- (NSString *)networkInfoDescription;

/**
 友盟统计埋点上传网络类型
 
 @return  1:wifi；2:4G；3:3G；4:无网
 */
- (NSString *)networkInfoNumberString;

- (NSString*)netWorkStatusString;

- (BOOL)isReachable;

- (KiwiNetworkCode)networkCode;//上报使用，非4G会返回未知
- (KiwiNetworkCode)mobileNetworkCode;//直接获取本机运营商信息，没有网络判断，业务层应该使用这个接口

- (NSString *)networkCodeString;//上报使用，非4G会返回未知

- (NSString *)networkTypeString;/**< 上报使用，"None, 2G, 3G, 4G, WiFi" */

- (KiwiNetworkAccessTechValue)networkAccessTechValue;

- (NSString *)networkAccessTechValueString;

- (KiwiNetworkStatus)syncCurrentNetworkStatus;

@end
