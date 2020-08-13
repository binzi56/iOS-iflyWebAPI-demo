//
//  YYHTTPRequestOperationManager.m
//  kiwi
//
//  Created by li yipeng on 14-4-14.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import "HYFHTTPManager.h"
#import "KiwiSDKMacro.h"

/**
 * http接口请求超时时间，超过10s时会调[NSURLSessionDataTask cancel]，触发系统错误NSURLErrorCancelled
 */
NSTimeInterval kHYFDefaultRequestTimeout = 10;

@interface HYFHTTPManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *backgoundCallBackSessionManager;

@property (nonatomic, weak) id<HYHTTPMonitorDelegate> monitorDelegate;

@end

@implementation HYFHTTPManager

+ (instancetype)sharedObject
{
    static HYFHTTPManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HYFHTTPManager alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.sessionManager = [[AFHTTPSessionManager alloc] init];
        
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager.responseSerializer = serializer;
        
        
        self.backgoundCallBackSessionManager = [[AFHTTPSessionManager alloc] init];
        self.backgoundCallBackSessionManager.responseSerializer = serializer;
        self.backgoundCallBackSessionManager.completionQueue = dispatch_queue_create("com.huyafoundation.http.background.complete", DISPATCH_QUEUE_SERIAL);
        
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        securityPolicy.validatesDomainName = NO;
        if ([self isAppInternalVersion]){
            //内部版本设置，避免某些测试环境的https证书无效导致请求被cancel
            securityPolicy.allowInvalidCertificates = YES;
        }
        self.sessionManager.securityPolicy = securityPolicy;
        self.backgoundCallBackSessionManager.securityPolicy = securityPolicy;
        //#warning TODO: FIXME in product environment
        //_sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    }
    return self;
}

#pragma mark -

- (void)sendRequest:(NSURLRequest *)request
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self sendRequest:request needStatistic:YES timeoutInteval:kHYFDefaultRequestTimeout success:success failure:failure];
}

- (void)sendRequest:(NSURLRequest *)request
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [self taskWithRequest:request sessionManager:self.sessionManager needStatistic:needStatistic timeoutInterval:timeoutInteval success:success failure:failure];
    
    [task resume];
}

- (void)sendRequest:(NSURLRequest *)request
       useURLSesion:(BOOL)useURLSesion
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
  backgroundSuccess:(void (^)(NSURLSessionDataTask *, id))success
  backgroundFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSURLSessionDataTask *task = [self taskWithRequest:request sessionManager:self.backgoundCallBackSessionManager useURLSesion:useURLSesion needStatistic:needStatistic timeoutInterval:timeoutInteval success:success failure:failure];
    
    [task resume];
}

- (void)sendHttpRequestWithUrl:(NSString *)url
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [self sendRequest:request success:success failure:failure];
}


- (void)sendHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSError *error =  nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    [self sendRequest:request success:success failure:failure];
}


- (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self postHttpRequestWithUrl:url
                         timeout:kHYFDefaultRequestTimeout
                      parameters:parameters
       constructingBodyWithBlock:block
    constructingRequestWithBlock:nil
                         success:success
                         failure:failure];
}

- (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
  constructingRequestWithBlock:(void (^)(NSMutableURLRequest* request))requestBlock
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                               URLString:[[NSURL URLWithString:url relativeToURL:self.sessionManager.baseURL] absoluteString]
                                                                                              parameters:parameters
                                                                               constructingBodyWithBlock:block
                                                                                                   error:nil];
    if (requestBlock) {
        requestBlock(request);
    }
    NSURLSessionDataTask *task = [self taskWithRequest:request sessionManager:self.sessionManager needStatistic:YES timeoutInterval:timeout success:success failure:failure];
    [task resume];
}

- (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
           uploadProgressBlock:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                               URLString:[[NSURL URLWithString:url relativeToURL:self.sessionManager.baseURL] absoluteString]
                                                                                              parameters:parameters
                                                                               constructingBodyWithBlock:block
                                                                                                   error:nil];
    
    NSURLSessionDataTask *task = [self.sessionManager uploadTaskWithRequest:request fromData:nil progress:uploadProgressBlock completionHandler:completionHandler];
    [task resume];
}

- (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                 needStatistic:(BOOL)needStatistic
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSError *error =  nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:parameters error:&error];
    
    NSURLSessionDataTask *task = [self taskWithRequest:request sessionManager:self.sessionManager needStatistic:needStatistic timeoutInterval:kHYFDefaultRequestTimeout success:success failure:failure];
    [task resume];
}

- (void)putHttpRequestWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters
                  bodyContent:(NSData *)bodyContent
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //https://github.com/AFNetworking/AFNetworking/issues/1112
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setAllHTTPHeaderFields:parameters];
    [request setHTTPBody:bodyContent];
    [request setHTTPMethod:@"PUT"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSURLSessionDataTask *task = [self taskWithRequest:request sessionManager:self.sessionManager needStatistic:YES timeoutInterval:0 success:success failure:failure];
    [task resume];
}

