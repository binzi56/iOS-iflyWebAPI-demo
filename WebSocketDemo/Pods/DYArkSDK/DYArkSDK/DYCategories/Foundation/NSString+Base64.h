//
//  NSString+Base64.h
//  Wolf
//
//  Created by Tim on 2017/5/2.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Base64Additions)

+ (NSString *)base64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
