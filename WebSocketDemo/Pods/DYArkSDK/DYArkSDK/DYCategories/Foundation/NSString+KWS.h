#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface NSString (KWSSafeSize)

- (CGSize)safeSizeWithFont:(UIFont *)font;
- (CGSize)safeSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end


@interface NSString (KWSURL)

+ (NSString*)encodeURLForChinese:(NSString *)string;

+ (NSString*)encodeURL:(NSString *)string;

+ (NSString*)decodeURL:(NSString *)string;

/**
 *  使用这个方法的时候请慎重，必须确保 URL 参数 中不包含 ":/=" 字符。
 *  比如：http://yy.com/?shareTitle=abc&shareUrl=http://huya.com/，
 *  理论上取到的 shareUrl 应该是 http://huya.com/，但本方法只返回 http
 *  keyToLowercase NO
 *  valueReplacingPercentEscapes YES
 *  @return URL 参数字典
 */
- (NSDictionary *)decodeUrlParameters;

/**
 * keyToLowercase，key是否转成小写
 * valueReplacingPercentEscapes，value decode
 */
- (NSDictionary *)decodeUrlParametersKeyToLowercase:(BOOL)keyToLowercase valueReplacingPercentEscapes:(BOOL)valueReplacingPercentEscapes;

/**
 * 根据key从url取出参数值，如果没有则返回nil
 */
- (NSString *)getParameterWithKey:(NSString *)key;

/**
 * 替换url上的参数
 * 1，给定key与新的value 2，给定一组要替换的键值对
 * eg: http://yy.com/?yyuid=&imei= , @{@"yyuid" : @"111"}，替换后： http://yy.com/?yyuid=111&imei=
 */
- (NSString *)urlStringByReplaceValueForKey:(NSString *)key withValue:(NSString *)value;
- (NSString *)urlStringByReplaceParameters:(NSDictionary *)parameters;

/**
 * 该函数会自动为没有协议头的url添加http头
 */
+ (NSString*)autoFixedHttpString:(NSString*)url;

/*
 * 该函数为url的query增加参数
 */
+ (NSString *)stringWithAppendQuery:(NSString *)queryString
                              param:(NSString*)param
                              value:(NSString*)value;

@end


@interface NSString (SafeString)

/**
 *  @brief 如果包含特殊字符，比如阿拉伯文字，则替换为@" "，防止core text崩溃
 */
- (NSString *)safeString;

/**
 * 特殊字符过滤动态配置
 */
+ (void)updateSpecialTextWithConfig:(NSDictionary *)config;

/**
 * 是否数字
 */
+ (BOOL)isNumberString:(NSString *)string;

@end


@interface NSString (KWSXML)

/**
 * 特殊字符转义后的合法的xml字符串
 */
- (NSString *)stringByXMLEscaped;

@end

