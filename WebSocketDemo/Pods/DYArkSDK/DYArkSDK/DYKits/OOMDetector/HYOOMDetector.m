////  HYOOMDetector.m
//  kiwi
//
//  Created by Haisheng Ding on 2018/5/10.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

#import "HYOOMDetector.h"
#import "KiwiSDKMacro.h"

static NSString *kDDOOMDetectorUserDefaultsKey = @"kDDOOMDetectorUserDefaultsKeyName";
static NSString *kSystemVersionKey = @"SystemVersion";
static NSString *kAppVersionKey = @"AppVersion";
static NSString *kAppStateKey = @"AppState";
static NSString *kAppTerminateTypeKey = @"TerminateType";
static NSString *kDeviceBootTimeKey = @"DeviceBootTime";

static NSString *kAppTerminateTypeCrash = @"Crash";
static NSString *kAppTerminateTypeExit = @"Exit";
static NSString *kAppTerminateTypeTerminate = @"Terminate";

static NSString *kAppStateActive = @"Active";
static NSString *kAppStateInactive = @"Inactive";
static NSString *kAppStateBackground = @"Background";

static NSString *kMemoryWarningInfoKey =  @"MemoryWarningInfo";

@interface HYOOMDetector ()

@property (nonatomic, strong)NSDictionary *lastState;
@property (nonatomic, strong)NSMutableDictionary *currentState;
@property (nonatomic, strong)NSOperationQueue *queue;
@property (nonatomic, strong)NSString *stateFilePath;
@property (nonatomic, assign)NSInteger totalWarningTimes;
@end

@implementation HYOOMDetector

#pragma mark - public

+ (instancetype)sharedInstance {
    static HYOOMDetector * s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [HYOOMDetector new];
    });
    
    return s_instance;
}

+ (void)startDetectWithLastStatusHandle:(void(^)(HYTerminateType terminateType,NSString* warningInfo))handle {
    return [[HYOOMDetector sharedInstance] startDetectWithLastStatusHandle:handle];
}

+ (void)logExit {
    return [[HYOOMDetector sharedInstance] logExit];
}

+ (void)logCrash {
    return [[HYOOMDetector sharedInstance] logCrash];
}

+ (NSString*)stringFromTerminateType:(HYTerminateType)terminateType {
    NSString *strType = nil;
    switch (terminateType) {
        case 0:
            strType = @"HYTerminateTypeAppLaunchAfterFirstInstall";
            break;
        case 1:
            strType = @"HYTerminateTypeAppUpgrade";
            break;
        case 2:
            strType = @"HYTerminateTypeCrash";
            break;
        case 3:
            strType = @"HYTerminateTypeExit";
            break;
        case 4:
            strType = @"HYTerminateTypeTerminate";
            break;
        case 5:
            strType = @"HYTerminateTypeOSUpgrade";
            break;
        case 6:
            strType = @"HYTerminateTypeDeviceReboot";
            break;
        case 7:
            strType = @"HYTerminateTypeActiveFoom";
            break;
        case 8:
            strType = @"HYTerminateTypeInactiveFoom";
            break;
        case 9:
            strType = @"HYTerminateTypeBoom";
            break;
        default:
            strType = @"HYTerminateTypeUnknown";
            break;
    }
    return strType;
}

#pragma mark - private

