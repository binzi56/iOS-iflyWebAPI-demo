//
//  LogModel.h
//  YY2
//
//  Created by dev on 9/14/12.
//  Copyright (c) 2012 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HYLogProtocol.h"

#define HY_LOG_INTERNAL(level, moduleName, formatStr, ...)  \
do { \
if ([HYLog shouldLog:level]) { \
[HYLog logWithLevel:level module:moduleName fileName:__FILE__ lineNum:__LINE__ funcName:__FUNCTION__ format:(formatStr), ##__VA_ARGS__]; \
} \
} while(0)

#define HY_LOG_SIMPLE_INTERNAL(level, moduleName, formatStr, ...)  \
do { \
if ([HYLog shouldLog:level]) { \
[HYLog logWithLevel:level module:moduleName format:(formatStr), ##__VA_ARGS__]; \
} \
} while(0)

#define HY_LOG_IMMEDIATELY_INTERNAL(level, moduleName, formatStr, ...)  \
do { \
if ([HYLog shouldLog:level]) { \
[HYLog logImmediatelyWithLevel:level module:moduleName fileName:__FILE__ lineNum:__LINE__ funcName:__FUNCTION__ format:(formatStr), ##__VA_ARGS__]; \
} \
} while(0)


typedef void (^kHYLogErrorCallbackBlock)(HYLogLevel logLevel, NSString *module, const char *fileName, int32_t lineNum, const char *funcName, NSString *message);

@interface HYLog : NSObject

/**
 *  初始化 Log 模块
 *  @param logParentPath log存储路径，如果传nil，则存储到/Library/Cache
 *  @param logFileByteSize 文件大小，单位是 Byte
 */
+ (void)prepareForLogging:(BOOL)needConsoleLog
                appPrefix:(NSString *)appPrefix
            logParentPath:(NSString *)logParentPath
          logFileByteSize:(uint64_t)logFileByteSize;

/**
 *  卸载 Log 模块
 *
 */
+ (void)unloadLog;

/**
 *  Log 文件全路径
 *
 *  @return 路径名
 */
+ (NSString *)logFolderPath;


/**
 最新的log文件的完整路径
 
 @return log文件完整路径
 */
+ (NSString *)lastLogFilePathName;

/**
 倒序返回log文件列表
 
 @return 文件列表
 */
+ (NSArray *)logFilePathListByReverse;

/**
 *  根据指定的级别、格式打 Log。使用默认的 module、context(KWSLogContextDefault)。
 *  为了自定义logerror的方式，避免ddlog在主线程打logerror。
 *
 *  @param logLevel   Log 级别
 *  @param message 格式字符串
 */
+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char *)fileName lineNum:(int32_t)lineNum funcName:(const char *)funcName message:(NSString *)message;

+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char *)fileName lineNum:(int32_t)lineNum funcName:(const char *)funcName format:(NSString *)format, ... NS_FORMAT_FUNCTION(6,7);

/**
 这个方法不打印文件名、方法名、行数
 */
+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module format:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

/**
 * 同步写 log
 */
+ (void)logImmediatelyWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char *)fileName lineNum:(int32_t)lineNum funcName:(const char *)funcName format:(NSString *)format, ... NS_FORMAT_FUNCTION(6,7);

+ (BOOL)shouldLog:(HYLogLevel)level;

+ (void)flush;

+ (void)logErrorCallbackBlock:(kHYLogErrorCallbackBlock)callbackBlock;

@end





