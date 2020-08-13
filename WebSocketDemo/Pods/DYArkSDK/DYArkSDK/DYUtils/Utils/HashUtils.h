//
//  HashUtils.h
//  
//
//  Created by Wu Wenqing on 12-9-17.
//  Copyright (c) 2012年 Wu Wenqing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HashUtils : NSObject

+ (NSString *)sha1HexString:(NSString *)str;
+ (NSString *)md5HexString:(NSString *)str;

+ (NSString *)fileMd5HexString:(NSString *)filePath;
+ (NSString *)fileSha1HexString:(NSString *)filePath;

+ (NSString *)dataMd5HexString:(NSData *)data;

+ (NSString *)base64Encoding:(NSData *)data;
@end