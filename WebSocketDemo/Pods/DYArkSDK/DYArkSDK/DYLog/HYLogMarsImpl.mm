//
//  HYLogMarsImpl.m
//  Pods
//
//  Created by Gideon on 2017/1/10.
//
//

#import "HYLogMarsImpl.h"

#import <mars/xlog/appender.h>
#import <mars/xlog/xloggerbase.h>

static NSUInteger g_processID = 0;

static uint64_t kMaxXLogFileSize = 1024 * 1024 * 1; // 2017-11-21 改为 1 MB

@interface HYLogMarsImpl ()

@property (strong, nonatomic) NSDictionary *levelStringDict;
@property (strong, nonatomic) NSString *logParentPath;
@property (strong, nonatomic) NSString *appPrefix;

@end

@implementation HYLogMarsImpl

- (void)prepareForLogging:(BOOL)isDebugMode appPrefix:(NSString *)appPrefix logParentPath:(NSString *)logParentPath logFileByteSize:(uint64_t)logFileByteSize
{
    self.appPrefix = appPrefix;
    
    self.levelStringDict = @{
                         @(HYLogLevelNone)    : @"NONE",
                         @(HYLogLevelFatal)   : @"FATAL",
                         @(HYLogLevelError)   : @"ERROR",
                         @(HYLogLevelWarn)    : @"WARNING",
                         @(HYLogLevelInfo)    : @"INFO",
                         @(HYLogLevelDebug)   : @"DEBUG",
                         @(HYLogLevelVerbose) : @"VERBOSE",
                         @(HYLogLevelAll)     : @"ALL"
                         };
    
    if ([logParentPath length]) {
        _logParentPath = logParentPath;
    }
    
    if (isDebugMode) {
        xlogger_SetLevel(kLevelDebug);
        appender_set_console_log(true);
    } else {
        xlogger_SetLevel(kLevelInfo);
        appender_set_console_log(false);
    }
    
    appender_set_max_file_size(logFileByteSize ? : kMaxXLogFileSize);
    
    NSString *logPath = [self logFolderPath];
    appender_open(kAppednerAsync, [logPath UTF8String], [self.appPrefix UTF8String], "");
}

- (void)unloadLog
{
    appender_close();
}

- (NSString *)logFolderPath
{
    NSString* path = [self getLogPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSString *)lastLogFilePathName
{
    NSArray *logFileList = [self logFilePathListByReverse];
    return [logFileList lastObject];
}

- (NSArray *)logFilePathListByReverse
{
    NSString *logFolderPath = [self logFolderPath];
    NSError *error = nil;
    NSArray *logFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolderPath error:&error];
    if (logFileList == nil || [logFileList count] == 0){
        return nil;
    }
    NSMutableArray *tmpLogFileList = [NSMutableArray new];
    [logFileList enumerateObjectsUsingBlock:^(NSString * logFilePath, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[logFilePath pathExtension] isEqualToString:@"xlog"]) {
            [tmpLogFileList addObject:[logFolderPath stringByAppendingPathComponent:logFilePath]];
        }
    }];
    
    tmpLogFileList = [tmpLogFileList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSDictionary *firstProperties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil];
        NSDate *firstDate = [firstProperties  objectForKey:NSFileModificationDate];
        NSDictionary *secondProperties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil];
        NSDate *secondDate = [secondProperties objectForKey:NSFileModificationDate];
        return [secondDate compare:firstDate];
    }];
    
    return [tmpLogFileList copy];
}

- (void)logWithLevel:(HYLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName message:(NSString *)message
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    uintptr_t tid = (uintptr_t)[NSThread currentThread];
    
    // 质量监控中心检测到大量调用 xlog 可能会导致卡顿，用异步队列避免阻塞主线程
    dispatch_async([self loggerQueue], ^{
        [self writeLogWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message time:time tid:tid];
    });
}

- (void)logImmediatelyWithLevel:(HYLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName message:(NSString *)message
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    uintptr_t tid = (uintptr_t)[NSThread currentThread];
    
    [self writeLogWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message time:time tid:tid];
}

- (BOOL)shouldLog:(HYLogLevel)level
{
    if (level >= xlogger_Level()) {
        return YES;
    }
    return NO;
}

- (void)flush
{
    appender_flush();
}

#pragma mark - private

- (void)writeLogWithLevel:(HYLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName message:(NSString *)message time:(struct timeval)time tid:(uintptr_t)tid
{
    NSString *tag = [NSString stringWithFormat:@"<%@>%@", [self levelStringWithLevel:logLevel], moduleName ? [NSString stringWithFormat:@"<%@>", moduleName] : @""];
    
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = tag.UTF8String;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    info.timeval = time;
    info.tid = tid;
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    
    xlogger_Write(&info, message.UTF8String);
}

- (NSString *)levelStringWithLevel:(HYLogLevel)level
{
    NSString *str = self.levelStringDict[@(level)];
    return str ? : @"UNKNOWN";
}

- (dispatch_queue_t)loggerQueue
{
    static dispatch_queue_t queue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.yy.mobile.huya.xlogger", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

#pragma mark - log File Path

- (NSString *)getCacheDirectory
{
    do {
        if (_logParentPath)
            break;
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1)
            break;
        
        _logParentPath = [directories objectAtIndex:0];
        
        NSUInteger length = [_logParentPath length];
        if (length < 1) {
            _logParentPath = nil;
            break;
        }
        
        if ('/' == [_logParentPath characterAtIndex:length - 1])
            break;
        
        _logParentPath = [_logParentPath stringByAppendingString:@"/"];
    } while (false);
    
    return _logParentPath;
}

- (NSString *)getLogPath
{
    static NSString * kLogDir = @"logs/";
    NSString *cacheDir = [self getCacheDirectory];
    if (cacheDir == nil){
        return nil;
    }
    return [cacheDir stringByAppendingPathComponent:kLogDir];
}

@end
