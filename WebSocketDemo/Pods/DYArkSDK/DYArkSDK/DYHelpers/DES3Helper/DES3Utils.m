//
//  DES3Utils.m
//  kiwi
//
//  Created by maihx on 14-4-8.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import "DES3Utils.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

static NSString * const kSecretKey = @"aefd@93f1-5$a84!ea2#931f";
static NSString * const kIv        = @"01234567";

@implementation DES3Utils

+ (NSString *)encrypt:(NSString *)plainText
{
    NSData* plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [plainData length];
    size_t bufferSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    void *pBuffer = malloc(bufferSize * sizeof(uint8_t));
    memset(pBuffer, 0x0, bufferSize);
    
    size_t encryptedSize = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                                       kCCAlgorithm3DES,
                                       kCCOptionPKCS7Padding,
                                       (const void *)[kSecretKey UTF8String],
                                       kCCKeySize3DES,
                                       (const void *)[kIv UTF8String],
                                       [plainData bytes],
                                       plainTextBufferSize,
                                       pBuffer,
                                       bufferSize,
                                       &encryptedSize);
    if (ccStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:pBuffer length:encryptedSize];
        return [GTMBase64 stringByEncodingData:resultData];
    } else {
        free(pBuffer);
        return nil;
    }
}

+ (NSString *)decrypt:(NSString *)encryptedText
{
    NSData *encryptedData = [GTMBase64 decodeData:[encryptedText dataUsingEncoding:NSUTF8StringEncoding]];
    size_t encryptedTextBufferSize = [encryptedData length];
    size_t bufferSize = (encryptedTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    void *pBuffer = malloc(bufferSize * sizeof(uint8_t));
    memset(pBuffer, 0x0, bufferSize);
    
    size_t decryptedSize = 0;
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithm3DES,
                                       kCCOptionPKCS7Padding,
                                       (const void *)[kSecretKey UTF8String],
                                       kCCKeySize3DES,
                                       (const void *)[kIv UTF8String],
                                       [encryptedData bytes],
                                       encryptedTextBufferSize,
                                       pBuffer,
                                       bufferSize,
                                       &decryptedSize);
    if (ccStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:pBuffer length:decryptedSize];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    } else {
        free(pBuffer);
        return nil;
    }
}

@end
