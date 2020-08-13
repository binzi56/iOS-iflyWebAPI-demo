//
//  HYDataCenter.m
//  kiwi
//
//  Created by liyipeng on 2017/1/3.
//  Copyright © 2017年 YY Inc. All rights reserved.
//

#import "HYDataCenter.h"
#import "KiwiSDKMacro.h"
#import <objc/message.h>
#import "NSObject+HYThread.h"
#import "HYJSONHelper.h"


static NSString * const kDataCenterConfig       = @"DataCenterConfig";
static NSString * const kAllWupRequestUseHTTP   = @"AllWupRequestUseHTTP";
static NSString * const kWupRequestUseHTTP      = @"WupRequestUseHTTP";
static NSString * const kHTTPRetryCount         = @"HTTPRetryCount";
static NSString * const kHTTPTimeout            = @"HTTPTimeout";


@interface HYDataCenter ()

@property (nonatomic, strong) id<IWFDataCenterRequestProxy> wupRequestProxy;
@property (nonatomic, strong) id<IWFDataCenterRequestProxy> signalWupRequestProxy;
@property (nonatomic, strong) id<IWFDataCenterRequestProxy> urlRequestProxy;

@property (nonatomic, strong) id<IHYDataCenterCacheProxy> cacheProxy;

@property (nonatomic, strong) NSSet<NSString*> *shouldValidateProperties;

/**
 {
 "AllWupRequestUseHTTP":1,
 "/mobileui/getMobileHomePageData2":{
 "WupRequestUseHTTP":0,
 "HTTPRetryCount":0,
 "HTTPTimeout":15}
 }
 */
@property (nonatomic, strong) NSDictionary *requestConfig;

@end

@implementation HYDataCenter

+ (instancetype)sharedObject
{
    static HYDataCenter *dataCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataCenter = [[HYDataCenter alloc] init];
    });
    return dataCenter;
}

- (NSSet<NSString*> *)shouldValidateProperties
{
    if (!_shouldValidateProperties) {
        _shouldValidateProperties = [self defaultValidateProperties];
    }
    
    return _shouldValidateProperties;
}

- (NSSet<NSString *>*)defaultValidateProperties
{
    return [NSSet setWithObjects:@"jce_sNickName",
            @"jce_sLiveDesc",
            @"jce_sSubchannelName",
            @"jce_sNick",
            @"jce_sSign",
            @"jce_sGameName",
            @"jce_sPropsName",
            @"jce_sPresenterNickName",
            @"jce_sVideoTitle",
            @"jce_sLiveIntro",
            @"jce_sTitle",
            @"jce_sSubTitle",
            @"jce_sText",   //角标
            @"jce_sName",   //标签
            nil];
}

- (void)setupWupRequestProxy:(id<IWFDataCenterRequestProxy>) wupRequestProxy
{
    self.wupRequestProxy = wupRequestProxy;
}

- (void)setupSignalWupRequestProxy:(id<IWFDataCenterRequestProxy>) wupRequestProxy
{
    self.signalWupRequestProxy = wupRequestProxy;
}

- (void)setupUrlRequestProxy:(id<IWFDataCenterRequestProxy>) urlRequestProxy
{
    self.urlRequestProxy = urlRequestProxy;
}

- (void)setupCacheProxy:(id<IHYDataCenterCacheProxy>)cacheProxy
{
    self.cacheProxy = cacheProxy;
}

- (void)updateRequestConfig:(NSDictionary *)config
{
    NSString *jsonString = [config safeStringOrNilForKey:kDataCenterConfig];
    
    if (jsonString) {
        NSDictionary *reqeustConfig = [jsonString hyObjectFromJSONString];
        
        if ([reqeustConfig isKindOfClass:[NSDictionary class]]) {
            _requestConfig = reqeustConfig;
        }
    }
}

#pragma mark -

