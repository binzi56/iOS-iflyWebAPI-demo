//
//  NSAssertionHandler+DY.m
//  XHX
//
//  Created by EasyinWan on 2019/1/14.
//  Copyright © 2019 XYWL. All rights reserved.
//

#ifdef DEBUG

#import "NSAssertionHandler+DY.h"
#import "NSObject+YYAdd.h"
#import "HYLogMacros.h"

#define ARGS_PARSE()                                                            \
NSString *argString;                                                            \
{                                                                               \
va_list args;                                                                   \
va_start(args, format);                                                         \
argString = [[NSString alloc] initWithFormat:format arguments:args];            \
va_end(args);                                                                   \
}                                                                               \

@implementation NSAssertionHandler (DY)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(handleFailureInMethod:object:file:lineNumber:description:) with:@selector(safe_handleFailureInMethod:object:file:lineNumber:description:)];
        [self swizzleInstanceMethod:@selector(handleFailureInFunction:file:lineNumber:description:) with:@selector(safe_handleFailureInFunction:file:lineNumber:description:)];
    });
}

- (void)safe_handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    ARGS_PARSE();
    [self failureMessageWithReasonString:argString];
    [self safe_handleFailureInMethod:selector object:object file:fileName lineNumber:line description:argString];
}

- (void)safe_handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    ARGS_PARSE();
    [self failureMessageWithReasonString:argString];
    [self safe_handleFailureInFunction:functionName file:fileName lineNumber:line description:format];
}

- (void)failureMessageWithReasonString:(NSString *)reasonString
{
    DYLogInfo(@"*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: '%@' \n*** First throw call stack: \n%@\n", reasonString, [NSThread callStackSymbols]);
}

@end

#endif
