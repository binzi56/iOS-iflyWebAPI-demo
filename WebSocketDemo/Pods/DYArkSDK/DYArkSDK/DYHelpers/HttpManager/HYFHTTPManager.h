//
//  YYHTTPRequestOperationManager.h
//  kiwi
//
//  Created by li yipeng on 14-4-14.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

extern NSTimeInterval kHYFDefaultRequestTimeout;

@protocol HYHTTPMonitorDelegate <NSObject>

@required
- (void)didReceiveHttpRespFromRequest:(NSURLRequest *)req resp:(id)resp timeConsumingMs:(long long)timeConsumingMs error:(NSError*)error;

@end

/**
 *  @brief  除上传下载外，其他所有HTTP请求都设置超时时间为10s
 */
@interface HYFHTTPManager : NSObject

+ (instancetype)sharedObject;

+ (void)setupHttpMonitorDelegate:(id<HYHTTPMonitorDelegate>)monitorDelegate;

/**
 *  @brief  10s超时
 */
+ (void)sendRequest:(NSURLRequest *)request
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  timeoutInteval s超时
 */
+ (void)sendRequest:(NSURLRequest *)request
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 发送request，从子线程回调，一般在wup请求中使用，backgroundSuccess中子线程解包，减少主线程卡顿
 */
+ (void)sendRequest:(NSURLRequest *)request
       useURLSesion:(BOOL)useURLSesion
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
  backgroundSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))backgroundSuccess
  backgroundFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))backgroundFailure;

/**
 *  @brief  10s超时
 */
+ (void)sendHttpRequestWithUrl:(NSString *)url
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  下载，如音频下载，系统默认超时
 */
+ (void)sendHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
              //downloadProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgress;

/**
 *  @brief  10s超时
 */
+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  10s超时
 */
+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  10s超时
 */
+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                 needStatistic:(BOOL)needStatistic
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
           uploadProgressBlock:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
/**
 *  @brief  超时设为0则不超时
 */
+ (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  上传，如图片下载，系统默认超时
 */
+ (void)putHttpRequestWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters
                  bodyContent:(NSData *)bodyContent
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  @brief  下载较大的资源，直接存储到本地文件
 */
+ (void)downloadWithRequest:(NSString *)url
              localFilePath:(NSString *)localFilePath
                    success:(void (^)(NSURLSessionDownloadTask *task, NSURL *filePath))success
                    failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;

/**
 post json请求，系统默认超时
 */
+ (void)postJsonHttpRequestWithUrl:(NSString *)url
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  @brief  如果URL schema是http，转换成https
 */
+ (NSString *)urlStringWithHttpsSchema:(NSString *)originUrlString;


@end
