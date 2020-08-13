//
//  NSNotificationCenter+DY.m
//  DYArkSDK
//
//  Created by EasyinWan on 2018/11/5.
//

#warning TODO 卡线程，待优化
#ifdef TMP_CLOSE
//#ifdef INTELNAL_VERSION

#import "NSNotificationCenter+DY.h"

#import <mach/mach.h>
#import <execinfo.h>

#import <objc/runtime.h>
#import "NSObject+YYAdd.h"
#import "HYLogMacros.h"

@implementation NSNotificationCenter (DY)

+ (void)load
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(postNotificationName:object:userInfo:) with:@selector(HY_postNotificationName:object:userInfo:)];
        [self swizzleInstanceMethod:@selector(postNotification:) with:@selector(HY_postNotification:)];
    });
}

- (void)HY_postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    [self logWithNotificationName:aName object:anObject userInfo:aUserInfo];
    [self HY_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)HY_postNotification:(NSNotification *)notification
{
    [self logWithNotificationName:notification.name object:notification.object userInfo:notification.userInfo];
    [self HY_postNotification:notification];
}

- (void)logWithNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    static NSArray *ignoreList = @[@"UITextSelectionDidScroll",
                                   @"UITextSelectionWillScroll",
                                   @"UIScrollViewAnimationEndedNotification",
                                   @"UIViewAnimationDidStopNotification",
                                   @"UIViewAnimationDidCommitNotification",
                                   @"NSTextViewWillChangeNotifyingTextViewNotification",
                                   ];
    static NSArray *greedyIgnoreList = @[@"Progress"];
    
    for (NSString *notiName in ignoreList)
    {
        if ([aName isEqualToString:notiName])
        {
            return;
        }
    }
    
    for (NSString *ignoreWord in greedyIgnoreList)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([aName containsString:ignoreWord])
#pragma clang diagnostic pop
        {
            return;
        }
    }
    
    const int length = 3;
    void *callStack[length];
    int frames = backtrace(callStack, length);
    if (frames < length) return;
    #warning TODO 这一句卡线程，待优化
    char **strs = backtrace_symbols(callStack, frames);
    NSString *preStack = [NSString stringWithUTF8String:strs[length - 1]];
    free(strs);
    
    NSRange range = [preStack rangeOfString:@"-["];
    if (NSNotFound == range.location) {
        range = [preStack rangeOfString:@"+["];
        if (NSNotFound == range.location) return;
    }
    preStack = [preStack substringFromIndex:range.location];
    
    NSString *logStr = @"\n **** NSNotificationCenter POST ****";
    logStr = [logStr stringByAppendingFormat:@"\n * SEL  : %@", preStack];
    logStr = [logStr stringByAppendingFormat:@"\n * NAME : %@", aName];
    if (anObject) logStr = [logStr stringByAppendingFormat:@"\n * OBJ  : [%@] %@", [anObject class], anObject];
    if (aUserInfo) logStr = [logStr stringByAppendingFormat:@"\n * INFO : [%@] %@", [aUserInfo class], aUserInfo];
    logStr = [logStr stringByAppendingFormat:@"\n **** "];
    DYLogInfo(@"%@", logStr);
}

@end

#endif
