//
//  HYLogProtocol.h
//  Pods
//
//  Created by Gideon on 2017/1/10.
//
//


typedef enum {
    HYLogLevelAll = 0,
    HYLogLevelVerbose = 0,
    HYLogLevelDebug,    // Detailed information on the flow through the system.
    HYLogLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    HYLogLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    HYLogLevelError,    // Other runtime errors or unexpected conditions.
    HYLogLevelFatal,    // Severe errors that cause premature termination.
    HYLogLevelNone,     // Special level used to disable all log messages.
} HYLogLevel;


@protocol IHYLogImplProtocol <NSObject>


/**
 @param isDebugMode 是否是debug模式
 @param logParentPath log父目录，如果传nil则默认存到/Library/Cache下
 @param logFileByteSize 文件大小，单位是 Byte
 */
- (void)prepareForLogging:(BOOL)isDebugMode appPrefix:(NSString *)appPrefix logParentPath:(NSString *)logParentPath logFileByteSize:(uint64_t)logFileByteSize;

- (void)unloadLog;

- (NSString *)logFolderPath;

/**
 返回最新的log文件的完整路径
 
 @return 文件的完整路径
 */
- (NSString *)lastLogFilePathName;

/**
 倒序返回log文件列表
 
 @return 文件列表
 */
- (NSArray *)logFilePathListByReverse;

/**
 * 在异步队列里写 log
 */
- (void)logWithLevel:(HYLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName message:(NSString *)message;

/**
 * 立即写 log
 */
- (void)logImmediatelyWithLevel:(HYLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName message:(NSString *)message;

- (BOOL)shouldLog:(HYLogLevel)level;

- (void)flush;

@end
