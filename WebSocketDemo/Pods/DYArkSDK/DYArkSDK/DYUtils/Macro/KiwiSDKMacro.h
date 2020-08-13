//
//  CommonMacros.h
//  KiwiSDK
//
//  Created by Gideon on 2018/3/8.
//  Copyright © 2018年 YY.Inc. All rights reserved.
//

#ifndef CommonMacros_h
#define CommonMacros_h


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <HexColors/HexColors.h>
#import "VersionHelper.h"
#import "HYProgressHUD.h"

//utils
#import "UiUtils.h"
#import "StringUtils.h"
#import "NetWorkUtils.h"
#import "HYFHTTPManager.h"

//fundation
#import "NSMutableArray+YYAdd.h"
#import "NSDictionary+KWS.h"
#import "NSMutableDictionary+KWS.h"
#import "NSString+KWS.h"

//UIKit
//#import "UIView+KWS.h"
//#import "UIView+KWSLayout.h"
//#import "UILabel+KWS.h"
//#import "UIImageView+KWS.h"
//#import "UIImage+KWS.h"
//#import "UIWebView+KWS.h"
#import "UIDevice+KWS.h"

//Log
#import "HYLogMacros.h"

//Thread
#import "HYGCDQueuePool.h"

/**************** Macros For Localization ****************/

//如果支持多语言，可以用下面这个
//#define KiwiLocalizedString(key, comment) \
//(([[[NSLocale preferredLanguages] objectAtIndex:0] isEqual:@"zh-Hans"])?([[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]):([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil]))

//目前只有简体中文，暂时用这个
#define KiwiLocalizedString(key, comment) \
([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil])

#define L(key) KiwiLocalizedString(key, nil)

/**************** Macros For String ****************/

#define StdStringFromNSString(str) [str UTF8String]
#define NSStringFromStdString(str) [NSString stringWithUTF8String:((str).data())]
#define NSStringFromInt(d) [NSString stringWithFormat:@"%d", (d)]
#define NSStringFromLong(d) [NSString stringWithFormat:@"%lld", (d)]
#define NSStringFromUInt32(u) [NSString stringWithFormat:@"%u", (u)]
#define NSStringFromFloat(f) [NSString stringWithFormat:@"%f", (f)]
#define NSStringFromDouble(f) [NSString stringWithFormat:@"%lf", (f)]
#define NSStringConcat(str1, str2) [NSString stringWithFormat:@"%@%@", (str1), (str2)]
#define NSStringConcat3(str1, str2, str3) [NSString stringWithFormat:@"%@%@%@", (str1), (str2), (str3)]
#define NSStringFromNSData(data) [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
#define NSDataFromNSString(str) [str dataUsingEncoding:NSUTF8StringEncoding]

/**************** Macros For Float Compare ****************/

#define cDefaultFloatComparisonEpsilon    0.0001
#define cEqualFloats(f1, f2, epsilon)     ( fabs( (f1) - (f2) ) < epsilon )
#define cNotEqualFloats(f1, f2, epsilon)  ( !cEqualFloats(f1, f2, epsilon) )
#define cIsEqualFloatZero(f)              ( fabs( (f) - 0.0000 ) < cDefaultFloatComparisonEpsilon )

/**************** Macros For safe Calling ****************/

#define __CALL(x,...) if(x) { x(__VA_ARGS__); }

