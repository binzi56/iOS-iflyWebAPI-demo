//
//  NSDate+Common.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Common)

- (BOOL)isToday;

- (BOOL)isYesterday;

- (NSString *)shortTimeTextOfDate;

- (NSString *)timeTextOfDate;

/// 限定的秒数后，显示具体时间；
/// 限定的秒数内，显示xx前
/// @param seconds 限定的秒数
+ (NSString *)shortTimeTextOfDateWithAfterSeconds:(int64_t)seconds;

@end
