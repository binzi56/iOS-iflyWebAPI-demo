////  HYFEventTrackerCenter.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYFEventBase;

@interface HYFEventTrackerCenter : NSObject

+ (instancetype)sharedInstance;

- (void)addEvent:(HYFEventBase*)event;

- (void)startTrace;
- (void)setMaxEventCount:(NSInteger)maxEventCount;
- (void)addEventWithName:(NSString*)name event:(NSString*)event;
- (void)recordText:(NSString*)text key:(NSString*)key;
- (NSString*)fullTraces;
- (NSString*)eventTraces;
- (NSString*)recordTraces;

@end