#if defined(DEBUG)
#define __DBUGAssert(e) \
(__builtin_expect(!(e), 0) ? __assert(#e, __FILE__, __LINE__) : (void)0)
#else
#define __DBUGAssert(e) ((void)0)
#endif

/* MONAssert assertion is active at all times, including release builds. */

#define __DAssert(e) \
(__builtin_expect(!(e), 0) ? __assert(#e, __FILE__, __LINE__) : (void)0)


/**************** Macros    For safe Check ****************/

#define __IF_DO(exp, stuff) if((exp)) { stuff; }

#define __CHECK(exp) if(!(exp)) { return; }

#define __CHECK_RET(exp, x) if(!(exp)) { return x; }

#define __CHECK_ASSERT(exp) if(!(exp)) { KWSLogDebug(@"FAILED CHECK:%@", @#exp); __DBUGAssert(false); return;}

#define __CHECK_ASSERT_RET(exp, x) if(!(exp)) { KWSLogDebug(@"FAILED CHECK:%@", @#exp); __DBUGAssert(false); return x;}


/**************** Macros For iOS version ****************/

#define iOS7_Adjust_TableViewSeparatorInset(t)  if (!SystemVersionLessThan(@"7.0")) { t.separatorInset = UIEdgeInsetsZero; }

/**************** Block ****************/

/**
 * 弱引用定义
 */
#define BlockWeakSelf(weakSelf, self)   __weak typeof(self) weakSelf = self

/**
 * 强引用定义
 */
#define BlockStrongSelf(strongSelf, weakSelf)   __strong typeof(weakSelf) strongSelf = weakSelf

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#define HYCAAnimationDelegate CAAnimationDelegate
#else
#define HYCAAnimationDelegate NSObject
#endif


/**************** log/call in debug/internal mode ****************/

#ifdef DEBUG
#define HYLogInDebug(frmt, ...) KWSLogDebug(frmt, ##__VA_ARGS__)
#else
#define HYLogInDebug(frmt, ...)
#endif

#ifdef HYINTERNAL
#define HYCallInInternal(str) str
#else
#define HYCallInInternal(str)
#endif

/**************** Macros For iOS version ****************/

#define SystemVersionLessThan(v) ([[[UIDevice currentDevice] hy_systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

/**************** Macros For Device ****************/

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

/**************** 通知 ****************/

/**
 * 通知声明
 */
#define N_Dec(notification) extern NSString * const notification

/**
 * 通知定义
 */
#define N_Def(notification) NSString * const notification = @#notification

//目前只有简体中文，暂时用这个
#ifndef KWBaseL

#define KiwiBaseLocalizedString(key, comment) \
([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil])

#define KWBaseL(key) KiwiBaseLocalizedString(key, nil)

#endif


#define IS_LOW_PERFORMANCE_DEVICE   [[UIDevice currentDevice] isLowPerformanceDevice]
#define IS_LOWER_THAN_IPAD3         [[UIDevice currentDevice] isLowerThanIPad3]
#define IS_IPHONE4S_OR_LOWER        [[UIDevice currentDevice] isIPhone4sOrLower]
#define IS_IPHONE6_OR_LOWER         [[UIDevice currentDevice] isIPhone6OrLower]
#define IS_IPHONE5                  [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 5"]
#define IS_IPHONE5C                 [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 5c"]
#define IS_IPHONE5S                 [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 5s"]
#define IS_IPHONE6                  [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 6"]
#define IS_IPHONE6_PLUS             [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 6 Plus"]
#define IS_IPHONE6S                 [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 6s"]
#define IS_IPHONE6S_PLUS            [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone 6s Plus"]
#define IS_IPHONESE                 [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone SE"]

#if TARGET_IPHONE_SIMULATOR
#define IS_IPHONEX                  (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812.0,375.0)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375.0, 812.0)))
#else
#define IS_IPHONEX                  [[UIDevice currentDevice].machineModelName isEqualToString:@"iPhone X"]
#endif

/************************String*************************/

#define SAFE_UTF8STRING(str) (str != nil ? [str UTF8String] : "")
#define SAFE_STRING(str) str != nil ? str : @""

/************************实例相关*************************/
#define WF_AS_SINGLETION( __class ) \
+ (__class *)sharedInstance;

#define WF_DEF_SINGLETION( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

////测试
//#ifdef INTELNAL_VERSION
//    #import "DYTestModeManager.h"
//    #define kDYTest(VAL) do{VAL}while(0)
//    #define kDYTestOnlyAssert                                                   \
//        if (![DYTestModeManager sharedInstance].isTestSwitchOn)                       \
//        {                                                                       \
//            NSAssert(NO, @"func %@ is test only", NSStringFromSelector(_cmd));  \
//            return;                                                             \
//        }
//    #define kDYTestIgnoredUndeclaredSelector(VAL) \
//        _Pragma("clang diagnostic push") \
//        _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
//        do{VAL}while(0)   \
//        _Pragma("clang diagnostic pop")
//#else
//    #define kDYTest(VAL)
//    #define kDYTestOnlyAssert return;
//    #define kDYTestIgnoredUndeclaredSelector(VAL)
//#endif

/**
 *  Easyin
 *  Begin ===>
 *  Syntactic sugar from ReactiveCocoa
 *
 *  How to use:
 *  e.g.
 *  @weakify(self)
 *  [self block:^ {
 *      @strongify(self)
 *      [self doSomething];
 *  }
 **/
#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")
#endif
#endif
/**
 *  Easyin
 *  End <===
 *  Syntactic sugar from ReactiveCocoa
 **/

/**
 *  Easyin
 *  Begin ===>
 *  check property's value and class
 *  throw exception in DEBUG mode
 *  return YES or NO in RELEASE mode
 *
 **/
#ifndef DYFetchPropertyName
#define DYFetchPropertyName(VAL) (@""#VAL)
#endif

#ifndef DYFetchClass
#define DYFetchClass(VAL) ([VAL class])
#endif

#ifndef DYIsValid
#define DYIsValid(VAL) (VAL)
#endif

#ifndef DYIsKindOfClass
#define DYIsKindOfClass(VAL, CLASS) ([VAL isKindOfClass:[CLASS class]])
#endif

#ifndef DYCheckInvalidAndKindOfClass

    #ifdef DEBUG
        #define DYCheckInvalidAndKindOfClass(VAL, CLASS)                                                                                                                    \
        (                                                                                                                                                                   \
        (                                                                                                                                                                   \
            (!DYIsValid(VAL)) ?                                                                                                                                             \
            ({NSAssert(NO, @"NSAssert => %s Line %d\nInvalid value of \"%@\" ", __PRETTY_FUNCTION__, __LINE__, DYFetchPropertyName(VAL));YES;})                             \
            : NO                                                                                                                                                            \
        )                                                                                                                                                                   \
        ||                                                                                                                                                                  \
        (                                                                                                                                                                   \
            (!DYIsKindOfClass((VAL), CLASS)) ?                                                                                                                                \
            ({NSAssert(NO, @"NSAssert => %s Line %d\nexpected class \"%@\" but class \"%@\" given ", __PRETTY_FUNCTION__, __LINE__, [CLASS class], DYFetchClass(VAL));YES;})  \
            : NO                                                                                                                                                            \
        )                                                                                                                                                                   \
        )
    #else
        #define DYCheckInvalidAndKindOfClass(VAL, CLASS)                                                                                                                      \
        (                                                                                                                                                                   \
        (                                                                                                                                                                   \
            (!DYIsValid(VAL)) ?                                                                                                                                            \
            ({                                                                                                                                                              \
                DYLogError(@"%s Line %d\nInvalid value of \"%@\" ", __PRETTY_FUNCTION__, __LINE__, DYFetchPropertyName(VAL));                                                 \
                YES;                                                                                                                                                        \
            })                                                                                                                                                              \
            : NO                                                                                                                                                            \
        )                                                                                                                                                                   \
        ||                                                                                                                                                                  \
        (                                                                                                                                                                   \
            (!DYIsKindOfClass((VAL), CLASS)) ?                                                                                                                                \
            ({                                                                                                                                                              \
                DYLogError(@"%s Line %d\nexpected class \"%@\" but class \"%@\" given ", __PRETTY_FUNCTION__, __LINE__, [CLASS class], DYFetchClass(VAL));                    \
                YES;                                                                                                                                                        \
            })                                                                                                                                                              \
            : NO                                                                                                                                                            \
        )                                                                                                                                                                   \
        )
    #endif

#endif
/**
 *  Easyin
 *  End <===
 *  check property's value and class
 *  throw exception in DEBUG mode
 *  return YES or NO in RELEASE mode
 *
 **/

#endif /* CommonMacros_h */
