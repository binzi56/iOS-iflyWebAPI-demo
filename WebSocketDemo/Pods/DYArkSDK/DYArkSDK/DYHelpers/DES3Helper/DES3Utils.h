//
//  DES3Utils.h
//  kiwi
//
//  Created by maihx on 14-4-8.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Utils : NSObject

+ (NSString *)encrypt:(NSString *)plainText;
+ (NSString *)decrypt:(NSString *)encryptedText;

@end
