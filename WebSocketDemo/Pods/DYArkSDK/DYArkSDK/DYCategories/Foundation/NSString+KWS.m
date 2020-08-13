#import "NSString+KWS.h"
#import "KiwiSDKMacro.h"
#import <objc/runtime.h>
#import "NSMutableDictionary+KWS.h"

@implementation NSString (KWSSafeSize)

- (CGSize)safeSizeWithFont:(UIFont *)font
{
    return [self safeSizeWithFont:font
                constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                    lineBreakMode:NSLineBreakByCharWrapping];
}

- (CGSize)safeSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize inSize = CGSizeZero;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect frame = [self boundingRectWithSize:size
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName : font}
                                          context:nil];
        inSize = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
    }
    
    if (!isnormal(inSize.width)) {
        inSize.width = 0.0;
    }
    return inSize;
}

@end


@implementation NSString (KWSURL)

+ (NSString*)encodeURLForChinese:(NSString *)string
{
    NSCharacterSet *allowedCharacters = [[NSCharacterSet illegalCharacterSet] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

+ (NSString*)encodeURL:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                                                 kCFStringEncodingUTF8));
}

+ (NSString*)decodeURL:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef) string,
                                                                                                 CFSTR(""),
                                                                                                 kCFStringEncodingUTF8));
}

- (NSDictionary *)decodeUrlParameters
{
    return [self decodeUrlParametersKeyToLowercase:NO valueReplacingPercentEscapes:YES];
}

- (NSDictionary *)decodeUrlParametersKeyToLowercase:(BOOL)keyToLowercase valueReplacingPercentEscapes:(BOOL)valueReplacingPercentEscapes
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSArray *urlComponents = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":/?&"]];
    
    
    for (NSString *strItem in urlComponents) {
        NSArray *itemComponents = [strItem componentsSeparatedByString:@"="];
#ifdef IS_CARAMEL
        NSString *key = [itemComponents count] > 0 ? ((NSString *)itemComponents[0]).mutableCopy : @"";
        NSString *value = [itemComponents count] > 1 ? ((NSString *)itemComponents[1]).mutableCopy : @"";
#else
        NSString *key = [itemComponents count] > 0 ? ((NSString *)itemComponents[0]) : @"";
        NSString *value = [itemComponents count] > 1 ? ((NSString *)itemComponents[1]) : @"";
#endif
        if (key && key.length && value && value.length){
            
            if (keyToLowercase) {
                key = [key lowercaseString];
            }
            
            if (valueReplacingPercentEscapes) {
                value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            [dict safeSetObject:value forKey:key];
        }
    }
    
    return dict;
}

- (NSString *)getParameterWithKey:(NSString *)theKey
{
    if ([theKey length]) {
        
        NSArray *urlComponents = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":/?&"]];
        
        for (NSString *strItem in urlComponents) {
            NSArray *itemComponents = [strItem componentsSeparatedByString:@"="];
            NSString *key = [itemComponents count] > 0 ? itemComponents[0] : @"";
            NSString *value = [itemComponents count] > 1 ? itemComponents[1] : @"";
            if (key && key.length && [key compare:theKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return value;
            }
        }
    }
    
    return nil;
}

