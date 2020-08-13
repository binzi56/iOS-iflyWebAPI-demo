//
//  TimeUtils.m
//  Liveplay
//
//  Created by kerry on 2017/6/26.
//  Copyright © 2017年 kerry. All rights reserved.
//

#import "TimeUtils.h"

static double sTimeOffWithServer = 0;

@implementation ZKDateTime



@end

@implementation TimeUtils

+(double)getLocalTimeWithSec{
    return [[NSDate date]timeIntervalSince1970];
}

+(double)getLocalTimeWithMSec{
    return [self getCurrentTimeWithSec] * 1000;
}

+(void)setTimeOffsetWithServer:(double) serverTime{
    sTimeOffWithServer = serverTime - [self getLocalTimeWithSec];
}

+(double)getCurrentTimeWithSec{
    return [self getLocalTimeWithSec] + sTimeOffWithServer;
}

+(double)getCurrentTimeWithMSec{
    return [self getLocalTimeWithMSec] + sTimeOffWithServer;
}

+ (NSString *) stringFromDate:(NSDate *) date{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [formatter stringFromDate:date];
}

//获取时间实体类
+ (ZKDateTime *) dateModelFromDate:(NSDate *) date{
    ZKDateTime *dateMode=[[ZKDateTime alloc] init];
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *comp=[cal components:NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    dateMode.year=comp.year;
    dateMode.moth=comp.month;
    dateMode.day=comp.day;
    dateMode.hour=comp.hour;
    dateMode.minute=comp.minute;
    dateMode.second=comp.second;
    return dateMode ;
}

+ (NSDate *) DateFromString:(NSString *) StringDate{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [formatter dateFromString:StringDate];
}




//返回小时和分钟
+ (NSString *) hourAndMinuteStringFromDate:(NSDate *) date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}


//长用时间字符串格式
+ (NSString *) stringFromDateNomal:(NSDate *) date{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:date];
}

+ (NSDate *) DateFromDateString:(NSString *) StringDate{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter dateFromString:StringDate];
}

//返回 yyyy-MM-dd 格式的时间
+ (NSString *) stringFromDateToDay:(NSDate *) date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

//返回 yyyy年MM月dd日 格式的时间
+ (NSString *) chineseStringFromDateToDay:(NSDate *) date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    return [formatter stringFromDate:date];
}

/**
 *	@brief	返回yyyy/mm/dd格式的字符串
 *
 *	@return	yyyy/mm/dd
 */
+ (NSString *) stringYMDFromDate:(NSDate *) date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    return [formatter stringFromDate:date];
}

//获取时间实体类
+ (ZKDateTime *) dateModelFromDateString:(NSString *) strDate{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [formatter dateFromString:strDate];
    
    ZKDateTime *dateMode=[[ZKDateTime alloc] init];
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *comp=[cal components:NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    dateMode.year=comp.year;
    dateMode.moth=comp.month;
    dateMode.day=comp.day;
    dateMode.hour=comp.hour;
    dateMode.minute=comp.minute;
    dateMode.second=comp.second;
    return dateMode ;
    
}

//获取时间实体类 long long
+ (ZKDateTime *) dateModelFromLongDate:(long long) longDate{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:longDate / 1000];
    
    ZKDateTime *dateMode=[[ZKDateTime alloc] init];
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *comp=[cal components:NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    dateMode.year=comp.year;
    dateMode.moth=comp.month;
    dateMode.day=comp.day;
    dateMode.hour=comp.hour;
    dateMode.minute=comp.minute;
    dateMode.second=comp.second;
    return dateMode ;
    
}


//获取时间实体类（精确到分钟）
+ (ZKDateTime *) dayModelFromDateString:(NSString *) strDate{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [formatter dateFromString:strDate];
    
    ZKDateTime *dateMode=[[ZKDateTime alloc] init];
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *comp=[cal components:NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    dateMode.year=comp.year;
    dateMode.moth=comp.month;
    dateMode.day=comp.day;
    dateMode.hour=comp.hour;
    dateMode.minute=comp.minute;
    dateMode.second=comp.second;
    return dateMode ;
    
}



//取某天时间的0点
+(NSString *) stringOfStartDay:(NSDate *) date{
    NSCalendar *cal=[NSCalendar currentCalendar];
    //第一天
    NSDateComponents *comp=[cal components: NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute |NSCalendarUnitSecond fromDate:date];
    comp.hour=0;
    comp.minute=0;
    comp.second=0;
    NSDate *firstDay=[cal dateFromComponents:comp];
    NSString *firsStrDate=[TimeUtils stringFromDate:firstDay];
    return firsStrDate;
    
}

+ (NSString *) stringOfEndDay:(NSDate *) date{
    
    NSCalendar *cal=[NSCalendar currentCalendar];
    //最后一天
    NSDateComponents *comp1=[cal components: NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute |NSCalendarUnitSecond fromDate:date];
    comp1.hour=23;
    comp1.minute=59;
    comp1.second=59;
    
    NSDate *lastDay=[cal dateFromComponents:comp1];
    
    NSString *lastStrDate=[TimeUtils stringFromDate:lastDay];
    
    return lastStrDate;
    
}

//将long long 转换成时间字符串
+ (NSString *) dateByLongLongType:(long long) longTimg{
    if (longTimg!=0) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:longTimg / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        
        return [dateFormatter stringFromDate:date];
    }else{
        return @"";
    }
    
}

//将long long 转换成时间字符串yyyy-MM-dd HH:mm
+ (NSString *) dateByLongLongTypeOfMinutes:(long long) longTimg{
    if (longTimg!=0) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:longTimg / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        return [dateFormatter stringFromDate:date];
    }else{
        return @"";
    }
    
}

//将long long 转换成时间字符串yyyy-MM-dd
+ (NSString *) dateByLongLongTypeOfDay:(long long) longTimg{
    if (longTimg!=0) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:longTimg / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        return [dateFormatter stringFromDate:date];
    }else{
        return @"";
    }
    
}

//将long 转换成时间字符串yyyy-MM-dd HH:mm 无需除以1000
+ (NSString *) dateByLongTypeOfMinutes:(long long) longTimg{
    if (longTimg!=0) {
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:longTimg];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        return [dateFormatter stringFromDate:date];
    }else{
        return @"";
    }
    
}

//将NSDate转成long long
+(long long)longLongFromDate:(NSDate*)date{
    return [date timeIntervalSince1970] * 1000;
}


//将long long转成NSDate
+ (NSDate *) dateFromLongLongData:(long long) longDate{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:longDate / 1000];
    return date;
}


/**
 2  * @method
 3  *
 4  * @brief 获取两个日期之间的天数
 5  * @param fromDate       起始日期
 6  * @param toDate         终止日期
 7  * @return    总天数
 8  */
+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents    * comp = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:NSCalendarWrapComponents];
    return comp.day;
}


// 判断是否是同一天
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
}

+ (NSString*)costTimeLevelWithSecond:(double)costTime {
    if (costTime <= 0.1) {
        return @"1";
    } else if (costTime <= 0.3) {
        return @"2";
    } else if (costTime <= 0.8) {
        return @"3";
    } else if (costTime <= 3.0) {
        return @"4";
    } else if (costTime <= 20.0) {
        return @"5";
    } else {
        return @"6";
    }

}



/**
 返回yyyy.mm.dd格式的字符串
 
 @param date 当前的日期对象
 @return 返回yyyy.mm.dd格式的字符串
 */
+ (NSString *) stringSeparatePointYMDFromDate:(NSDate *) date {
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    return [formatter stringFromDate:date];
}

@end
