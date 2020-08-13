//
//  WFHTTPManager+IWFDataCenterRequestProxy.m
//  kiwi
//
//  Created by hpf1908 on 2017/1/9.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "HYFHTTPManager+IWFDataCenterRequestProxy.h"
#import "NetWorkUtils.h"

@implementation HYFHTTPManager (IWFDataCenterRequestProxy)

- (void)sendRequest:(WFDataCenterRequest *)request completion:(void (^)(id, NSError *))completion
{
    if (![NetWorkUtils networkReachable]) {
        
        if (completion) {
            completion(nil, [NetWorkUtils currentError]);
        }
        return;
    }
    
    NSString *urlString = (NSString *)request.request;
    
    if (![urlString isKindOfClass:[NSString class]]) {
        return;
    }
    
    [[self class] sendHttpRequestWithUrl:urlString success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (completion) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (completion) {
            completion(nil, error);
        }
    }];
}


@end
