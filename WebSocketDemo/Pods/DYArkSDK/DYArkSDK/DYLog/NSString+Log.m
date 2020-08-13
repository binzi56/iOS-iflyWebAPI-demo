//
//  NSString+Log.m
//  MZAudio
//
//  Created by EasyinWan on 2019/3/14.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "NSString+Log.h"
#import "HYLog.h"

@implementation NSString (Log)

- (NSStringLogBlock)p_dyLogDebug    { return self.p_dyLog; }
- (NSStringLogBlock)p_dyLogInfo     { return self.p_dyLog; }
- (NSStringLogBlock)p_dyLogWarn     { return self.p_dyLog; }
- (NSStringLogBlock)p_dyLogError    { return self.p_dyLog; }
- (NSStringLogBlock)p_dyLogFatal    { return self.p_dyLog; }

- (NSStringLogBlock)p_dyLog
{
    return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {
        NSAssert(format, @"参数不能为空");
        
        va_list argList;
        va_start(argList, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
        
        [HYLog logWithLevel:level
                     module:self
                   fileName:fileName
                    lineNum:lineNum
                   funcName:funcName
                    message:message];
    };
}

#pragma mark - never be called because of macro
- (NSStringLogBlock)debug  {return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {};}
- (NSStringLogBlock)info   {return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {};}
- (NSStringLogBlock)warn   {return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {};}
- (NSStringLogBlock)error  {return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {};}
- (NSStringLogBlock)fatal  {return ^ (HYLogLevel level, const char *fileName, int32_t lineNum, const char *funcName, NSString *format, ...) {};}

@end
