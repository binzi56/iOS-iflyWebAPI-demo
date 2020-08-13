//
//  NSString+Ext.m
//  SampleBroadcaster
//
//  Created by weicaiyu on 16/5/20.
//  Copyright © 2016年 videocore. All rights reserved.
//

#import "NSString+Ext.h"
#import <CoreText/CoreText.h>
#import<CommonCrypto/CommonDigest.h>

#import "HYLogMacros.h"

@implementation NSString (Ext)

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}



//含表情，计算文字高度
- (CGFloat)heightStringWithEmojis:(NSString*)str fontType:(UIFont *)uiFont ForWidth:(CGFloat)width {
    
    // Get text
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef) str );
    CFIndex stringLength = CFStringGetLength((CFStringRef) attrString);
    
    // Change font
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) uiFont.fontName, uiFont.pointSize, NULL);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, stringLength), kCTFontAttributeName, ctFont);
    
    // Calc the size
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), &fitRange);
    
    CFRelease(ctFont);
    CFRelease(framesetter);
    CFRelease(attrString);
    
    return frameSize.height +4;
    
}


+ (NSString *) md5:(NSString *) input {
    const char  *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

//去掉字符串前面的0
+(NSString*) getTheCorrectNum:(NSString*)tempString
{
    while ([tempString hasPrefix:@"0"])
    {
        tempString = [tempString substringFromIndex:1];
        DYLogInfo(@"压缩之后的tempString:%@",tempString);
    }
    return tempString;
}


//把不规则的Json改成标准的双引号JSON
+ (NSString *)changeJsonStringToTrueJsonString:(NSString *)json
{
    // 将没有双引号的替换成有双引号的
    NSString *validString = [json stringByReplacingOccurrencesOfString:@"(\\w+)\\s*:([^A-Za-z0-9_])"
                                                            withString:@"\"$1\":$2"
                                                               options:NSRegularExpressionSearch
                                                                 range:NSMakeRange(0, [json length])];
    
    
    //把'单引号改为双引号"
    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])'"
                                                         withString:@"$1\""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    validString = [validString stringByReplacingOccurrencesOfString:@"'([:\\],\\}])"
                                                         withString:@"\"$1"
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    
    //再重复一次 将没有双引号的替换成有双引号的
    validString = [validString stringByReplacingOccurrencesOfString:@"([:\\[,\\{])(\\w+)\\s*:"
                                                         withString:@"$1\"$2\":"
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [validString length])];
    return validString;
}


//获取字符串中的数字
+ (NSString *) numFromString:(NSString *) rewStr{
    
    
    NSScanner *scanner = [NSScanner scannerWithString:rewStr];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    
    int number;
    [scanner scanInt:&number];
    NSString *num=[NSString stringWithFormat:@"%d",number];
    
    return num;
    
}

//获取文字的尺寸
+ (CGSize) sizeFrom:(NSString *) content  font:(UIFont *) font{
    CGSize nameMaxSize=CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT);//最大宽高
    return [self sizeFrom:content font:font maxSize:nameMaxSize];
    
}

//获取文字的尺寸
+ (CGSize) sizeFrom:(NSString *) content  font:(UIFont *) font maxSize:(CGSize)maxSize{
    
    if (!font || !content) {
        return CGSizeZero;
    }
    CGSize inSize = CGSizeZero;
    NSDictionary *attrs = @{NSFontAttributeName: font};
    CGSize nameMaxSize = maxSize;//最大宽高
    
    CGRect frame =[content boundingRectWithSize:nameMaxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil];//options设置两个参数比较准确,NSStringDrawingTruncatesLastVisibleLine,如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。如果没有指定NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略
    inSize = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
    if (!isnormal(inSize.width)) {
        inSize.width = 0.0;
    }

    return inSize;
    
}

- (CGSize)sizeWithFont:(UIFont *)font lineSpace:(CGFloat)lineSpace textKern:(CGFloat)kern inSize:(CGSize)size{

    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (lineSpace >0) {
        paragraphStyle.lineSpacing = lineSpace;
    }
    CGRect frame = [self boundingRectWithSize:size
                                      options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName : font ,NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName : @(kern)}
                                      context:nil];

    CGSize inSize = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
    if (!isnormal(inSize.width)) {
        inSize.width = 0.0;
    }
    return inSize;
}


//字典转Json字符串
+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        DYLogInfo(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

//JSON字符串转化为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        DYLogInfo(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


//获取URL指定参数的值
+ (NSString *) paramValueOfUrl:(NSString *) url withParam:(NSString *) param{
    
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",param];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return nil;
}


+(NSArray*)urlFromString:(NSString *)string
{
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    //NSString *subStr;
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
        
    }
    return arr;
    
    
}


-(BOOL)isValidString
{
    if (self == nil || [self length] == 0||[self  isEqualToString:@""] || [self isEqualToString:@"<null>"]) {
        return NO;
    }
    return YES;
}

//字符串长度（字符）
//+(NSUInteger)textLength: (NSString *) text{
//    if (!text) {
//        return 0;
//    }
//    int strlength = 0;
//    char* p = (char*)[text cStringUsingEncoding:NSUnicodeStringEncoding];
//    for (int i=0 ; i<[text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
//        if (*p) {
//            p++;
//            strlength++;
//        }
//        else {
//            p++;
//        }
//    }
//    return strlength;
//
//}

//By Easyin
- (float)dy_length
{
    __block float length = 0;
    if (!self ||
        ![self isKindOfClass:[NSString class]]) {
        return length;
    }
    
    NSString *newString = [self copy];
    
    NSRange fullRange = NSMakeRange(0, [newString length]);
    [newString enumerateSubstringsInRange:fullRange
                                  options:NSStringEnumerationByComposedCharacterSequences
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         length += [self.class isHalfLengthWithString:substring] ? 0.5f : 1.f;
     }];
    
    return length;
}

+ (BOOL)isHalfLengthWithString:(NSString *)string
{
    // http://ascii.911cha.com/
    //"ASCII可显示字符"表中的字符均为半个, 32~126
    int x = [string characterAtIndex:0];
    if (x >= 32 && x <= 126) {
        return YES;
    }
    return NO;
}

- (NSString *)dy_substringWithLength:(float)length
{
    if (!self ||
        ![self isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    NSString *selfCopy = [self copy];
    NSRange fullRange = NSMakeRange(0, [selfCopy length]);
    __block float blockLenght = length;
    __block NSMutableString * newString = [NSMutableString new];
    [selfCopy enumerateSubstringsInRange:fullRange
                                  options:NSStringEnumerationByComposedCharacterSequences
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         
         blockLenght -= [self.class isHalfLengthWithString:substring] ? 0.5f : 1.f;
         if (blockLenght < 0.f)
         {
             *stop = YES;
             return ;
         }
         [newString appendString:substring];
     }];
    
    return [newString copy];
}

- (NSString *)dy_cutEllipsisWithLength:(float)length
{
    return self.dy_length>length?[[self dy_substringWithLength:length] stringByAppendingString:@"…"]:self;
}

@end
