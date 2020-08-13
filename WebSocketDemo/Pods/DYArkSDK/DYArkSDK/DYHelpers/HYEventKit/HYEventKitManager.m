//
//  HYCalendarManager.m
//  kiwi
//
//  Created by zzyong on 2016/10/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

//#import <EventKit/EventKit.h>
#import "HYEventKitManager.h"
#import "KiwiSDKMacro.h"

@interface HYEventKitManager ()

//@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation HYEventKitManager

#pragma mark - public

+ (instancetype)sharedObject
{
    static HYEventKitManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void){
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
//        self.eventStore = [[EKEventStore alloc] init];
    }
    return self;
}

#pragma mark - Event

- (void)addEventToCalendarWithTitle:(NSString *)title
                              notes:(NSString *)notes
                                url:(NSString *)urlString
                          startDate:(NSDate *)startDate
                            dueDate:(NSDate *)dueDate
                      alarmInterval:(NSTimeInterval)alarmInterval
                         completion:(void (^)(BOOL success, NSError *error))completion
{
    BlockWeakSelf(weakSelf, self);
    /**
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error) {
                                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                BOOL success = NO;
                                NSError *saveError = error;
                                do {
                                    
                                    if (saveError) {
                                        break;
                                    }
                                    
                                    //用户未开启事件提醒事项
                                    if (!granted) {
                                        saveError = [weakSelf authorityLimitError];
                                        break;
                                    }
                                    
                                    //检测是否存在相同的事件
                                    if ([weakSelf isEventExistInCalendarWithStartDate:startDate dueDate:dueDate title:title]) {
                                        success = YES;
                                        break;
                                    }
                                    
                                    EKEvent *event = [EKEvent eventWithEventStore:weakSelf.eventStore];
                                    event.title = title;
                                    event.notes = notes;
                                    event.URL = [NSURL URLWithString:urlString];
                                    event.allDay = NO;
                                    event.startDate = startDate;
                                    event.endDate = dueDate;
                                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:alarmInterval]];
                                    event.calendar = [weakSelf.eventStore defaultCalendarForNewEvents];
                                    success = [weakSelf.eventStore saveEvent:event span:EKSpanThisEvent commit:NO error:&saveError];
                                    if (saveError) {
                                        break;
                                    }
                                    [weakSelf.eventStore commit:&saveError];
                                    
                                } while (0);
                                
                                if (completion) {
                                    completion(success, saveError);
                                }
                            });
     }];
     **/
}

- (void)removeEventWithStartDate:(NSDate *)startDate
                         dueDate:(NSDate *)dueDate
                           title:(NSString *)title
                      completion:(void (^)(BOOL, NSError *))completion
{
    /**
    BlockWeakSelf(weakSelf, self);
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error) {
                                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            BOOL success = NO;
                            NSError *removeError = error;
                            do {
                                
                                if (removeError) {
                                    break;
                                }
                                
                                //用户未开启事件提醒事项
                                if (!granted) {
                                    removeError = [weakSelf authorityLimitError];
                                    break;
                                }
                                
                                NSArray *eventsArray = [weakSelf fetchEventsWithStartDate:startDate dueDate:dueDate];
                                if (!eventsArray.count) {
                                    success = YES;
                                    break;
                                }
                                
                                NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title matches %@", title];
                                NSArray *results = [eventsArray filteredArrayUsingPredicate:titlePredicate];
                                [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    NSError *removeMommitError = nil;
                                    if (![self.eventStore removeEvent:obj span:EKSpanThisEvent commit:NO error:&removeMommitError]) {
                                        KWSLogInfo(@"remove error %@", removeMommitError);
                                    }
                                }];
                                
                                success = [self.eventStore commit:&removeError];
                                
                            } while (0);
                            
                            if (completion) {
                                completion(success, error);
                            }
                        });
    }];
     **/
}

- (NSArray *)fetchEventsWithStartDate:(NSDate *)startDate
                              dueDate:(NSDate *)dueDate
{
    /**
    if (startDate == nil || dueDate == nil) {
        KWSLogError(@"startDate nil :%@ or dueDate nil :%@",startDate, dueDate);
        return nil;
    }
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:dueDate
                                                                    calendars:nil];
    if(predicate) {
        return [self.eventStore eventsMatchingPredicate:predicate];
    } else {
        return nil;
    }
     **/
    return [NSArray new];
}

#pragma mark - private

- (BOOL)isEventExistInCalendarWithStartDate:(NSDate *)startDate
                                    dueDate:(NSDate *)dueDate
                                      title:(NSString *)title
{
    NSArray *eventsArray = [self fetchEventsWithStartDate:startDate dueDate:dueDate];
    if (!eventsArray.count) {
        return NO;
    } else {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title matches %@", title];
        return [eventsArray filteredArrayUsingPredicate:titlePredicate].count;
    }
}

- (NSError *)authorityLimitError
{
//    return [NSError errorWithDomain:@"EKErrorDomain"
//                               code:-1
//                           userInfo:@{@"NSLocalizedDescription" : @"未开启权限"}];
   return [NSError new];
}

@end

