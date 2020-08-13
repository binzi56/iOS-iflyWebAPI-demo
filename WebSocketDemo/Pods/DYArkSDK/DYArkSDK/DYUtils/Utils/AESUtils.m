//
//  AESUtils.m
//  Wolf
//
//  Created by Tim on 2017/5/2.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "AESUtils.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSData+Common.h"


NSString* aes_encrypt(NSString *message , NSString *password)
{
    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    return base64EncodedString;
}

NSString* aes_decrypt(NSString *base64EncodedString , NSString *password)
{
    NSData *encryptedData = [NSData dataFromBase64String:base64EncodedString];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

NSData* aes_encryptData(NSData *data , NSString *password)
{
    NSData *encryptedData = [data AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return encryptedData;
}

NSData* aes_decryptData(NSData *data , NSString *password)
{
    NSData *decryptedData = [data decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return decryptedData;
}

