//
//  WFDataCenterRequest.h
//  kiwi
//
//  Created by liyipeng on 2017/1/6.
//  Copyright © 2017年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYNetworkTypes.h"

extern NSTimeInterval const kOneHourInterval;
extern NSTimeInterval const kOneDayInterval;
extern NSTimeInterval const kOneWeekInterval;

typedef NS_ENUM(NSInteger, HYWupDataChannel) {
    HYWupDataChannelHTTP         = 1,
    HYWupDataChannelHySignal
};

@protocol IHYDataCenterCacheProxy;
@protocol IWFDataCenterRequestProxy;

typedef NS_ENUM(NSUInteger, WFDataCenterRequestType) {
    WFDataCenterRequestWUP,
    WFDataCenterRequestURL,
    WFDataCenterRequestCache
};

typedef NS_ENUM(NSUInteger, WFDataCenterRequestPriority) {
    WFDataCenterRequestPriorityDefault  =0,
    WFDataCenterRequestPriorityHigh     =1,
};

@interface WFDataCenterRequest : NSObject
/**
 request WUP request, NSURLRequest
 */
@property (nonatomic, strong) id<NSObject> request;

//common
@property (nonatomic, assign) WFDataCenterRequestType requestType;

//wup
@property (nonatomic, strong) NSString *servant;
@property (nonatomic, strong) NSString *func;
@property (nonatomic, assign) int32_t maxRetryCount;
@property (nonatomic, strong) Class rspClass;
@property (nonatomic, strong) NSArray<NSString *> *shouldValidateProperties; /**< default nil*/
@property (nonatomic, assign) HYWupDataChannel dataChannel;
@property (nonatomic, strong) NSArray *timeoutIntervals;    /**< 超时时间，支持数组配置，比如首页5、10、15，代表第一次请求超时为5s， 第二次为10s，第三次为15s*/
@property (nonatomic, assign) BOOL ignoreValidatePropertyCheck; /**< 如果优先级比较高，并且可能有特殊字符的概率较低，可以设置不处理特殊字符串 */
@property (nonatomic, assign) WFDataCenterRequestPriority requestPriority; /**< 如果优先级高，则不切到 wup.send 队列发送请求 */
@property (nonatomic, assign) BOOL canCallbackInBackground;
@property (nonatomic, assign) BOOL useURLSession;

@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *functionName;
@property (nonatomic, assign) int32_t cmdid;
@property (nonatomic, assign) ChannelType channelSelect;

//cache
@property (nonatomic, strong) NSString *cacheKey;               /**< 缓存key*/
@property (nonatomic, assign) NSTimeInterval cacheDuration;    /**< 单位s 缓存过期时间，默认0，使用cacheProxy默认过期时间*/

//custom proxy
@property (nonatomic, weak) id<IHYDataCenterCacheProxy> cacheProxy;
@property (nonatomic, weak) id<IWFDataCenterRequestProxy> requestProxy;

@property (nonatomic, assign) BOOL avoidMultiCallbackIfNetworkError;  /**< 禁止多次回调，如先网络后缓存时有可能有多次回调*/

//wup请求，重试次数为1
+ (instancetype)wupRequestWithReq:(id)req
                      servantName:(NSString *)servantName
                         funcName:(NSString *)funcName
                         rspClass:(Class)rspClass;

//wup请求，重试次数为0
+ (instancetype)noRetryWupRequestWithReq:(id)req
                             servantName:(NSString *)servantName
                                funcName:(NSString *)funcName
                                rspClass:(Class)rspClass;

//普通http请求
+ (instancetype)urlRequestWithUrlString:(NSString *)urlString;

//读取缓存
+ (instancetype)requestWithCacheKey:(NSString *)cacheKey;

- (NSString *)cgi;

- (void)setNetworkRequest:(id)networkRequest;
- (void)cancel;

@end
