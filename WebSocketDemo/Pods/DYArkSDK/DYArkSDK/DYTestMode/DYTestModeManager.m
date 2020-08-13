//
//  DYTestModeManager.m
//  Exchange
//
//  Created by EasyinWan on 12/06/2018.
//  Copyright © 2018 Consensus. All rights reserved.
//

#ifdef INTELNAL_VERSION

#import "DYTestModeManager.h"
#import <KiwiSDKMacro.h>
#import "YYCategoriesMacro.h"
#import <NSObject+YYAdd.h>
#import <UIDevice+YYAdd.h>
//#import <YYCategories/NSObject+YYAdd.h>
#import "UiUtils.h"
#import "BlocksKit+UIKit.h"
#import "SettingsData.h"
//#import "SettingsDataDef.h"
#import "DYTestModeDef.h"
#import "DYTestModeManager+protocol.h"

NSString * const kNotificationTestEnvChanged = @"kNotificationTestEnvChanged";
NSString * const kNotificationTestModeChanged = @"kNotificationTestModeChanged";
NSString * const kNotificationDYLogInfogerModeChanged = @"kNotificationDYLogInfogerModeChanged";
NSString * const kNotificationTestModeButtonClickChanged = @"kNotificationTestModeButtonClickChanged";
NSString * const kNotificationMonitorMemoryChanged = @"kNotificationMonitorMemoryChanged";

/*
 *  可变参数模板
 */
// 用来终止递归并处理包中最后一个元素
//template <typename T>
//void print(const T &t)
//{
//    kDYLogModuleTest.info(@"%@", t);
//}
//
//// 包中除了最后一个元素之外的其他元素都会调用这个版本的print
//template <typename T, typename...Args>
//void print(const T &t, const Args&...rest)
//{
//    kDYLogModuleTest.info(@"%@", t);     // 打印第一个实参
//    print(rest...);       // 递归调用，打印其他实参
//}
//
//// 测试
//void printTest()
//{
//    //print("string1", 2, 3.14f, "string2", 42);
//    print(@"string1", @"string2");
//}
/*
 *  可变参数模板
 */


@interface DYTestModeManager ()
<
UIGestureRecognizerDelegate
>
{
    CADisplayLink *_displabyLinkForMonitorMemory;
}
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, assign) BOOL isDragingFloatingButton;

@end

@implementation DYTestModeManager

//WF_DEF_SINGLETION(DYTestModeManager);
+ (instancetype)sharedInstance
{
    static DYTestModeManager *_sharedInstance = nil;
    static  dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self.class alloc] init];
    });
    return _sharedInstance;
}

