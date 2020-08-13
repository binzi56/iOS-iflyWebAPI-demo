//
//  HYStyleManager.h
//  kiwi
//
//  Created by pengfeihuang on 16/11/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYStyleManager : NSObject

+ (instancetype)sharedManager;

+ (UIColor*)colorWithHexString:(NSString*)hexString;

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end