- (void)sendRequest:(WFDataCenterRequest *)request
           strategy:(HYDataCenterStrategy)strategy
         completion:(DataCenterCompletionBlock)completion
{
    KWSLogInfo(@"%@, ReadWrite option %lu, ReadPriority %lu", [request description], (unsigned long)strategy, (unsigned long)strategy);
    
    DataCenterCompletionBlock safeBlock = ^(id rsp, BOOL fromCache, NetworkServiceError *error) {
        
        KWSLogInfo(@"result %@, rsp %d, fromCache %d, error %@", [request description], (rsp ? YES : NO), fromCache, error);
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([rsp copy], fromCache, error);
            });
        }
    };
    
    if (strategy == HYDataCenterStrategyNetOnly) {
        
        [self dataFromNetworkWithRequest:request completion:^(id networkRsp, NetworkServiceError *networkError) {
            safeBlock(networkRsp, NO, networkError);
        }];
        
    } else if (strategy == HYDataCenterStrategyNetThenCache) {
        
        [self dataFromNetworkWithRequest:request completion:^(id networkRsp, NetworkServiceError *networkError) {
            
            BOOL hasCallback = NO;
            
            if (!request.avoidMultiCallbackIfNetworkError) {
                safeBlock(networkRsp, NO, networkError);
                hasCallback = YES;
            }
            
            if ([networkError hasError]) {
                id cacheRsp = [self objectForRequest:request];
                if (cacheRsp) {
                    safeBlock(cacheRsp, YES, nil);
                    hasCallback = YES;
                }
            }
            
            if (!hasCallback) {
                safeBlock(networkRsp, NO, networkError);
            }
        }];
        
    } else if (strategy == HYDataCenterStrategyCacheOnly) {
        
        //缓存
        id cacheRsp = [self objectForRequest:request];
        if (cacheRsp) {
            safeBlock(cacheRsp, YES, nil);
        }
        
    } else if (strategy == HYDataCenterStrategyCacheThenNet) {
        
        id cacheRsp = [self objectForRequest:request];
        if (cacheRsp) {
            safeBlock(cacheRsp, YES, nil);
        }
        
        //网络
        [self dataFromNetworkWithRequest:request completion:^(id networkRsp, NetworkServiceError *networkError) {
            if (cacheRsp && [cacheRsp isEqual:networkRsp]) return;
            safeBlock(networkRsp, NO, networkError);
        }];
    } else if (strategy == HYDataCenterStrategyCacheThenNetIfNoCache) {
        
        id cacheRsp = [self objectForRequest:request];
        if (cacheRsp) {
            safeBlock(cacheRsp, YES, nil);
        } else {
            //网络
            [self dataFromNetworkWithRequest:request completion:^(id networkRsp, NetworkServiceError *networkError) {
                safeBlock(networkRsp, NO, networkError);
            }];
        }
    }
}

#pragma mark - Network

- (void)dataFromNetworkWithRequest:(WFDataCenterRequest *)request completion:(void(^)(id networkRsp, NetworkServiceError *networkError))completion
{
    NetworkServiceError *sendError = nil;
    
    id<IWFDataCenterRequestProxy> requestProxy = [self requestProxyForRequest:request];
    
    if (requestProxy) {
        
        KWSLogInfo(@"network send %@", request);
        [requestProxy sendRequest:request completion:^(id rsp, NetworkServiceError *error) {
            
            if (request.ignoreValidatePropertyCheck) {
                [self safeCallBackWith:request rsp:rsp error:error completion:completion];
            } else {
                [self validateObject:rsp withWupProperties:request.shouldValidateProperties completion:^ {
                    [self safeCallBackWith:request rsp:rsp error:error completion:completion];
                }];
            }
            
        }];
        
    } else {
        NSAssert(NO, @"not request proxy found");
        NSError* err = [NSError errorWithDomain:HYDataCenterDomain code:HYDataCenterNoRequestProxy userInfo:@{NSLocalizedDescriptionKey: @"not request proxy found"}];
        KWSLogInfo(@"not request proxy found");
        sendError = [[NetworkServiceError alloc] init];
        sendError.error = err;
        
        completion(nil, sendError);
    }
}

