//
//  DateUtils.m
//  Wolf
//
//  Created by aiqin on 17/4/12.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+(NSInteger)dateStringToAge: (NSString *)dateString
{
    if (dateString == nil)
    {
        return 0;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [dateFormatter dateFromString:dateString];
    if (date == nil)
    {
        return 0;
    }
    
//    @try {
//        return [self getDateAgeYearInt:date];
//    } @catch (NSException *exception) {
//        return 0;
//    }
    
    return [self getDateAgeYearInt:date];
}

+(NSString*)getDateString: (NSDate *)date
{
    NSDate *selected = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; // HH:mm +0800
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *destDateString = [dateFormatter stringFromDate:selected];
    return destDateString;
}

+ (NSString*)saveDateToShowDate:(NSString*)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *selected = [dateFormatter dateFromString:time];
    
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *destDateString = [dateFormatter stringFromDate:selected];
    return destDateString;
}

+ (NSString*)showDateToSaveDate:(NSString*)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *selected = [dateFormatter dateFromString:time];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:selected];
    return destDateString;
}


+(NSString*)getDateConstellation: (NSDate *)date
{
    NSDate *selected = date;
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [greCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:selected];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    
    NSInteger numCode = month * 100 + day;
    
    if (numCode>=321 && numCode <= 419){
        return @"白羊座";
    }
    else if (numCode>=420 && numCode <= 520){
        return @"金牛座";
    }
    else if (numCode>=521 && numCode <= 621){
        return @"双子座";
    }
    else if (numCode>=622 && numCode <= 722){
        return @"巨蟹座";
    }
    else if (numCode>=723 && numCode <= 822){
        return @"狮子座";
    }
    else if (numCode>=823 && numCode <= 922){
        return @"处女座";
    }
    else if (numCode>=923 && numCode <= 1023){
        return @"天秤座";
    }
    else if (numCode>=1024 && numCode <= 1121){
        return @"天蝎座";
    }
    else if (numCode>=1122 && numCode <= 1221){
        return @"射手座";
    }
    else if (numCode>=1222 || numCode <= 119){
        return @"摩羯座";
    }
    else if (numCode>=120 && numCode <= 218){
        return @"水瓶座";
    }
    else if (numCode>=219 && numCode <= 320){
        return @"双鱼座";
    }
    
    return nil;
}


+(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

//取年龄
+(NSString*)getDateAgeYear: (NSDate *)date
{
    NSDate *selected = date;
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateNew = [calendar components:unitFlags fromDate:selected toDate:nowDate options:0];
    //(long)[date year],(long)[date month],(long)[date day]
    return [NSString stringWithFormat:(@"%ld岁"),(long)[dateNew year]];
}

//取年龄数值
+(NSInteger)getDateAgeYearInt: (NSDate *)date
{
    NSDate *selected = date;
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateNew = [calendar components:unitFlags fromDate:selected toDate:nowDate options:0];
    //(long)[date year],(long)[date month],(long)[date day]
    return [dateNew year];
}

@end