- (instancetype)init {
    if (self = [super init]) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.currentState = [NSMutableDictionary new];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.stateFilePath = [documentsDirectory stringByAppendingPathComponent:@"HYameOOMInfo.plist"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningNotificationHandle:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)readLastState {
    @synchronized (self) {
        [self.currentState setObject:[self systemVersion] forKey:kSystemVersionKey];
        [self.currentState setObject:[self appVersion] forKey:kAppVersionKey];
        [self.currentState setObject:[self deviceBootTime] forKey:kDeviceBootTimeKey];
        if ([[NSFileManager defaultManager] fileExistsAtPath: self.stateFilePath])
        {
            self.lastState = [[NSMutableDictionary alloc] initWithContentsOfFile:self.stateFilePath];
        }
    };
    
    [self synchronizeLastState];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startDetectWithLastStatusHandle:(void(^)(HYTerminateType terminateType,NSString* warningInfo))handle {
    [self.queue addOperationWithBlock:^{
        [self readLastState];
        HYTerminateType lastTerminateType= HYTerminateTypeUnknown;
        if ([self isFirstLaunchAfterInstall]) {
            lastTerminateType = HYTerminateTypeAppLaunchAfterFirstInstall;
        } else if ([self isAppCrashed]) {
            lastTerminateType = HYTerminateTypeCrash;
        } else if ([self isAppExited]) {
            lastTerminateType = HYTerminateTypeExit;
        } else if ([self isAppTerminated]) {
            lastTerminateType = HYTerminateTypeTerminate;
        } else if ([self isAppUpgraded]) {
            lastTerminateType = HYTerminateTypeAppUpgrade;
        } else if ([self isSystemUpgraded]) {
            lastTerminateType = HYTerminateTypeOSUpgrade;
        } else if ([self isDeviceReboot]) {
            lastTerminateType = HYTerminateTypeDeviceReboot;
        } else {
            NSString *appstate = [self.lastState objectForKey:kAppStateKey];
            if ([appstate isEqualToString:kAppStateBackground]) {
                lastTerminateType = HYTerminateTypeBoom;
            } else if ([appstate isEqualToString:kAppStateActive]) {
                lastTerminateType = HYTerminateTypeActiveFoom;
            } else if ([appstate isEqualToString:kAppStateInactive]) {
                lastTerminateType = HYTerminateTypeInactiveFoom;
            }
        }
        if (handle) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                handle(lastTerminateType, [self.lastState objectForKey:kMemoryWarningInfoKey]);
            });
        }
    }];
}