- (void)downloadWithRequest:(NSString *)url
              localFilePath:(NSString *)localFilePath
                    success:(void (^)(NSURLSessionDownloadTask *task, NSURL *filePath))success
                    failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __weak NSURLSessionDownloadTask *task = nil;
    task = [self.sessionManager downloadTaskWithRequest:request
                                               progress:nil
                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                return [NSURL fileURLWithPath:localFilePath];
                                            }
                                      completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                          if (error == nil){
                                              if (success){
                                                  success(task, filePath);
                                              }
                                          }
                                          else{
                                              if (failure){
                                                  failure(task, error);
                                              }
                                          }
                                          
                                      }];
    [task resume];
}

/**
 *  @brief  返回带超时的NSURLSessionDataTask
 *  @param timeoutInterval 如果等于0，则不设置超时
 */
- (NSURLSessionDataTask *)taskWithRequest:(NSURLRequest *)request
                           sessionManager:(AFHTTPSessionManager *)sessionManager
                             useURLSesion:(BOOL)useURLSesion
                            needStatistic:(BOOL)needStatistic
                          timeoutInterval:(int32_t)timeoutInterval
                                  success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                                  failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure
{
    __block NSURLSessionDataTask *task = nil;
    CFAbsoluteTime start = needStatistic ? CFAbsoluteTimeGetCurrent() : 0;
    
    void(^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        long long usedTime = needStatistic ? [[self class] usedTimeSince:start limitedToTimeoutInterval:timeoutInterval] : 0;
        
        if (error == nil){
            if (success){
                success(task, data);
            }
        }
        else{
            if (failure){
                failure(task, error);
            }
        }
        if (needStatistic) {
            if (self.monitorDelegate && [self.monitorDelegate respondsToSelector:@selector(didReceiveHttpRespFromRequest:resp:timeConsumingMs:error:)]){
                [self.monitorDelegate didReceiveHttpRespFromRequest:request resp:data timeConsumingMs:usedTime error:error];
            }
        }
    };
    
    if (useURLSesion) {
        
        task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            completionHandler(data, response, error);
        }];
        
    } else {
        task = [sessionManager dataTaskWithRequest:request
                                 completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                     
                                     completionHandler(responseObject, response, error);
                                     
                                 }];
    }
    
    if (timeoutInterval > 0){
        __weak NSURLSessionDataTask* weakTask = task;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakTask && weakTask.state != NSURLSessionTaskStateCompleted){
                KWSLogError(@"[Kiwi:YYHTTPManager] NSURLSessionDataTask %@ timeout after %ds cancel", weakTask.originalRequest.URL, timeoutInterval);
                //[NOTE]cancel会触发failure回调，error为NSURLErrorCancelled
                [weakTask cancel];
                
                //2016.9.27，换成NSURLSessionDataTask后cancel调failure block，不需要再手动调。
                /*
                 if (failure){
                 NSError *error = [NSError errorWithDomain:kHTTPErrorDomain
                 code:kHTTPTimeoutErrorCodeTimeout
                 userInfo:@{NSLocalizedDescriptionKey : kHTTPTimeoutDescription}];
                 failure(weakTask, error);
                 }
                 */
            }
        });
    }
    
    return task;
}

/**
 *  @brief  返回带超时的NSURLSessionDataTask
 *  @param timeoutInterval 如果等于0，则不设置超时
 */
- (NSURLSessionDataTask *)taskWithRequest:(NSURLRequest *)request
                           sessionManager:(AFHTTPSessionManager *)sessionManager
                            needStatistic:(BOOL)needStatistic
                          timeoutInterval:(int32_t)timeoutInterval
                                  success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                                  failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure
{
    
    return [self taskWithRequest:request sessionManager:sessionManager useURLSesion:NO needStatistic:needStatistic timeoutInterval:timeoutInterval success:success failure:failure];
}

#pragma mark - public

+ (void)setupHttpMonitorDelegate:(id<HYHTTPMonitorDelegate>)monitorDelegate;
{
    [HYFHTTPManager sharedObject].monitorDelegate = monitorDelegate;
}

+ (void)sendRequest:(NSURLRequest *)request
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [HYFHTTPManager sendRequest:request needStatistic:YES timeoutInteval:kHYFDefaultRequestTimeout success:success failure:failure];
}


+ (void)sendRequest:(NSURLRequest *)request
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] sendRequest:request needStatistic:needStatistic timeoutInteval:timeoutInteval success:success failure:failure];
}

/**
 发送request，从子线程回调，一般在wup请求中使用，backgroundSuccess中子线程解包，减少主线程卡顿
 */
