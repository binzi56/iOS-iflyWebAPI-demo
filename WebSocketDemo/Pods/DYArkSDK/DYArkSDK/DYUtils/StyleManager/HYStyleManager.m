//
//  HYStyleManager.m
//  kiwi
//
//  Created by pengfeihuang on 16/11/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYStyleManager.h"
#import "HYCacheManager.h"
#import <HexColors/HexColors.h>

@interface HYStyleManager()

@property(nonatomic,strong) id<IHYCache> memoryCache;

@end

@implementation HYStyleManager

+ (instancetype)sharedManager
{
    static id sharedCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCacheManager = [[self alloc] init];
    });
    return sharedCacheManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _memoryCache = [HYCacheManager createMemoryCache];
    }
    return self;
}

+ (UIColor*)colorWithHexString:(NSString*)hexString
{
    return [[self sharedManager] colorWithHexString:hexString];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[self sharedManager] colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor*)colorWithHexString:(NSString*)hexString
{
    //#FFFF00，颜色字符串最低要求有6个字符，否则认为非法，release版返回ClearColor
    if ([hexString length] < 6) {
        NSAssert(0, @"hexString %@ illegal", hexString);
        return [UIColor clearColor];
    }
    NSString* key = hexString ? [hexString lowercaseString] : @"";
    UIColor* color = [_memoryCache objectForKey:key];
    if (!color) {
        color = [UIColor hx_colorWithHexString:key];
        if (color) {
            [_memoryCache setObject:color forKey:key];
        }
    }
    return color;
}

- (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSString* colorIdendifier = [NSString stringWithFormat:@"color:%0.2f_%0.2f_%0.2f_%0.2f",red,green,blue,alpha];
    UIColor* color = [_memoryCache objectForKey:colorIdendifier];
    if (!color) {
        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        if (color) {
            [_memoryCache setObject:color forKey:colorIdendifier];
        }
    }
    return color;
}

@end
