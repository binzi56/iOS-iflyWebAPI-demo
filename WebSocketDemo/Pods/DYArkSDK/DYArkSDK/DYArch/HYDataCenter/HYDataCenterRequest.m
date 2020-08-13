//
//  WFDataCenterRequest.m
//  kiwi
//
//  Created by liyipeng on 2017/1/6.
//  Copyright © 2017年 YY Inc. All rights reserved.
//

#import "HYDataCenterRequest.h"
#import "HYFHTTPManager.h"
#import "KiwiSDKMacro.h"

NSTimeInterval const kOneHourInterval   = 3600;
NSTimeInterval const kOneDayInterval    = 86400;
NSTimeInterval const kOneWeekInterval   = 604800;

static const int32_t kDefaultRetryCount= 1;

@interface WFDataCenterRequest ()
@property (nonatomic, strong) NSString *cgi;
@property (nonatomic, weak) id networkRequest;
@end

@implementation WFDataCenterRequest

+ (instancetype)wupRequestWithReq:(id)req
                      servantName:(NSString *)servantName
                         funcName:(NSString *)funcName
                         rspClass:(Class)rspClass
{
    WFDataCenterRequest *dataCenterRequest = [[WFDataCenterRequest alloc] init];
    dataCenterRequest.request = req;
    dataCenterRequest.servant = servantName;
    dataCenterRequest.func = funcName;
    dataCenterRequest.dataChannel = HYWupDataChannelHySignal;
    dataCenterRequest.rspClass = rspClass;
    dataCenterRequest.requestType = WFDataCenterRequestWUP;
    dataCenterRequest.timeoutIntervals = @[@(kHYFDefaultRequestTimeout)];
    dataCenterRequest.maxRetryCount = kDefaultRetryCount;
    dataCenterRequest.channelSelect = ChannelType_All;
    return dataCenterRequest;
}

+ (instancetype)noRetryWupRequestWithReq:(id)req
                             servantName:(NSString *)servantName
                                funcName:(NSString *)funcName
                                rspClass:(Class)rspClass
{
    WFDataCenterRequest *dataCenterRequest = [[WFDataCenterRequest alloc] init];
    dataCenterRequest.request = req;
    dataCenterRequest.servant = servantName;
    dataCenterRequest.func = funcName;
    dataCenterRequest.dataChannel = HYWupDataChannelHySignal;
    dataCenterRequest.rspClass = rspClass;
    dataCenterRequest.requestType = WFDataCenterRequestWUP;
    dataCenterRequest.timeoutIntervals = @[@(kHYFDefaultRequestTimeout)];
    dataCenterRequest.maxRetryCount = 0;
    dataCenterRequest.channelSelect = ChannelType_All;
    return dataCenterRequest;
}

//普通http请求
+ (instancetype)urlRequestWithUrlString:(NSString *)urlString
{
    WFDataCenterRequest *dataCenterRequest = [[WFDataCenterRequest alloc] init];
    dataCenterRequest.request = urlString;
    dataCenterRequest.cacheKey = urlString;
    dataCenterRequest.requestType = WFDataCenterRequestURL;
    dataCenterRequest.timeoutIntervals = @[@(kHYFDefaultRequestTimeout)];
    dataCenterRequest.maxRetryCount = kDefaultRetryCount;
    dataCenterRequest.channelSelect = ChannelType_All;
    return dataCenterRequest;
}

//读取缓存
+ (instancetype)requestWithCacheKey:(NSString *)cacheKey
{
    WFDataCenterRequest *dataCenterRequest = [[WFDataCenterRequest alloc] init];
    dataCenterRequest.cacheKey = cacheKey;
    dataCenterRequest.requestType = WFDataCenterRequestCache;
    dataCenterRequest.channelSelect = ChannelType_All;
    return dataCenterRequest;
    
}

- (NSString *)cgi
{
    if (!_cgi) {
        _cgi = [NSString stringWithFormat:@"/%@/%@",self.servant, self.func];
    }
    
    return _cgi;
}

- (void)setNetworkRequest:(id)networkRequest
{
    _networkRequest = networkRequest;
}

- (void)cancel
{
    if ([self.networkRequest respondsToSelector:@selector(cancel)]) {
        KWSLogInfo(@"%@", self);
        [self.networkRequest cancel];
    }
}

- (NSString *)description
{
    switch (self.requestType) {
        case WFDataCenterRequestURL:
            return [NSString stringWithFormat:@"req:%p url:%@", self, self.request];
            break;
            
        case WFDataCenterRequestWUP: {
            return [NSString stringWithFormat:@"req:%p %@, func %@, %@", self, NSStringFromClass(self.request.class), self.func, NSStringFromClass(self.rspClass)];
            break;
        }
        case WFDataCenterRequestCache: {
            return [NSString stringWithFormat:@"req:%p cache:%@", self, [self cacheKey]];
            break;
        }
        default:
            break;
    }
}

@end
