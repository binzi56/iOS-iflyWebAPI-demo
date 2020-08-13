//
//  stringutils.h
//  ipadyy
//
//  Created by lslin on 13-5-17.
//  Copyright (c) 2013年 YY.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtils : NSObject

+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
+ (NSString*)decodeBase64WithStringToString:(NSString *)strBase64;

/**
 * 返回 sha1 加密后的 urlsafe_base64 编码
 */
+ (NSString *)hmacsha1WithSecret:(NSString *)key data:(NSString *)data;

/**
 * 返回 sha1 加密后的 16进制字符串
 */
+ (NSString *)hmacsha1HexStringWithSecret:(NSString *)key data:(NSString *)data;

/**
 * 计算字符串长度，2半角 = 1长度，0.5长度会作为1长度
 */
+ (NSInteger)getWideStringLength:(NSString *)str;

/**
 * 计算字符串长度，1全角 = 2长度
 */
+ (NSInteger)getHalfStringLength:(NSString *)str;

/**
 * 截取全角长度的字符串，e.g: "中国人 2" =》 “中国”；“中国ren 3” =》“中国re”
 */
+ (NSString *)subStringWithString:(NSString *)str wideStringLength:(NSUInteger)len;

/**
 * 根据当前时间返回 "MM-dd HH:mm" 格式的字符串
 */
+ (NSString *)timeStringByNow;

/**
 * 根据指定的时间戳返回 "MM-dd HH:mm" 格式的字符串
 */
+ (NSString *)timeStringByTimestamp:(double)timestamp;

/**
 * 根据指定的时间戳，返回自定义格式的字符串
 * @li 如果是1分钟内，返回 "刚刚"
 * @li 如果是今天，返回 "HH:mm"
 * @li 如果是昨天，返回 "昨天 HH:mm"
 * @li 如果是今年，返回 "MM-dd HH:mm"
 * @li 如果是一年前，返回 "yy-MM-dd"
 */
+ (NSString *)customTimeStringByTimestamp:(double)timestamp;

/**
 * 粉丝圈时间轴时间格式化
 * @li 如果是1分钟内，返回 "刚刚"
 * @li 如果是1小时内，返回 "%d分钟前"
 * @li 如果是1天内，返回 "%d小时前"
 * @li 超过1天，返回 "%d天前"
 */
+ (NSString *)timeLineStringByDate:(NSDate *)theDate;

/**
 * 根据指定的时间，返回自定义格式的字符串
 * @li 如果是1分钟内，返回 "刚刚"
 * @li 如果是今天，返回 "HH:mm"
 * @li 如果是昨天，返回 "昨天 HH:mm"
 * @li 如果是今年，返回 "MM-dd HH:mm"
 * @li 如果是一年前，返回 "yyyy-MM-dd"
 */
+ (NSString *)customTimeStringByDate:(NSDate *)theDate;

/**
 * 根据时间戳，返回时间间隔。如："1年前 1月前 1天前 1分钟前"
 */
+ (NSString *)diffTimeStringByTimestamp:(double)timestamp;

/**
 * 根据时间、格式，返回时间字符串
 */
+ (NSString *)timeStringByDate:(NSDate *)date format:(NSString *)format;

/**
 * 返回 "Mon, 20 Oct 2014 10:51:40 GMT" 格式的字符串
 */
+ (NSString *)gmtTimeStringByDate:(NSDate *)date;

/**
 * 根据时间字符串、格式返回时间
 */
+ (NSDate *)dateByTimeString:(NSString *)time format:(NSString *)format;

/**
 * 返回缩写的数字，如：1300 -> 1.3k; 10000 -> 1w
 */
+ (NSString *)shortFormatStringByNumber:(NSUInteger)num;

/**
 * 过滤掉会导致UILabel崩溃的字符\n
 * Crash: Constant is not finite! That's illegal. constant:-inf
 * @param text 原始字符串
 * @return 过滤后的字符串
 */
+ (NSString *)convertSpecialText:(NSString *)text;

/**
 * 秒钟到分钟的转换
 * @param sec 以秒为单位的数字
 * @return e.g: @"13:02"
 */
+ (NSString *)minuteStringBySeconds:(NSInteger)sec;

/**
 * 秒钟到时间的转换，110s -> 00:01:50
 * @param sec 以秒为单位的数字
 * @return e.g: @"13:02:01"
 */
+ (NSString *)timeStringBySeconds:(NSInteger)sec;

/**
 *  颜色代码
 *  @param color 颜色值
 *  @return e.g: @"#FFFFFF"
 */
+ (NSString *)colorCodeForColor:(int)color;

/**
 *  颜色代码
 *  @param colorString 16进制颜色 e.g: @"#FFFFFF"
 *  @return 10进制的颜色值，如果传入颜色格式不对返回-1
 */
+ (int)decimalNumberWithColorString:(NSString *)colorString;

/**
 *  格式化上次开播时间
 */
+ (NSString *)lastLiveTimeDecriptionFromTimestamp:(int64_t)timestamp;

/**
 *  格式化视频上传时间，从形如"xxxx-xx-xx xx:xx"转化为"xxxx.xx.xx xx:xx"或"昨天","前天"等
 *  @param string 形如"xxxx-xx-xx xx:xx"时间字符串
 *  @return 形如"xxxx.xx.xx xx:xx"或"昨天","前天"时间字符串
 */
+ (NSString *)formattedDateStringFromString:(NSString *)string;

/**
 *  格式化数量字符串
 *  @param count 整数
 *  @return 形如"n.m万","n.m亿"的字符串
 */
+ (NSString *)countStringFromCount:(long long)count;

@end
