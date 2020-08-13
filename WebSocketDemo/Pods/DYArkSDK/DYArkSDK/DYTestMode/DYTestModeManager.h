//
//  DYTestModeManager.h
//  Exchange
//
//  Created by EasyinWan on 12/06/2018.
//  Copyright © 2018 Consensus. All rights reserved.
//

#ifdef INTELNAL_VERSION

#import <UIKit/UIKit.h>

extern NSString * const kNotificationTestEnvChanged;
extern NSString * const kNotificationTestModeChanged;
extern NSString * const kNotificationDYLogInfogerModeChanged;
extern NSString * const kNotificationTestModeButtonClickChanged;
extern NSString * const kNotificationMonitorMemoryChanged;

#define kSettingKeyTestServerType @"kSettingKeyTestServerType"
#define kSettingKeyTestServerSubEnv @"kSettingKeyTestServerSubEnv"
#define kSettingKeyTestTurnOn @"kSettingKeyTestTurnOn"
#define kSettingKeyEnableTest @"kSettingKeyEnableTest"
#define kSettingKeyMonitorMemoryTurnOn @"kSettingKeyMonitorMemoryTurnOn"

#define kDYTestManagerPerformSelectorWithArgs(TARGET, SEL, ...)                 \
_Pragma("clang diagnostic push")                                                \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")                   \
DYTestModeManager.kDYTestManagerPerformSelectorWithArgsInside((TARGET), (SEL), ##__VA_ARGS__)     \
_Pragma("clang diagnostic pop")

//@compatibility_alias
//@compatibility_alias UICollectionViewController PSTCollectionViewController;

//打印宏展开后的函数
#define __toString(x) __toString_0(x)
#define __toString_0(x) #x
#define DYTestManager_LOG_MACRO(x) DYLogInfo(@"%s=\n%s", #x, __toString(x))

@interface DYTestModeManager : NSObject

//WF_AS_SINGLETION(DYTestModeManager);
+ (instancetype)sharedInstance;

+ (id (^)(id target, SEL selector, ...))kDYTestManagerPerformSelectorWithArgsInside;
//id kDYTestManagerPerformSelectorWithArgsInside(id target, SEL selector, ...);

- (void)setup;

- (void)setupTest;

- (BOOL)isTestSwitchOn;

@end

#endif //end #ifdef INTELNAL_VERSION
