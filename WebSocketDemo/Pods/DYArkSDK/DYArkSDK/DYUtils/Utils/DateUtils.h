//
//  DateUtils.h
//  Wolf
//
//  Created by aiqin on 17/4/12.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

/**
 * 获取年龄 使用“1990-01-01”转换为27
 */
+(NSInteger)dateStringToAge: (NSString *)dateString;


/**
 * 使用1990-01-01转换为1990年01月01日
 */
+ (NSString*)saveDateToShowDate:(NSString*)time;


/**
 * 使用1990年01月01日转换为1990-01-01
 */
+ (NSString*)showDateToSaveDate:(NSString*)time;


/**
 * 根据日期得到星座
 */
+(NSString*)getDateConstellation: (NSDate *)date;


/**
 * 把一个date转换为“1990-01-01”类型的文本
 */
+(NSString*)getDateString: (NSDate *)date;


/**
 * 获取现在时间戳（UTC+0）文本，10位，精确到秒
 */
+(NSString *)getNowTimeTimestamp;


/**
 * 获取日期到现在的年龄
 */
+(NSString*)getDateAgeYear: (NSDate *)date;


/**
 * 获取日期到现在的年龄 Int
 */
+(NSInteger)getDateAgeYearInt: (NSDate *)date;

@end
