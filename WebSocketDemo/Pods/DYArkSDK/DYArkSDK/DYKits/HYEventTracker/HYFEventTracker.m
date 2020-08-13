////  HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventTracker.h"

#import "HYFEventTrackerCenter.h"

@implementation HYFEventTracker

+ (void)startTrace {
    [[HYFEventTrackerCenter sharedInstance] startTrace];
}

+ (void)setMaxEventCount:(NSInteger)maxEventCount {
    [[HYFEventTrackerCenter sharedInstance] setMaxEventCount:maxEventCount];
}

+ (void)addEventWithName:(NSString*)name event:(NSString*)event {
    [[HYFEventTrackerCenter sharedInstance] addEventWithName:name event:event];
}

+ (void)recordText:(NSString*)text key:(NSString*)key {
    [[HYFEventTrackerCenter sharedInstance] recordText:text key:key];
}

+ (NSString*)fullTraces {
    return [[HYFEventTrackerCenter sharedInstance] fullTraces];
}

+ (NSString*)eventTraces {
    return [[HYFEventTrackerCenter sharedInstance] eventTraces];
}

+ (NSString*)recordTraces {
    return [[HYFEventTrackerCenter sharedInstance] recordTraces];
}

@end