#define INIT_INV(TARGET, _last_arg_, _return_) \
NSMethodSignature * sig = [(TARGET) methodSignatureForSelector:sel]; \
if (!sig) { [(TARGET) doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [(TARGET) doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:(TARGET)]; \
[inv setSelector:sel]; \
va_list args; \
va_start(args, _last_arg_); \
[NSObject setInv:inv withSig:sig andArgs:args]; \
va_end(args);

+ (id (^)(id target, SEL selector, ...))kDYTestManagerPerformSelectorWithArgsInside
{
    return ^ (id target, SEL sel, ...) {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")
        id nilObject = nil;
        INIT_INV(target, sel, nilObject);
        [inv invoke];
        return [NSObject getReturnFromInv:inv withSig:sig];
        _Pragma("clang diagnostic pop")
    };
}

//id kDYTestManagerPerformSelectorWithArgsInside(id target, SEL sel, ...)
//{
//    _Pragma("clang diagnostic push")
//    _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")
//    INIT_INV(target, sel, nil);
//    [inv invoke];
//    return [NSObject getReturnFromInv:inv withSig:sig];
//    _Pragma("clang diagnostic pop")
//}

- (void)setup
{
    [self addNotifications];
    [self setupTest];
    
//    printTest();
    
//    DYTestFuncTwo(^{
//        id a = nil;
//        NSString *str = [NSString stringWithFormat:@"%@", @"test"];
//        DYLogInfo(@"str:%@", str);
//    });
}

/**
 是否测试模式
 
 @return 设置状态
 */
- (BOOL)isEnableTestMode
{
    return [[SettingsData.sharedObject getValueForKey:kSettingKeyEnableTest] boolValue];
}

/**
 当isEnableTestMode为true时，这一项才有意义
 
 @return 设置状态
 */
- (BOOL)isTestSwitchOn
{
    return (self.isEnableTestMode &&
            [[SettingsData.sharedObject getValueForKey:kSettingKeyTestTurnOn] boolValue]);
}

- (void)setupMonitorMemory
{
    BOOL isMonitorMemoryTurnOn = [[SettingsData.sharedObject getValueForKey:kSettingKeyMonitorMemoryTurnOn] boolValue];
    if (self.isEnableTestMode &&
        isMonitorMemoryTurnOn) {
        [self stopMonitorMemory];
        [self startMonitorMemory];
    }
    else {
        [self stopMonitorMemory];
    }
}

- (void)startMonitorMemory
{
    _displabyLinkForMonitorMemory = [CADisplayLink displayLinkWithTarget:self selector:@selector(reloadMemory)];
    [_displabyLinkForMonitorMemory addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMonitorMemory
{
    [_displabyLinkForMonitorMemory invalidate];
    _displabyLinkForMonitorMemory = nil;
    
    BOOL isTestTurnOn = [[SettingsData.sharedObject getValueForKey:kSettingKeyTestTurnOn] boolValue];
    NSString *title = [NSString stringWithFormat:@"测试模式 %@", isTestTurnOn?@"YES":@"NO"];
    [self.floatingButton setTitle:title forState:UIControlStateNormal];
}

- (void)reloadMemory
{
    BOOL isTestTurnOn = [[SettingsData.sharedObject getValueForKey:kSettingKeyTestTurnOn] boolValue];
    NSString *title = [NSString stringWithFormat:@"测试模式 %@\n", isTestTurnOn?@"YES":@"NO"];
    title = [title stringByAppendingFormat:@"总内存:%ldMB\n", (int64_t)(UIDevice.currentDevice.memoryTotal / 1024.f / 1024.f)];
    title = [title stringByAppendingFormat:@"剩内存:%ldMB", (int64_t)(UIDevice.currentDevice.memoryFree / 1024.f / 2014.f)];
    
    [self.floatingButton setTitle:title forState:UIControlStateNormal];
}

/**********************
 *
 **********************/
// Accept any number of args >= N, but expand to just the Nth one.
// Here, N == 6.
#define _GET_NTH_ARG(_1, _2, _3, _4, _5, N, ...) N

// Define some macros to help us create overrides based on the
// arity of a for-each-style macro.
#define _fe_0(_call, ...)
#define _fe_1(_call, x) _call(x)
#define _fe_2(_call, x, ...) _call(x) _fe_1(_call, __VA_ARGS__)
#define _fe_3(_call, x, ...) _call(x) _fe_2(_call, __VA_ARGS__)
#define _fe_4(_call, x, ...) _call(x) _fe_3(_call, __VA_ARGS__)

/**
 * Provide a for-each construct for variadic macros. Supports up
 * to 4 args.
 *
 * Example usage1:
 *     #define FWD_DECLARE_CLASS(cls) class cls;
 *     CALL_MACRO_X_FOR_EACH(FWD_DECLARE_CLASS, Foo, Bar)
 *
 * Example usage 2:
 *     #define START_NS(ns) namespace ns {
 *     #define END_NS(ns) }
 *     #define MY_NAMESPACES System, Net, Http
 *     CALL_MACRO_X_FOR_EACH(START_NS, MY_NAMESPACES)
 *     typedef foo int;
 *     CALL_MACRO_X_FOR_EACH(END_NS, MY_NAMESPACES)
 */
#define CALL_MACRO_X_FOR_EACH(x, ...) \
_GET_NTH_ARG("ignored", ##__VA_ARGS__, \
_fe_4, _fe_3, _fe_2, _fe_1, _fe_0)(x, ##__VA_ARGS__)
/**********************
 *
 **********************/

#pragma mark - notifications
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTest) name:kNotificationTestModeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupMonitorMemory) name:kNotificationMonitorMemoryChanged object:nil];
}

#pragma mark - test
- (void)setupTest
{
    //是否开启测试
    if (self.isEnableTestMode)
    {
        [_floatingButton removeFromSuperview];
        _floatingButton = nil;
        _floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _floatingButton.backgroundColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:0.5f];
        _floatingButton.frame = (CGRect){SCREEN_WIDTH - 56.f, SCREEN_HEIGHT - 56.f - 30.f, 56.f, 56.f};
        _floatingButton.layer.cornerRadius = _floatingButton.frame.size.height * 0.5f;
        _floatingButton.layer.shadowColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.f].CGColor;
        _floatingButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        _floatingButton.layer.shadowOpacity = 0.5f;
        [_floatingButton setTitle:[NSString stringWithFormat:@"测试模式 %@", self.isTestSwitchOn?@"YES":@"NO"] forState:UIControlStateNormal];
        _floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:7.f];
        _floatingButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        _floatingButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _floatingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _floatingButton.titleLabel.numberOfLines = 0;
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:_floatingButton];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(floatingButtonDrag:)];
        panGesture.delegate = self;
        [window addGestureRecognizer:panGesture];
        @weakify(self)
        [_floatingButton bk_addEventHandler:^(id sender) {
            BOOL isTestTurnOn = [[SettingsData.sharedObject getValueForKey:kSettingKeyTestTurnOn] boolValue];
            isTestTurnOn = !isTestTurnOn;
            [SettingsData.sharedObject setValue:@(isTestTurnOn) forKey:kSettingKeyTestTurnOn];
            @strongify(self)
            [self.floatingButton setTitle:[NSString stringWithFormat:@"测试模式 %@", isTestTurnOn?@"YES":@"NO"] forState:UIControlStateNormal];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTestModeButtonClickChanged object:nil];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [_floatingButton removeFromSuperview];
        _floatingButton = nil;
    }
    
    [self setupMonitorMemory];
}

- (void)floatingButtonDrag:(UIPanGestureRecognizer *)panGesture
{
    CGPoint point = [panGesture locationInView:panGesture.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        if (CGRectContainsPoint(_floatingButton.frame, point))
        {
            self.isDragingFloatingButton = YES;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        if (!self.isDragingFloatingButton)
        {
            return;
        }
        CGFloat minX = _floatingButton.frame.size.width * 0.5f;
        CGFloat minY = _floatingButton.frame.size.height * 0.5f;
        CGFloat maxX = SCREEN_WIDTH - minX;
        CGFloat maxY = SCREEN_HEIGHT - minY;
        point.x = MAX(point.x, minX);
        point.x = MIN(point.x, maxX);
        point.y = MAX(point.y, minY);
        point.y = MIN(point.y, maxY);
        
        _floatingButton.center = point;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateFailed)
    {
        self.isDragingFloatingButton = NO;
    }
}

//#define IS_OBJECT(T) _Generic( (T), id: YES, default: NO)

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (_floatingButton &&
        NO == _floatingButton.hidden &&
        CGRectContainsPoint(_floatingButton.frame, point))
    {
        return YES;
    }
    return NO;
}

@end

#endif //end #ifdef INTELNAL_VERSION
