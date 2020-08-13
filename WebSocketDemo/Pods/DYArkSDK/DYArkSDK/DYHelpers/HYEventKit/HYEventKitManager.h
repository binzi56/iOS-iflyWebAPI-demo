//
//  HYCalendarManager.h
//  kiwi
//
//  Created by zzyong on 2016/10/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYEventKitManager : NSObject

+ (instancetype)sharedObject;

#pragma mark - 系统日历提醒

//增加系统日历提醒事件
- (void)addEventToCalendarWithTitle:(NSString *)title
                              notes:(NSString *)notes
                                url:(NSString *)urlString
                          startDate:(NSDate *)startDate
                            dueDate:(NSDate *)dueDate
                      alarmInterval:(NSTimeInterval)alarmInterval
                         completion:(void (^)(BOOL success, NSError *error))completion;

//移除系统日历提醒事件
- (void)removeEventWithStartDate:(NSDate *)startDate
                         dueDate:(NSDate *)dueDate
                           title:(NSString *)title
                      completion:(void (^)(BOOL success, NSError *error))completion;

@end
