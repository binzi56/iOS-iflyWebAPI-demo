//
//  LogModel.m
//  YY2
//
//  Created by dev on 9/14/12.
//  Copyright (c) 2012 YY Inc. All rights reserved.
//

#import "HYLog.h"
#import "HYLogMarsImpl.h"
#import "HYLogMacros.h"

//#import "CrashReportManager.h"

@implementation HYLog

static id<IHYLogImplProtocol> _logImpl = nil;

static kHYLogErrorCallbackBlock _callbackBlock = nil;

#pragma mark - Public

+ (void)prepareForLogging:(BOOL)needConsoleLog
                appPrefix:(NSString *)appPrefix
            logParentPath:(NSString *)logParentPath
          logFileByteSize:(uint64_t)logFileByteSize
{
    _logImpl = [HYLogMarsImpl new];
    
    [_logImpl prepareForLogging:needConsoleLog appPrefix:appPrefix logParentPath:logParentPath logFileByteSize:logFileByteSize];
    
    ////prepareForLogging is called when app is in start-up pharse, to avoid slow start-up pharse,
    //putting cleanLogFiles to aysnc call in main thread
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [HYLog cleanLogFiles];
    });
}

+ (void)unloadLog
{
    [_logImpl unloadLog];
}


+ (NSString *)logFolderPath
{
    return [_logImpl logFolderPath];
}

+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char*)fileName lineNum:(int32_t)lineNum funcName:(const char*)funcName message:(NSString *)message
{
    if (HYLogLevelError == logLevel ||
        HYLogLevelFatal == logLevel) {
        //        [CrashReportManager.shareInstance reportCustomErrorWithTitle:module desc:message];
        if (_callbackBlock) {
            _callbackBlock(logLevel, module, fileName, lineNum, funcName, message);
        }
    }
    [_logImpl logWithLevel:logLevel moduleName:module fileName:fileName lineNumber:lineNum funcName:funcName message:message];
}

+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char*)fileName lineNum:(int32_t)lineNum funcName:(const char*)funcName format:(NSString *)format, ...
{
    NSAssert(format, @"参数不能为空");
    va_list argList;
    va_start(argList, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    [_logImpl logWithLevel:logLevel moduleName:module fileName:fileName lineNumber:lineNum funcName:funcName message:message];
}

+ (void)logWithLevel:(HYLogLevel)logLevel module:(NSString *)module format:(NSString *)format, ...
{
    NSAssert(format, @"参数不能为空");
    
    va_list argList;
    va_start(argList, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    [_logImpl logWithLevel:logLevel moduleName:module fileName:"" lineNumber:0 funcName:"" message:message];
}

+ (void)logImmediatelyWithLevel:(HYLogLevel)logLevel module:(NSString *)module fileName:(const char *)fileName lineNum:(int32_t)lineNum funcName:(const char *)funcName format:(NSString *)format, ... NS_FORMAT_FUNCTION(6,7)
{
    NSAssert(format, @"参数不能为空");
    va_list argList;
    va_start(argList, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    
    [_logImpl logImmediatelyWithLevel:logLevel moduleName:module fileName:fileName lineNumber:lineNum funcName:funcName message:message];
}

+ (BOOL)shouldLog:(HYLogLevel)level
{
    return [_logImpl shouldLog:level];
}

+ (void)flush
{
    [_logImpl flush];
}

+ (void)logErrorCallbackBlock:(kHYLogErrorCallbackBlock)callbackBlock
{
    _callbackBlock = callbackBlock;
}

#pragma mark - private

+ (void)cleanLogFiles
{
    NSError* error= nil;
    NSString* logFolder = [HYLog logFolderPath];
    NSArray* logFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolder error:&error];
    if (logFiles == nil || [logFiles count] == 0) {
        KWSLogError(@"Error happened when clearnLogFiles:%@", error);
        return;
    }
    
#ifdef DEBUG
    NSDate* date = [[NSDate date] dateByAddingTimeInterval:-10*24*60*60];
#else
    NSDate* date = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
#endif
    
    for (NSString *logFile in logFiles) {
        
        NSString *logFilePath = [logFolder stringByAppendingPathComponent:logFile];
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:&error];
        if (fileAttr) {
            NSDate *creationDate = [fileAttr valueForKey:NSFileCreationDate];
            if ([creationDate compare:date] == NSOrderedAscending) {
                KWSLogInfo(@"[Kiwi:LogExt] cleanLogFiles: %@ will be deleted", logFile);
                [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
                KWSLogInfo(@"[Kiwi:LogExt] cleanLogFiles: %@ was deleted, error number is %ld", logFilePath, (long)error.code);
            }
        }
    }
}

+ (NSString *)lastLogFilePathName
{
    return [_logImpl lastLogFilePathName];
}

+ (NSArray *)logFilePathListByReverse
{
    return [_logImpl logFilePathListByReverse];
}

@end