- (BOOL)isFirstLaunchAfterInstall {
    BOOL bRet = FALSE;
    if (!self.lastState) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isAppCrashed {
    BOOL bRet = FALSE;
    NSString *terminateType = [self.lastState objectForKey:kAppTerminateTypeKey];
    if ([terminateType isEqualToString:kAppTerminateTypeCrash]) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isAppExited {
    BOOL bRet = FALSE;
    NSString *terminateType = [self.lastState objectForKey:kAppTerminateTypeKey];
    if ([terminateType isEqualToString:kAppTerminateTypeExit]) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isAppTerminated {
    BOOL bRet = FALSE;
    NSString *terminateType = [self.lastState objectForKey:kAppTerminateTypeKey];
    if ([terminateType isEqualToString:kAppTerminateTypeTerminate]) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isAppUpgraded {
    BOOL bRet = FALSE;
    NSString *lastAppVersion = [self.lastState objectForKey:kAppVersionKey];
    if (![lastAppVersion isEqualToString:[self appVersion]]) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isSystemUpgraded {
    BOOL bRet = FALSE;
    NSString *lastSystemVersion = [self.lastState objectForKey:kSystemVersionKey];
    if (![lastSystemVersion isEqualToString:[self systemVersion]]) {
        bRet = YES;
    }
    return bRet;
}

- (BOOL)isDeviceReboot {
    BOOL bRet = FALSE;
    NSString *appstate = [self.lastState objectForKey:kAppStateKey];
    NSString *lastBootTime = [self.lastState objectForKey:kDeviceBootTimeKey];
    //如果app在前台，关机将会收到terminate通知
    if (![lastBootTime isEqualToString:[self deviceBootTime]] && ![appstate isEqualToString:kAppTerminateTypeTerminate]) {
        bRet = YES;
    }
    return bRet;
}

- (void)logExit {
    [self syncSetState:kAppTerminateTypeExit forKey:kAppTerminateTypeKey];
}

- (void)logCrash {
    [self syncSetState:kAppTerminateTypeCrash forKey:kAppTerminateTypeKey];
}

- (void)logMemoryWarningInfo:(NSString*)info {
    [self setState:info forKey:kMemoryWarningInfoKey];
}

//exit,crash,terminate必须同步调用，否则可能来不及记录app就退出了
- (void)syncSetState:(NSString*)state forKey:(NSString*)key {
    @synchronized (self) {
        [self.currentState setObject:state forKey:key];
    }
    [self synchronizeLastState];
}


- (void)setState:(NSString*)state forKey:(NSString*)key {
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        [weakSelf syncSetState:state forKey:key];
    }];
}

- (void)synchronizeLastState {
    @synchronized (self) {
        if (self.currentState.count) {
            [self.currentState writeToFile:self.stateFilePath atomically:YES];
        }
    }
}



- (NSString*)appVersion {
    static dispatch_once_t once;
    static NSString *s_appVersion=@"";
    dispatch_once(&once, ^{
        s_appVersion = [[NSBundle mainBundle].infoDictionary valueForKey:(NSString*)kCFBundleVersionKey];
    });
    return s_appVersion;
}

- (NSString*)systemVersion {
    static dispatch_once_t onceToken;
    static NSString *s_systemVersion=@"";
    dispatch_once(&onceToken, ^{
        s_systemVersion = [[UIDevice currentDevice] systemVersion];
    });
    return s_systemVersion;
}

- (NSString*)deviceBootTime {
    static NSString *s_deviceBootTime=@"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#define MIB_SIZE 2
        
        int mib[MIB_SIZE];
        size_t size;
        struct timeval  boottime;
        
        mib[0] = CTL_KERN;
        mib[1] = KERN_BOOTTIME;
        size = sizeof(boottime);
        if (sysctl(mib, MIB_SIZE, &boottime, &size, NULL, 0) != -1)
        {
            s_deviceBootTime = [NSString stringWithFormat:@"%ld.%d", boottime.tv_sec, boottime.tv_usec];
        }
    });
    return s_deviceBootTime;
}

#pragma mark - notification handle

- (void)handleDidEnterBackgroundNotification:(NSNotification*)notification {
    [self setState:kAppStateBackground forKey:kAppStateKey];
}

- (void)handleDidBecomeActiveNotification:(NSNotification*)notification {
    [self setState:kAppStateActive forKey:kAppStateKey];
}

- (void)handleWillResignActiveNotification:(NSNotification*)notification {
    [self setState:kAppStateInactive forKey:kAppStateKey];
}

- (void)handleWillTerminateNotification:(NSNotification*)notification {
    [self syncSetState:kAppTerminateTypeTerminate forKey:kAppTerminateTypeKey];
}

- (void)memoryWarningNotificationHandle:(NSNotification*)notification {
    ++_totalWarningTimes;
    NSString *warningInfo = [NSString stringWithFormat:@"warning times:%ld available mem:%.2f resident mem:%.2f phys mem:%.2f current VC:%@",(long)_totalWarningTimes, [self deviceAvailableMemory], [self appResidentMemory], [self appPhysicalMemory], NSStringFromClass([[self topViewController] class])];
    [self logMemoryWarningInfo:warningInfo];
}

#pragma mark - memory profiler

- (CGFloat)deviceAvailableMemory {
    CGFloat availableMem = 0.0;
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t infoCount =HOST_VM_INFO64_COUNT;
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    kern_return_t kernReturn = host_statistics64(mach_host_self(),
                                                 HOST_VM_INFO64,
                                                 (host_info64_t)&vmStats,
                                                 &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        KWSLogInfo(@"deviceAvailableMemory failed:%d", kernReturn);
        return availableMem;
    }
    
    availableMem = ((pagesize *(vmStats.free_count + vmStats.inactive_count)) /1024.0) / 1024.0;
    return availableMem;
}
- (CGFloat)appResidentMemory {
    CGFloat residentMem = 0.0;
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kernReturn != KERN_SUCCESS ) {
        KWSLogInfo(@"appResidentMemory failed:%d", kernReturn);
        return residentMem;
    }
    residentMem = info.resident_size / (1024.0 * 1024.0);
    
    return residentMem;
}

- (CGFloat)appPhysicalMemory {
    int64_t physMem = 0.0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn != KERN_SUCCESS) {
        KWSLogInfo(@"appPhysicalMemory failed:%d", kernelReturn);
        return physMem;
    }
    
    return (int64_t) vmInfo.phys_footprint / 1024.0 / 1024.0;
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topViewController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewController:rootViewController.presentedViewController];
    }
    //hard coding for HYRootViewController!!!!
    if ([NSStringFromClass([rootViewController class]) isEqualToString:@"HYRootViewController"]) {
        UINavigationController *nav = [rootViewController valueForKey:@"embedNavigationController"];
        if (nav) {
            return [self topViewController:nav];
        }
    }
    
    return rootViewController;
}
@end