- (id<IWFDataCenterRequestProxy>)requestProxyForRequest:(WFDataCenterRequest *)request
{
    id<IWFDataCenterRequestProxy> requestProxy = request.requestProxy;
    
    if (!requestProxy) {
        if (request.requestType == WFDataCenterRequestWUP) {
            
            BOOL requestUseHTTP = NO;
            
            if (_requestConfig) {
                
                if ([[_requestConfig safeNumberOrNilForKey:kAllWupRequestUseHTTP] boolValue]) {
                    requestUseHTTP = YES;
                }
                
                NSString *cgi = [request cgi];
                
                NSDictionary *singleRequestConfig = [_requestConfig safeDictionaryForKey:cgi];
                
                if (singleRequestConfig) {
                    
                    NSNumber *requestUseHTTPNumber = [singleRequestConfig safeNumberOrNilForKey:kWupRequestUseHTTP];
                    if (requestUseHTTPNumber) {
                        requestUseHTTP = [requestUseHTTPNumber boolValue];
                    }
                    
                    if (requestUseHTTP) {
                        NSNumber *retryCountNumber = [singleRequestConfig safeNumberOrNilForKey:kHTTPRetryCount];
                        
                        if (retryCountNumber) {
                            request.maxRetryCount = [retryCountNumber intValue];
                        }
                        
                        NSNumber *timeoutInterval = [singleRequestConfig safeNumberOrNilForKey:kHTTPTimeout];
                        
                        if (timeoutInterval) {
                            request.timeoutIntervals = [NSArray arrayWithObjects:timeoutInterval, nil];
                        }
                    }
                }
            }
            
            if (requestUseHTTP) {
                requestProxy = self.wupRequestProxy;
            } else {
                requestProxy = self.signalWupRequestProxy;
            }
            
        } else if (request.requestType == WFDataCenterRequestURL) {
            requestProxy = self.urlRequestProxy;
        }
    }
    
    return requestProxy;
}

- (void)safeCallBackWith:(WFDataCenterRequest *)request rsp:(id)rsp error:(NetworkServiceError *)error completion:(void(^)(id networkRsp, NetworkServiceError *networkError))completion
{
    //保存缓存
    if (rsp && [request.cacheKey length] && ![error hasError]) {
        [self.cacheProxy saveCachedTime:CFAbsoluteTimeGetCurrent() forObject:rsp];
        [self setObject:[rsp copy] forRequest:request];
    }
    
    if (request.canCallbackInBackground) {
        //调用者指定可以子线程回调，不切换线程，此时有可能是主线程，也有可能是子线程
        completion(rsp, error);
    } else {
        //调用者未指定可以子线程回调，强制主线程回调
        dispatch_async_main_queue_safe(^{
            completion(rsp, error);
        });
    }
}

#pragma mark - Cache

- (id<IHYDataCenterCacheProxy>)cacheProxyForReqeust:(WFDataCenterRequest *)request
{
    return (request.cacheProxy ? : self.cacheProxy);
}

- (id)objectForRequest:(WFDataCenterRequest *)request
{
    NSString *cacheKey = [request cacheKey];
    
    if (!cacheKey) {
        NSString *errorMsg = [NSString stringWithFormat:@"no cacheKey for %@", request];
        KWSLogInfo(@"%@", errorMsg);
        NSAssert(NO, errorMsg);
        return nil;
    }
    
    id<IHYDataCenterCacheProxy> cacheProxy = [self cacheProxyForReqeust:request];
    
    id cachedObject = [cacheProxy huyaObjectForKey:cacheKey];
    
    if (cachedObject && request.cacheDuration > 0) {
        
        CFAbsoluteTime cachedTime = [cacheProxy cachedTimeForObject:cachedObject];
        
        if (cachedTime > 0 && CFAbsoluteTimeGetCurrent() - cachedTime > request.cacheDuration) {
            KWSLogInfo(@"%@ get cache object but expire", request);
            cachedObject = nil;
        }
    }
    
    return cachedObject;
}

- (void)setObject:(id)object
       forRequest:(WFDataCenterRequest *)request
{
    if (!object) {
        return;
    }
    
    NSString *cacheKey = [request cacheKey];
    
    if (!cacheKey) {
        NSString *errorMsg = [NSString stringWithFormat:@"setObject error,no cacheKey for %@", request];
        KWSLogInfo(@"%@", errorMsg);
        NSAssert(NO, errorMsg);
        return;
    }
    
    [[self cacheProxyForReqeust:request] huyaSetObject:object forKey:cacheKey];
}

- (void)removeObjectForRequest:(WFDataCenterRequest *)request
{
    NSString *cacheKey = [request cacheKey];
    
    if (!cacheKey) {
        NSString *errorMsg = [NSString stringWithFormat:@"removeObjectForRequest error,no cacheKey for %@", request];
        KWSLogInfo(@"%@", errorMsg);
        NSAssert(NO, errorMsg);
        return;
    }
    
    [[self cacheProxyForReqeust:request] huyaRemoveObjectForKey:cacheKey];
}