+ (void)sendRequest:(NSURLRequest *)request
       useURLSesion:(BOOL)useURLSesion
      needStatistic:(BOOL)needStatistic
     timeoutInteval:(NSTimeInterval)timeoutInteval
  backgroundSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))backgroundSuccess
  backgroundFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))backgroundFailure
{
    [[HYFHTTPManager sharedObject] sendRequest:request useURLSesion:useURLSesion needStatistic:needStatistic timeoutInteval:timeoutInteval backgroundSuccess:backgroundSuccess backgroundFailure:backgroundFailure];
}

+ (void)sendHttpRequestWithUrl:(NSString *)url
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] sendHttpRequestWithUrl:url success:success failure:failure];
}


+ (void)sendHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] sendHttpRequestWithUrl:url
                                               parameters:parameters
                                                  success:success
                                                  failure:failure];
}


+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] postHttpRequestWithUrl:url
                                               parameters:parameters
                                constructingBodyWithBlock:block
                                                  success:success
                                                  failure:failure];
}

+ (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [[HYFHTTPManager sharedObject] postHttpRequestWithUrl:url
                                                  timeout:timeout
                                               parameters:parameters
                                constructingBodyWithBlock:block
                             constructingRequestWithBlock:nil
                                                  success:success
                                                  failure:failure];
}

+ (void)postHttpRequestWithUrl:(NSString *)url
                       timeout:(uint32_t)timeout
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
           uploadProgressBlock:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    [[HYFHTTPManager sharedObject] postHttpRequestWithUrl:url
                                                  timeout:timeout
                                               parameters:parameters
                                constructingBodyWithBlock:block
                                      uploadProgressBlock:uploadProgressBlock
                                        completionHandler:completionHandler];
}

+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [HYFHTTPManager postHttpRequestWithUrl:url parameters:parameters needStatistic:YES success:success failure:failure];
}

+ (void)postHttpRequestWithUrl:(NSString *)url
                    parameters:(NSDictionary *)parameters
                 needStatistic:(BOOL)needStatistic
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] postHttpRequestWithUrl:url parameters:parameters needStatistic:needStatistic success:success failure:failure];
}


+ (void)putHttpRequestWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters
                  bodyContent:(NSData *)bodyContent
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] putHttpRequestWithUrl:url parameters:parameters bodyContent:bodyContent success:success failure:failure];
}

+ (void)downloadWithRequest:(NSString *)url
              localFilePath:(NSString *)localFilePath
                    success:(void (^)(NSURLSessionDownloadTask *task, NSURL *filePath))success
                    failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure
{
    [[HYFHTTPManager sharedObject] downloadWithRequest:url localFilePath:localFilePath success:success failure:failure];
}

+ (void)postJsonHttpRequestWithUrl:(NSString *)url
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    void (^constructingRequestWithBlock)(NSMutableURLRequest* request) = ^(NSMutableURLRequest* request) {
        
        if (parameters) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            NSError *serializationError = nil;
            NSData *bodyData = nil;
            if ([NSJSONSerialization isValidJSONObject:parameters]) {
                bodyData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&serializationError];
            } else {
                KWSLogError(@"invalid Json object");
            }
            
            if (serializationError) {
                KWSLogError(@"%@", serializationError);
            }
            if (bodyData) {
                [request setHTTPBody:bodyData];
            }
        }
    };
    
    [[HYFHTTPManager sharedObject] postHttpRequestWithUrl:url
                                                  timeout:0
                                               parameters:nil
                                constructingBodyWithBlock:nil
                             constructingRequestWithBlock:constructingRequestWithBlock
                                                  success:success
                                                  failure:failure];
}

+ (NSString *)urlStringWithHttpsSchema:(NSString *)originUrlString
{
    //暂时关闭
//    NSString* const kHttpSchema  = @"http://";
//    NSString* const kHttpsSchema = @"https://";
//    
//    if ([originUrlString hasPrefix:kHttpSchema]){
//        return [originUrlString stringByReplacingOccurrencesOfString:kHttpSchema withString:kHttpsSchema];
//    }
    
    return originUrlString;
}

/**
 退到后台时定时器无法执行，这里做修正，如果耗时比设定超时时间还大5s，则强制耗时为超时时间
 @param start 请求开始时间
 @param timeoutInterval 超时时间
 @return 请求开始到当前时间的毫秒数，最大不超过超时时间+5s
 */
+ (long long)usedTimeSince:(CFAbsoluteTime)start limitedToTimeoutInterval:(int32_t)timeoutInterval
{
    CFTimeInterval usedSeconds = CFAbsoluteTimeGetCurrent() - start;
    
    int tolerance = 5;
    
    if (timeoutInterval > 0 && usedSeconds > (timeoutInterval + tolerance)) {
        
        KWSLogInfo(@"usedSeconds %f, reset to %d", usedSeconds, timeoutInterval);
        usedSeconds = timeoutInterval;
    }
    return usedSeconds * 1000;
}

#pragma mark - private

- (BOOL)isAppInternalVersion
{
#ifdef DEBUG
    return YES;
#endif
    return [[NSBundle mainBundle].bundleIdentifier rangeOfString:@"enterprise"].location != NSNotFound;
}

@end
