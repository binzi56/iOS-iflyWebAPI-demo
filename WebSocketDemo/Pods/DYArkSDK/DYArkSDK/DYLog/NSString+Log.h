//
//  NSString+Log.h
//  MZAudio
//
//  Created by EasyinWan on 2019/3/14.
//  Copyright © 2019 XYWL. All rights reserved.
//

/*
 *  log模块定义
 *
 *  例如定义一个叫"Abc"的模块
 *  DYLogModule(Abc);
 *
 *  使用时:
 *  kDYLogModuleAbc.dyLogInfo(@"test log");
 *
 */


#import <Foundation/Foundation.h>
#import "HYLogProtocol.h"

#ifndef NSString_Log
#define NSString_Log

#ifdef debug
#error Redefined marco debug
#endif

#ifdef info
#error Redefined marco info
#endif

#ifdef warn
#error Redefined marco warn
#endif

#ifdef error
#error Redefined marco error
#endif

#ifdef fatal
#error Redefined marco fatal
#endif

typedef void (^NSStringLogBlock)(HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...);

#define dyLogMacro(LEVEL, format, ...) \
p_dyLogInfo((LEVEL), __FILE__, __LINE__, __FUNCTION__, (format), ##__VA_ARGS__);

#define debug(format, ...) \
dyLogMacro(HYLogLevelDebug, format, ##__VA_ARGS__);

#define info(format, ...) \
dyLogMacro(HYLogLevelInfo, format, ##__VA_ARGS__);

#define warn(format, ...) \
dyLogMacro(HYLogLevelWarn, format, ##__VA_ARGS__);

#define error(format, ...) \
dyLogMacro(HYLogLevelError, format, ##__VA_ARGS__);

#define fatal(format, ...) \
dyLogMacro(HYLogLevelFatal, format, ##__VA_ARGS__);

#define DYLogModule(MODULE) \
static NSString * const kDYLogModule##MODULE = @""#MODULE;

@interface NSString (Log)

#pragma mark - Public
- (NSStringLogBlock)debug;
- (NSStringLogBlock)info;
- (NSStringLogBlock)warn;
- (NSStringLogBlock)error;
- (NSStringLogBlock)fatal;

#pragma mark - Private
- (NSStringLogBlock)p_dyLogDebug;
- (NSStringLogBlock)p_dyLogInfo;
- (NSStringLogBlock)p_dyLogWarn;
- (NSStringLogBlock)p_dyLogError;
- (NSStringLogBlock)p_dyLogFatal;

@end

#endif
