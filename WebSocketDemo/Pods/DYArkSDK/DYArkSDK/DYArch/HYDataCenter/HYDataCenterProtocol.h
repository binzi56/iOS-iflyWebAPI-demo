//
//  HYDataCenterProtocol.h
//  kiwi
//
//  Created by liyipeng on 2017/1/3.
//  Copyright © 2017年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDataCenterRequest.h"
#import "IHYService.h"

static const uint32_t kCommonPageStartIndex = 0;      //直播模块分页加载起始页
static const uint32_t kHuyaMobileAPIPageStartIndex = 1;//2015.2月份改版后直播分类分页加载起始页

@class NetworkServiceError;
/**
 * 通用模块的分页个数，iPhone 15，iPad 30
 */
#define CommonPageSize ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 15 : 30)

extern NSString * const HYDataCenterDomain;

typedef NS_ENUM(NSInteger, HYDataCenterCode) {
    HYDataCenterSuccess,
    HYDataCenterNoCacheKey,         /**< 读缓存，但是没有对应的key*/
    HYDataCenterNoRequestProxy,     /**< 没有对应的网络通道*/
};

typedef NS_ENUM(NSUInteger, HYDataCenterStrategy) {
    HYDataCenterStrategyNetOnly,
    HYDataCenterStrategyNetThenCache,           /**< 先网络，如果网络失败，则使用缓存*/
    HYDataCenterStrategyCacheOnly,
    HYDataCenterStrategyCacheThenNet,           /**< 先缓存，后请求网络，可能有两次回调*/
    HYDataCenterStrategyCacheThenNetIfNoCache   /**< 先缓存，如果没有缓存则请求网络，只有一次回调*/
};

typedef void(^DataCenterCompletionBlock)(id rsp, BOOL fromCache, NetworkServiceError *error);
typedef void(^DataCenterResponseCompletion)(id rsp, NetworkServiceError *error);

#pragma mark -

@protocol IHYDataCenterService <IWFService>

//setup default proxys
- (void)setupWupRequestProxy:(id<IWFDataCenterRequestProxy>) wupRequestProxy;
- (void)setupSignalWupRequestProxy:(id<IWFDataCenterRequestProxy>) wupRequestProxy;
- (void)setupUrlRequestProxy:(id<IWFDataCenterRequestProxy>) urlRequestProxy;

- (void)setupCacheProxy:(id<IHYDataCenterCacheProxy>) cacheProxy;

- (void)updateRequestConfig:(NSDictionary *)config;

/**
 数据中心取数据接口
 @param request @ref WFDataCenterRequest
 @param strategy @ref HYDataCenterStrategy
 */
- (void)sendRequest:(WFDataCenterRequest *)request
           strategy:(HYDataCenterStrategy)strategy
         completion:(DataCenterCompletionBlock)completion;

/**
 数据中心同步读取缓存
 @param request
 */
- (id)objectForRequest:(WFDataCenterRequest *)request;

/**
 数据中心缓存数据
 @param object
 @param request
 */
- (void)setObject:(id)object forRequest:(WFDataCenterRequest *)request;

- (void)removeObjectForRequest:(WFDataCenterRequest *)request;

/**
 数据中心同步读取缓存
 @param key
 */
- (id)objectForKey:(NSString *)key;

/**
 数据中心缓存数据
 @param object
 @param key
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 移除缓存
 @param key
 */
- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObject;


/**
 过滤wup中特殊字符。ref defaultValidateProperties 中有需要过滤默认字段；在wupProperties中可以指定自定义字段。
 @param object wup或者集合
 @param wupProperties 需要过滤的字段
 */
- (void)validateObject:(id)object withWupProperties:(NSArray *)wupProperties;

@end


@protocol IWFDataCenterRequestProxy <NSObject>

- (void)sendRequest:(WFDataCenterRequest *)request completion:(DataCenterResponseCompletion)completion;

@end

@protocol IHYDataCenterCacheProxy <NSObject>

- (id)huyaObjectForKey:(NSString *)key;

- (void)huyaSetObject:(id)object forKey:(NSString *)key;

- (void)huyaRemoveObjectForKey:(NSString *)key;

- (void)huyaRemoveAllObjects;

- (CFAbsoluteTime)cachedTimeForObject:(id)object;

- (void)saveCachedTime:(CFAbsoluteTime)cachedTime forObject:(id)object;

@end