- (NSString *)urlStringByReplaceValueForKey:(NSString *)key withValue:(NSString *)value
{
    if (key.length == 0 || !value) {
        return [self copy];
    }
    
    NSString *regexStr = [NSString stringWithFormat:@"%@=([^&]*)", key];
    NSRegularExpression* regexExpression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray* matchs = [regexExpression matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (matchs != nil && [matchs count] == 1) {
        NSTextCheckingResult *checkingResult = [matchs objectAtIndex:0];
        
        NSString *replaceString = [NSString stringWithFormat:@"%@=%@", key, value];
        return [self stringByReplacingCharactersInRange:checkingResult.range
                                             withString:replaceString];
    }
    
    return [self copy];
}

- (NSString *)urlStringByReplaceParameters:(NSDictionary *)parameters
{
    NSString *urlString = [self copy];
    
    for (NSString *key in parameters) {
        urlString = [urlString urlStringByReplaceValueForKey:key withValue:parameters[key]];
    }
    
    return urlString;
}

+ (NSString*)autoFixedHttpString:(NSString*)url
{
    if (url != nil && ![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    return url;
}

+ (NSString *)stringWithAppendQuery:(NSString *)queryString
                              param:(NSString*)param
                              value:(NSString*)value
{
    if (![queryString length]) {
        return queryString;
    }
    
    return [[NSString alloc] initWithFormat:@"%@%@%@=%@", queryString,
            [queryString rangeOfString:@"?"].length > 0 ? @"&" : @"?", param, value];
}

@end

@interface HYSpecialTextFilter : NSObject
@property (atomic, strong) NSSet *specialTextsUnicharsSet;
@property (atomic, strong) NSArray *specialTextsUnicharsSetRanges;
@end

@implementation HYSpecialTextFilter

+ (instancetype)sharedObject
{
    static dispatch_once_t onceToken;
    static HYSpecialTextFilter *filter = nil;
    dispatch_once(&onceToken, ^{
        filter = [[HYSpecialTextFilter alloc] init];
    });
    
    return filter;
}

- (BOOL)isUnicharInSpecialText:(unichar)character specialTextsUnicharsSet:(NSSet *)specialTextsUnicharsSet specialTextsUnicharsSetRanges:(NSArray *)specialTextsUnicharsSetRanges
{
    /*
    static NSSet *specialSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *specialString = @"ิ̶ܾ҉ر";
        specialSet = [NSMutableSet setWithCapacity:specialString.length];
        for (int i = 0; i < specialString.length; i++) {
            unichar c = [specialString characterAtIndex:i];
            [specialSet addObject:@(c)];
        }
    });
     */
 
    //NSString *specialString = @"ิ̶ܾ҉ر";
    if (character == 1 || character == 3636 || character == 822 || character == 1854 || character == 1161 || character == 1585 || character == 65197) {
        return YES;
    }
    
    if (specialTextsUnicharsSetRanges) {
        for (NSArray *range in specialTextsUnicharsSetRanges) {
            unichar begin = [[range firstObject] unsignedShortValue];
            unichar end = [[range lastObject] unsignedShortValue];
            if (character >= begin && character <= end ) {
                return YES;
            }
        }
    }
    
    if (specialTextsUnicharsSet) {
        if ([specialTextsUnicharsSet containsObject:@(character)]) {
            return YES;
        }
    }
    
    return NO;
}

/*
 { "specialTextsUnichars":[26159],
 "specialTextsUnicharsRanges":[[65,90],[49,51]]
 }
 */
- (void)updateSpecialTextWithConfig:(NSDictionary *)config
{
    NSArray *specialTexts = [config objectForKey:@"specialTextsUnichars"];
    
    if ([specialTexts isKindOfClass:[NSArray class]] && [specialTexts count]) {
        self.specialTextsUnicharsSet = [NSSet setWithArray:specialTexts];
    } else {
        self.specialTextsUnicharsSet = nil;
    }
    
    NSArray *specialTextsRanges = [config objectForKey:@"specialTextsUnicharsRanges"];
    
    if ([specialTextsRanges isKindOfClass:[NSArray class]] && [specialTextsRanges count]) {
        self.specialTextsUnicharsSetRanges = specialTextsRanges;
    } else {
        self.specialTextsUnicharsSetRanges = nil;
    }
}

@end


static char const * const kKiwiHasSpecialText = "kKiwiHasSpecialText";
static char const * const kKiwiStringByReplaceWithWhiteSpace = "kKiwiStringByReplaceWithWhiteSpace";

@implementation NSString (SafeString)

/**
 *  @brief 如果包含特殊字符，比如阿拉伯文字，则替换为@" "，防止core text崩溃
 */
- (NSString *)safeString
{
    NSNumber *hasSpecialTextNumber = objc_getAssociatedObject(self, kKiwiHasSpecialText);
    
    if (!hasSpecialTextNumber) {
        hasSpecialTextNumber = [NSNumber numberWithBool:[self hasSpecialText]];
        objc_setAssociatedObject(self, kKiwiHasSpecialText, hasSpecialTextNumber, OBJC_ASSOCIATION_RETAIN);
    }
    
    if ([hasSpecialTextNumber boolValue]) {
        
        NSString *stringAfterReplaceSpecialText = objc_getAssociatedObject(self, kKiwiStringByReplaceWithWhiteSpace);
        
        if (!stringAfterReplaceSpecialText) {
            //有特殊字符，用空格替换
            stringAfterReplaceSpecialText = [self stringReplaceSpecialTextWithWhiteSpace];
            objc_setAssociatedObject(self, kKiwiStringByReplaceWithWhiteSpace, stringAfterReplaceSpecialText, OBJC_ASSOCIATION_RETAIN);
            KWSLogInfo(@"origin %@, after replace %@", self, stringAfterReplaceSpecialText);
        }
       
        return stringAfterReplaceSpecialText;
    } else {
        return self;
    }
}

- (NSString *)stringReplaceSpecialTextWithWhiteSpace
{
    NSString *text = self;
    
    HYSpecialTextFilter *textFilter = [HYSpecialTextFilter sharedObject];
    
    NSSet *specialTextsUnicharsSet = textFilter.specialTextsUnicharsSet;
    NSArray *specialTextsUnicharsSetRanges = textFilter.specialTextsUnicharsSetRanges;
    
    NSMutableString *tempMutableString = [[NSMutableString alloc] initWithCapacity:self.length];
    
    for (NSInteger i = 0; i < text.length; i++) {
        unichar c = [text characterAtIndex:i];
        
        if ([self isUnicharInSpecialText:c textFilter:textFilter specialTextsUnicharsSet:specialTextsUnicharsSet specialTextsUnicharsSetRanges:specialTextsUnicharsSetRanges]) {
            static unichar whitespaceUnichar = 32;
            [tempMutableString appendFormat:@"%C",whitespaceUnichar];
            KWSLogInfo(@"found special unichar %d", c);
        } else {
            [tempMutableString appendFormat:@"%C",c];
        }
    }
    
    return [tempMutableString copy];
}

//只要有一个特殊字符，就返回@""
- (NSString *)convertSpecialText:(NSString *)text
{
    if ([text hasSpecialText]) {
        return @"";
    } else {
        return text;
    }
}

- (BOOL)hasSpecialText
{
    if (![self length]) {
        return NO;
    }
    
    NSString *text = self;
    
    HYSpecialTextFilter *textFilter = [HYSpecialTextFilter sharedObject];
    
    NSSet *specialTextsUnicharsSet = textFilter.specialTextsUnicharsSet;
    NSArray *specialTextsUnicharsSetRanges = textFilter.specialTextsUnicharsSetRanges;
    
    BOOL hasSpecialText = NO;
    
    for (NSInteger i = 0; i < text.length; i++) {
        unichar c = [text characterAtIndex:i];
        
        if ([self isUnicharInSpecialText:c textFilter:textFilter specialTextsUnicharsSet:specialTextsUnicharsSet specialTextsUnicharsSetRanges:specialTextsUnicharsSetRanges]) {
            hasSpecialText = YES;
            KWSLogInfo(@"found special unichar %d, origin string:%@", c, self);
            break;
        }
    }
    
    return hasSpecialText;
}

- (BOOL)isUnicharInSpecialText:(unichar)character textFilter:(HYSpecialTextFilter *)textFilter specialTextsUnicharsSet:(NSSet *)specialTextsUnicharsSet specialTextsUnicharsSetRanges:(NSArray *)specialTextsUnicharsSetRanges
{
    //https://www.unicode.org/cldr/charts/28/keyboards/chars2keyboards.html#Telu 0x0C01 ~ 0x0C56 2018.2.23 2018春节期间崩溃
    if ((character >= 0x0600 && character <= 0x0700) ||
        (character >= 0x0C01 && character <= 0x0C56) ||
        [textFilter isUnicharInSpecialText:character specialTextsUnicharsSet:specialTextsUnicharsSet specialTextsUnicharsSetRanges:specialTextsUnicharsSetRanges]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)updateSpecialTextWithConfig:(NSDictionary *)config
{
    [[HYSpecialTextFilter sharedObject] updateSpecialTextWithConfig:config];
}

+ (BOOL)isNumberString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if (string.length > 0) {
        return NO;
    }
    
    return YES;
}

@end


static char const * const kKiwiXMLEscapedString = "KiwiXMLEscapedString";

@implementation NSString (KWSXML)

- (NSString *)stringByXMLEscaped
{
    NSMutableString *escapedString = objc_getAssociatedObject(self, kKiwiXMLEscapedString);
    
    if (!escapedString) {
        
        escapedString = [NSMutableString string];
        
        for (NSUInteger i = 0; i < self.length; ++i) {
            
            unichar ch = [self characterAtIndex:i];
            
            switch (ch) {
                case '\"': [escapedString appendString:@"&quot;"]; break;
                case '\'': [escapedString appendString:@"&apos;"]; break;
                case ' ' : [escapedString appendString:@"&nbsp;"]; break;
                case '&' : [escapedString appendString:@"&amp;" ]; break;
                case '<' : [escapedString appendString:@"&lt;"  ]; break;
                case '>' : [escapedString appendString:@"&gt;"  ]; break;
                default  : [escapedString appendFormat:@"%C", ch];
            }
        }
        
        objc_setAssociatedObject(self, kKiwiXMLEscapedString, escapedString, OBJC_ASSOCIATION_RETAIN);
    }
    
    return escapedString;
}

@end
