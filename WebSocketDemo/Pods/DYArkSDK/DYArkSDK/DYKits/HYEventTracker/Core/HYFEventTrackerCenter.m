////  HYFEventTrackerCenter.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventTrackerCenter.h"

#import <UIKit/UIKit.h>

#import "UIViewController+HYFEventTracker.h"
#import "UINavigationController+HYFEventTracker.h"
#import "UITableView+HYFEventTracker.h"
#import "UICollectionView+HYFEventTracker.h"
#import "UIControl+HYEventTracker.h"
#import "HYFNormalEvent.h"
#import "ETCircularQueue.h"

@interface HYFEventTrackerCenter ()

@property (nonatomic, assign)NSInteger maxEventCount;
@property (nonatomic, strong)dispatch_queue_t eventRecordQueue;
@property (nonatomic, strong)NSMutableDictionary *textContainer;
@property (nonatomic, strong)ETCircularQueue *eventContainer;
@property (nonatomic, assign)NSUInteger sequence;

@property (nonatomic, strong)NSMutableDictionary *methodContainer;
@end

@implementation HYFEventTrackerCenter
{
    volatile NSUInteger _isStarted;
}

+ (instancetype)sharedInstance {
    static HYFEventTrackerCenter * s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [HYFEventTrackerCenter new];
    });
    return s_instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.eventRecordQueue = dispatch_queue_create("com.huya.EventTrackerQueue", DISPATCH_QUEUE_SERIAL);
        self.maxEventCount = 300;
        _isStarted = 0;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark public
- (void)addEvent:(HYFEventBase*)event {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.eventRecordQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        event.sequence = [strongSelf currentSequence];
        [strongSelf.eventContainer addObject:event];
    });
}

- (void)startTrace {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doStart];
        });
    });
}

- (void)setMaxEventCount:(NSInteger)maxEventCount {
    _maxEventCount = maxEventCount;
}

- (void)addEventWithName:(NSString*)name event:(NSString*)event {
    if (!_isStarted) {
        return;
    }
    HYFNormalEvent *normalEvent = [[HYFNormalEvent alloc] initWithName:name event:event];
    [self addEvent:normalEvent];
}

- (void)recordText:(NSString*)text key:(NSString*)key {
    if (!_isStarted) {
        return;
    }
    
    if (!key || !text) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *copyText = [text copy];
    NSString *copyKey = [key copy];
    dispatch_async(self.eventRecordQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.textContainer setObject:copyText forKey:copyKey];
    });
}

- (NSString*)fullTraces {
    if (!_isStarted) {
        return nil;
    }
    NSMutableString *traces = [NSMutableString new];
    dispatch_sync(self.eventRecordQueue, ^{
        [traces appendString:[self stringFromRecordTraces]];
        [traces appendString:@"\n"];
        [traces appendString:[self stringFromEventTraces]];
    });
    return traces;
}

- (NSString*)eventTraces {
    if (!_isStarted) {
        return nil;
    }
    NSMutableString *traces = [NSMutableString new];
    dispatch_sync(self.eventRecordQueue, ^{
        [traces appendString:[self stringFromEventTraces]];
    });
    return traces;
}

- (NSString*)recordTraces {
    if (!_isStarted) {
        return nil;
    }
    NSMutableString *traces = [NSMutableString new];
    dispatch_sync(self.eventRecordQueue, ^{
        [traces appendString:[self stringFromRecordTraces]];
    });
    return traces;
}

#pragma mark private

- (NSUInteger)currentSequence {
    return self.sequence++;
}

- (NSMutableDictionary*)textContainer {
    if (!_textContainer) {
        _textContainer = [NSMutableDictionary new];
    }
    return _textContainer;
}

- (ETCircularQueue*)eventContainer {
    if (!_eventContainer) {
        _eventContainer = [[ETCircularQueue alloc] initWithCapacity:self.maxEventCount];
    }
    return _eventContainer;
}

- (void)doStart {
    [self swizzle];
    [self addNotificationObservers];
    __sync_fetch_and_add(&_isStarted, 1);
}

- (void)swizzle {
    [UIViewController ET_swizzle];
    [UINavigationController ET_swizzle];
    [UITableView ET_swizzle];
    [UICollectionView ET_swizzle];
    [UIControl ET_swizzle];
}

#pragma mark notification observer
- (void)addNotificationObservers {
    [self addNotificationObserver:UIApplicationDidEnterBackgroundNotification];
    [self addNotificationObserver:UIApplicationWillEnterForegroundNotification];
    [self addNotificationObserver:UIApplicationDidFinishLaunchingNotification];
    [self addNotificationObserver:UIApplicationDidBecomeActiveNotification];
    [self addNotificationObserver:UIApplicationWillResignActiveNotification];
    [self addNotificationObserver:UIApplicationDidReceiveMemoryWarningNotification];
    [self addNotificationObserver:UIApplicationWillTerminateNotification];
    [self addNotificationObserver:UIApplicationSignificantTimeChangeNotification];
    [self addNotificationObserver:UIApplicationWillChangeStatusBarOrientationNotification];
    [self addNotificationObserver:UIApplicationDidChangeStatusBarOrientationNotification];
    [self addNotificationObserver:UIApplicationWillChangeStatusBarFrameNotification];
    [self addNotificationObserver:UIApplicationDidChangeStatusBarFrameNotification];
    [self addNotificationObserver:UIApplicationBackgroundRefreshStatusDidChangeNotification];
    [self addNotificationObserver:UIApplicationUserDidTakeScreenshotNotification];
    [self addNotificationObserver:UIApplicationProtectedDataWillBecomeUnavailable];
    [self addNotificationObserver:UIApplicationProtectedDataDidBecomeAvailable];
}

- (void)addNotificationObserver:(NSString*)name {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:name object:nil];
}

- (void)notificationHandler:(NSNotification*)notification {
    NSString *name = notification.name;
    NSString *des = nil;
    if (name.length) {
        des = [NSString stringWithFormat:@"userInfo:%@", notification.userInfo];
        [self addEventWithName:name event:des];
    }
}

- (NSString*)stringFromEventTraces {
    NSMutableString *traces = [NSMutableString new];
    [traces appendString:@"[\n"];
    [self.eventContainer reverseEnumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HYFEventBase*event = (HYFEventBase*)obj;
        [traces appendString:[event eventDescription]];
        [traces appendString:@"\n"];
    }];
    [traces appendString:@"...\n]\n"];
    return traces;
}

- (NSString*)stringFromRecordTraces {
    NSMutableString *traces = [NSMutableString new];
    [traces appendString:@"{\n"];
    for (NSString*key in self.textContainer.allKeys) {
        [traces appendString:[NSString stringWithFormat:@"%@=%@\n", key, self.textContainer[key]]];
    }
    [traces appendString:@"}\n"];
    return traces;
}

@end
