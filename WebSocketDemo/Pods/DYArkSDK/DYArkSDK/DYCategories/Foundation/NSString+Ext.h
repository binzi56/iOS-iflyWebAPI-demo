//
//  NSString+Ext.h
//  SampleBroadcaster
//
//  Created by weicaiyu on 16/5/20.
//  Copyright © 2016年 videocore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Ext)

+ (BOOL)stringContainsEmoji:(NSString *)string;//判断是不是emoji表情

+ (NSString *) md5:(NSString *) input;//md5加密

//去掉字符串前面的0
+(NSString*) getTheCorrectNum:(NSString*)tempString;

//把不规则的Json改成标准的双引号JSON
+ (NSString *)changeJsonStringToTrueJsonString:(NSString *)json;

//获取字符串中的数字（第一个数字）
+ (NSString *) numFromString:(NSString *) rewStr;

//获取文字的尺寸,宽为屏幕宽度
+ (CGSize)sizeFrom:(NSString *) content  font:(UIFont *) font;

+ (CGSize)sizeFrom:(NSString *) content  font:(UIFont *) font maxSize:(CGSize)maxSize;

/// 根据文字获取宽度
/// @param font 字体大小
/// @param lineSpace 行高
/// @param kern 字间距
/// @param size 空间宽高，宽度必须正确，高度给大约最大高度
- (CGSize)sizeWithFont:(UIFont *)font lineSpace:(CGFloat)lineSpace textKern:(CGFloat)kern inSize:(CGSize)size;

//字典转Json字符串
+ (NSString*)convertToJSONData:(id)infoDict;

//JSON字符串转化为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//获取URL指定参数的值
+ (NSString *) paramValueOfUrl:(NSString *) url withParam:(NSString *) param;

//超链接
+(NSArray*)urlFromString:(NSString *)string;

-(BOOL)isValidString;

//字符串长度（字符）
//+(NSUInteger)textLength: (NSString *) text;

//By Easyin
//计算字符长度，emoji算1个
- (float)dy_length;

+ (BOOL)isHalfLengthWithString:(NSString *)string;

- (NSString *)dy_substringWithLength:(float)length;

- (NSString *)dy_cutEllipsisWithLength:(float)length;
@end
