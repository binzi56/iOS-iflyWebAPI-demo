//
//  HashUtils.m
//  
//
//  Created by Wu Wenqing on 12-9-17.
//  Copyright (c) 2012年 Wu Wenqing. All rights reserved.
//

#import "HashUtils.h"

#import <CommonCrypto/CommonDigest.h>
//#import <openssl/bio.h>
//#import <openssl/evp.h>

static const int kMd5BufferLength = 16;
static const int kSHa1BufferLength = 20;

@interface NSString_Hash : NSObject 

+ (NSString *)stringForMD5:(NSString *)str;
+ (NSString *)stringForSHA1:(NSString *)str;

@end

@interface NSData_Hash : NSObject

+ (NSData *)dataForMD5:(NSData *)data;
+ (NSData *)dataForSHA1:(NSData *)data;
+ (NSString *)hexString:(NSData *)data;

@end

@interface NSFileHandle_Hash : NSObject

+ (NSString *)fileMD5HexString:(NSFileHandle *)handler;
+ (NSString *)fileSHA1HexString:(NSFileHandle *)handler;

@end

@implementation HashUtils

+ (NSString *)sha1HexString:(NSString *)str
{
    return [NSString_Hash stringForSHA1:str];
}

+ (NSString *)md5HexString:(NSString *)str
{
    return [NSString_Hash stringForMD5:str];
}

+ (NSString *)fileMd5HexString:(NSString *)filePath
{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil)
        return nil;
    return [NSFileHandle_Hash fileMD5HexString:handle];
}

+ (NSString *)fileSha1HexString:(NSString *)filePath
{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil)
        return nil;
    return [NSFileHandle_Hash fileSHA1HexString:handle];
}

+ (NSString *)dataMd5HexString:(NSData *)data
{
    NSData *md5Data = [NSData_Hash dataForMD5:data];
    NSString *hexString = [NSData_Hash hexString:md5Data];
    return hexString;
}

//+ (NSString *)base64Encoding:(NSData *)data
//{
//    BIO *context = BIO_new( BIO_s_mem() );
//    
//    // Tell the context to encode base64
//    BIO *command = BIO_new( BIO_f_base64() );
//    context = BIO_push( command, context );
//    
//    // Encode all the data
//    BIO_set_flags( context, BIO_FLAGS_BASE64_NO_NL );
//    BIO_write( context, data.bytes, (int)[data length] );
//    int ret = BIO_flush( context );// make compiler happy.
//#pragma unused(ret)
//    
//    // Get the data out of the context
//    char *outputBuffer = NULL;
//    long outputLength = BIO_get_mem_data( context, &outputBuffer );
//    NSString *encodedString =
//    [[NSString alloc] initWithBytes:outputBuffer
//                             length:outputLength
//                           encoding:NSASCIIStringEncoding];
//    
//    BIO_free_all( context );
//    return encodedString;
//}

@end


@implementation NSString_Hash

+ (NSString *)stringForMD5:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *md5data = [NSData_Hash dataForMD5:data];
    return [NSData_Hash hexString:md5data];
}

+ (NSString *)stringForSHA1:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sha1data = [NSData_Hash dataForSHA1:data];
    return [NSData_Hash hexString:sha1data];
}

@end

@implementation NSData_Hash

+ (NSData *)dataForMD5:(NSData *)data
{
    const char *str = [data bytes];
    unsigned char digest[kMd5BufferLength];
    CC_MD5(str, (uint32_t)[data length], digest);
    return [NSData dataWithBytes:digest length:kMd5BufferLength];
}

+ (NSData *)dataForSHA1:(NSData *)data
{
    const unsigned char *buffer = [data bytes];
    unsigned char result[kSHa1BufferLength];
    CC_SHA1(buffer, (uint32_t)[data length], result);
    return [NSData dataWithBytes:result length:kSHa1BufferLength];
}

+ (NSString *)hexString:(NSData *)data
{
    const int length = (int)[data length];
    const unsigned char *str = [data bytes];
    NSMutableString *hexStr = [NSMutableString stringWithCapacity:length*2];
    for (int i=0; i<length; i++) {
        [hexStr appendFormat:@"%02x", str[i]];
    }
    return hexStr;
}

@end

static const int kBufferSize = 1024;

@implementation NSFileHandle_Hash

+ (NSString *)fileMD5HexString:(NSFileHandle *)handler
{
    assert(self != nil);
    CC_MD5_CTX ctx;
    CC_MD5_Init(&ctx);
    NSData* data = [handler readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        CC_MD5_Update(&ctx, [data bytes], (uint32_t)[data length]);
        data = [handler readDataOfLength:kBufferSize];
    }
    unsigned char result[kMd5BufferLength];
    CC_MD5_Final(result, &ctx);
    NSData *resultData = [NSData dataWithBytes:result length:kMd5BufferLength];
    return [NSData_Hash hexString:resultData];
}

+ (NSString *)fileSHA1HexString:(NSFileHandle *)handler
{
    assert(self != nil);
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    NSData* data = [handler readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        CC_SHA1_Update(&ctx, [data bytes], (uint32_t)[data length]);
        data = [handler readDataOfLength:kBufferSize];
    }
    unsigned char result[kSHa1BufferLength];
    CC_SHA1_Final(result, &ctx);
    NSData* resultData = [NSData dataWithBytes:result length:kSHa1BufferLength];
    return [NSData_Hash hexString:resultData];
}

@end

