//
//  AppDeviceUtils.h
//  HYCommon
//
//  Created by 刘刘智明 on 17/2/21.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDeviceUtils : NSObject

/**
 *  CPU核心数
 */
+ (int)cpuCoreCount;

/**
 *  CPU占用率
 */
+ (float)cpuUsage;

/**
 * 总内存MB
 */
+ (double)totalMemory;

/**
 * 已用的内存MB
 */
+ (double)usedMemory;

/**
 * 上行网络流量KB（清零后的）
 */
+ (double)upStreamFlow;

/**
 * 下行网络流量KB（清零后的）
 */
+ (double)downStreamFlow;

/**
 * 上行网络流量KB（总的上行流量）
 */
+ (double)totalUpStreamFlow;

/**
 * 下行网络流量KB（总的下行流量）
 */
+ (double)totalDownStreamFlow;

/**
 * 清空上行流量计数
 */
+ (void)resetDownStreamFlow;

/**
 * 清空下行流量计数
 */
+ (void)resetUpStreamFlow;

/**
 * 当前线程CPU使用率
 */
+ (double)currentThreadCpuUsage;

/**
 * 当前线程运行时间
 */
+ (double)currentThreadRunTime;

#pragma mark - Device

+ (NSString *)deviceSystemVersion;

/**
 * 设备名
 * @return "iPhone 6S"
 */
+ (NSString *)deviceModelName;

/**
 * 设备名，空格替换为"_"
 * @return "iPhone_6S"
 */
+ (NSString *)deviceModelNameWithoutSpace;

/**
 * 设备的用户定义名
 * @return "XX's iPhone"
 */
+ (NSString *)deviceUserName;

/**
 * 查询设备ID。调用hdstatsdk的函数
 * @return NSString, 有可能生成失败，返回nil。
 */
+ (NSString *)getDeviceID;

/**
 * ios系统的build id
 */
+ (NSString *)systemBuildId;

/**
 * keychain 相关
 * 读取keychain里指定key的内容
 * 向keychain里添加指定内容，data支持NSString、NSArray、NSDictionary、NSSet等可以序列化的类型
 * 在keychain里删除指定key的内容
 */
+ (id)loadKeyChain:(NSString *)chainKey;
+ (BOOL)addKeychain:(NSString*)chainKey data:(id)data;
+ (void)deleteKeychain:(NSString*)chainKey;

@end
