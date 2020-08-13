//
//  DYNetworkTypes.h
//  DYArkSDK
//
//  Created by flyhuang on 2018/10/23.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int32_t {
    ChannelType_Unknown   = 0,
    ChannelType_ShortConn = 1,
    ChannelType_LongConn = 2,
    ChannelType_Async = 3,
    ChannelType_All = 4
} ChannelType;

@interface Error : NSObject

@property (assign, nonatomic) int32_t code;
@property (strong, nonatomic) NSString *message;        //后台返回的值
@property (strong, nonatomic) NSString *logDescription;    //调试用

@end

@interface NetworkServiceError : NSObject

@property(nonatomic,strong) NSError* error;     //网络错误
@property(nonatomic,strong) Error* busiError;   //服务错误

- (BOOL)hasError;

- (NSInteger)code;

- (NSString*)errorMessage;

- (NSString*)errorDescribe;

@end