- (id)objectForKey:(NSString *)key
{
    return [self.cacheProxy huyaObjectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self.cacheProxy huyaSetObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.cacheProxy huyaRemoveObjectForKey:key];
}

- (void)removeAllObject
{
    [self.cacheProxy huyaRemoveAllObjects];
}

#pragma mark - validateObject

- (void)validateObject:(id)object withWupProperties:(NSArray *)wupProperties completion:(void(^)())completion
{
    if (!completion) {
        return;
    }
    
    if (!object) {
        completion();
        return;
    }
    
    if ([NSThread isMainThread]) {
        //子线程执行，防止卡顿
        hy_dispatch_async_model(^{
            [self validateObject:object withWupProperties:wupProperties];
            completion();
        });
    } else {
        //已经在子线程了，不用再切换线程
        [self validateObject:object withWupProperties:wupProperties];
        completion();
    }
}

- (void)validateObject:(id)object withWupProperties:(NSArray *)wupProperties
{
    if (!object) {
        return;
    }
    
#ifdef DEBUG
    NSDate *date = [NSDate date];
#endif
    
    NSSet *properties = wupProperties ? ([self.shouldValidateProperties setByAddingObjectsFromArray:wupProperties]) : self.shouldValidateProperties;
    [self processValidateForObject:object shouldValidateProperties:properties];
    
#ifdef DEBUG
    DYLogInfo(@"%s time %f", __func__, fabs([date timeIntervalSinceNow]));
#endif
}

- (void)processValidateForObject:(id)object shouldValidateProperties:(NSSet<NSString *>*)shouldValidateProperties
{
    //    if ([object isKindOfClass:[WupObjectV2 class]]) {
    //
    //        WupClassInfo *classInfo = [[(WupObjectV2*)object class] classInfo];
    //
    //        NSArray *properties = classInfo.propertyInfos;
    //
    //        for (WupPropertyInfo *propInfo in properties) {
    //
    //            switch (propInfo.nsType) {
    //                case WupEncodingTypeNSString:
    //                case WupEncodingTypeNSMutableString:
    //                {
    //                    if ([shouldValidateProperties containsObject:NSStringFromSelector(propInfo.getter)]) {
    //
    //                        NSString *stringValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, propInfo.getter);
    //
    //                        if ([stringValue isKindOfClass:[NSString class]] && [stringValue length]) {
    //                            stringValue = [StringUtils convertSpecialText:stringValue];
    //                        }
    //
    //                        if (propInfo.nsType == WupEncodingTypeNSMutableString) {
    //                            stringValue = [stringValue mutableCopy];
    //                        }
    //
    //                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)object, propInfo.setter, stringValue);
    //                    }
    //                    break;
    //                }
    //
    //                case WupEncodingTypeNSArray:
    //                case WupEncodingTypeNSMutableArray:
    //                case WupEncodingTypeNSSet:
    //                case WupEncodingTypeNSMutableSet: {
    //                    id infoValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, propInfo.getter);
    //                    [self processValidateForObject:infoValue shouldValidateProperties:shouldValidateProperties];
    //                    break;
    //                }
    //
    //                case WupEncodingTypeNSDictionary:
    //                case WupEncodingTypeNSMutableDictionary: {
    //                    //字典，需要拿value出来过滤
    //                    NSDictionary *infoValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, propInfo.getter);
    //                    if ([infoValue respondsToSelector:@selector(allValues)]) {
    //                        NSArray *allValues = [infoValue allValues];
    //                        [self processValidateForObject:allValues shouldValidateProperties:shouldValidateProperties];
    //                    }
    //
    //                    break;
    //                }
    //
    //                case WupEncodingTypeNSUnknown: {
    //                    if (propInfo.dataType == WupEncodingTypeObject) {
    //                        id infoValue = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, propInfo.getter);
    //                        //WUP对象
    //                        if ([infoValue isKindOfClass:[WupObjectV2 class]]) {
    //                            [self processValidateForObject:infoValue shouldValidateProperties:shouldValidateProperties];
    //                        }
    //                    }
    //                    break;
    //                }
    //                default:
    //                    break;
    //            }
    //        }
    //
    //    } else if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
    //        for (id subObject in ((id<NSFastEnumeration>)object)) {
    //            [self processValidateForObject:subObject shouldValidateProperties:shouldValidateProperties];
    //        }
    //    }
}

@end
