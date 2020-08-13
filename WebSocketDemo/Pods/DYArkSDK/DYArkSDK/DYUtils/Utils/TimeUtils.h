//
//  TimeUtils.h
//  Liveplay
//
//  Created by kerry on 2017/6/26.
//  Copyright © 2017年 kerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKDateTime : NSObject

@property (nonatomic,assign) NSInteger year;

@property (nonatomic,assign) NSInteger moth;

@property (nonatomic,assign) NSInteger day;

@property (nonatomic,assign) NSInteger hour;

@property (nonatomic,assign) NSInteger minute;

@property (nonatomic,assign) NSInteger second;



@end

@interface TimeUtils : NSObject
+(double)getLocalTimeWithSec;//获取本地时间，单位：s
+(double)getLocalTimeWithMSec;//获取本地时间，单位：ms
+(double)getCurrentTimeWithSec;//获取服务器时间，单位：s
+(double)getCurrentTimeWithMSec;//获取服务器时间，单位：ms
+(void)setTimeOffsetWithServer:(double) serverTime;////调整时间差，需要在调用服务器接口时获取到服务器时间后调用

/**
 *	@brief	返回yyyymmddHHmmss格式的字符串
 *
 *	@return	yyyymmddHHmmss
 */
+ (NSString *) stringFromDate:(NSDate *) date;

//获取时间实体类
+ (ZKDateTime *) dateModelFromDate:(NSDate *) date;

/**
 *	@brief	返回小时个分钟
 *
 *	@return	HH:ss
 */
+ (NSString *) hourAndMinuteStringFromDate:(NSDate *) date;


/**
 *	@brief	返回yyyy/mm/dd格式的字符串
 *
 *	@return	yyyy/mm/dd
 */
+ (NSString *) stringYMDFromDate:(NSDate *) date;

/**
 *	@brief	返回yyyy-MM-dd HH:mm:ss长用时间字符串格式
 *
 *	@return	yyyy-MM-dd HH:mm:ss
 */
+ (NSString *) stringFromDateNomal:(NSDate *) date;

+ (NSDate *) DateFromDateString:(NSString *) StringDate;

/**
 *	@brief	返回yyyy-MM-dd 长用时间字符串格式
 *
 *	@return	yyyy-MM-dd
 */
+ (NSString *) stringFromDateToDay:(NSDate *) date;

//返回 yyyy年MM月dd日 格式的时间
+ (NSString *) chineseStringFromDateToDay:(NSDate *) date;

/**
 *	@brief	获取时间实体类
 *
 *	@return	String 类型的时间
 */
+ (ZKDateTime *) dateModelFromDateString:(NSString *) strDate;

//获取时间实体类 long long
+ (ZKDateTime *) dateModelFromLongDate:(long long) longDate;

/**
 *	@brief	将yyyymmddHHmmss字符串时间转换成NSDate
 *
 *	@return	NSDate
 */
+ (NSDate *) DateFromString:(NSString *) StringDate;


//取某天时间的0点
+ (NSString *) stringOfStartDay:(NSDate *) date;

//取某天时间的最后一点
+ (NSString *) stringOfEndDay:(NSDate *) date;

/**
 *	@brief	获取时间实体类（yyyymmddHHmm）获取时间实体类（精确到分钟）
 *
 *	@return	String 类型的时间
 */
+ (ZKDateTime *) dayModelFromDateString:(NSString *) strDate;


/**
 *	@brief	将long long 转换成时间字符串
 *
 *	@return	String 类型的时间
 */
+ (NSString *) dateByLongLongType:(long long) longTimg;

//将long long 转换成时间字符串yyyy-MM-dd HH:mm
+ (NSString *) dateByLongLongTypeOfMinutes:(long long) longTimg;

//将long long 转换成时间字符串yyyy-MM-dd
+ (NSString *) dateByLongLongTypeOfDay:(long long) longTimg;

/**
 将long 转换成时间字符串yyyy-MM-dd HH:mm 无需除以1000
 
 @param longTimg 时间戳
 @return 日期字符串
 */
+ (NSString *) dateByLongTypeOfMinutes:(long long) longTimg;

//将NSDate转成long long
+(long long)longLongFromDate:(NSDate*)date;

//将long long转成NSDate
+ (NSDate *) dateFromLongLongData:(long long) longDate;

/**
 2  * @method
 3  *
 4  * @brief 获取两个日期之间的天数
 5  * @param fromDate       起始日期
 6  * @param toDate         终止日期
 7  * @return    总天数
 8  */
+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

// 判断是否是同一天
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

/**
 单位：秒 ，消耗时间 <= 0.1 ,costTime =1; 消耗时间 <=0.3 ,costTime =2；消耗时间 <=0.8 ,costTime =3；消耗时间 <=3；costTime =4；消耗时间 <=20，costTime =5

 @param time 耗时秒数
 @return 时间等级
 */
+ (NSString*)costTimeLevelWithSecond:(double)costTime;


/**
 返回yyyy.mm.dd格式的字符串
 
 @param date 当前的日期对象
 @return 返回yyyy.mm.dd格式的字符串
 */
+ (NSString *) stringSeparatePointYMDFromDate:(NSDate *) date;

@end
