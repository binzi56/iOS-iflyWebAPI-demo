//
//  RSAUtils.m
//  Wolf
//
//  Created by Tim on 2017/5/2.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "RSAUtils.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/md5.h>
#include <Security/Security.h>

#import "NSData+Common.h"
#import "NSData+CommonCrypto.h"

typedef enum {
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}RSA_PADDING_TYPE;

#define  PADDING   RSA_PADDING_TYPE_PKCS1


static RSA* _rsa_pub;
static RSA* _rsa_pri;


static void loadRSAPublickWithFile(NSString* filePath)
{
    if (!filePath.length) {
        return;
    }
    
    const char* cPath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
    FILE* file = fopen(cPath, "rb");
    if (!file) {
        return ;
    }
    
    _rsa_pub = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL);
    if (!_rsa_pub) {
        return ;
    }
    
    fclose(file);
}

static void loadRSAPrivateWithFile(NSString* filePath)
{
    if (!filePath.length) {
        return;
    }
    
    const char* cPath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
    FILE* file = fopen(cPath, "rb");
    if (!file) {
        return ;
    }
    
    _rsa_pri = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL);
    if (!_rsa_pri) {
        return ;
    }
    
    fclose(file);
}

static int getBlockSizeWithRSAPaddingType(RSA_PADDING_TYPE type, RSA* rsa)
{
    int len = RSA_size(rsa);
    if (type == RSA_PADDING_TYPE_PKCS1 || type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

//signString为base64字符串
BOOL rsa_verifyString_pubKey(NSString* string ,NSString* signString ,NSString* publicKeyPath)
{
    if (!_rsa_pub) {
        loadRSAPublickWithFile(publicKeyPath);
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    int verify_ok = RSA_verify(NID_sha1
                               , sha1, 20
                               , sig, sig_len
                               , _rsa_pub);
    
    return (1 == verify_ok) ? YES:NO;
}


BOOL rsa_verifyMD5String_pubKey(NSString* string ,NSString* signString ,NSString* publicKeyPath)
{
    if (!_rsa_pub) {
        loadRSAPublickWithFile(publicKeyPath);
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    // int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    int verify_ok = RSA_verify(NID_md5
                               , digest, MD5_DIGEST_LENGTH
                               , sig, sig_len
                               , _rsa_pub);
    
    return (1 == verify_ok) ? YES:NO;
}

NSString* rsa_signString_priKey(NSString* string ,NSString* privateKeyPath)
{
    if (!_rsa_pri) {
        loadRSAPrivateWithFile(privateKeyPath);
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    
    int rsa_sign_valid = RSA_sign(NID_sha1
                                  , sha1, 20
                                  , sig, &sig_len
                                  , _rsa_pri);
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}

NSString* rsa_signMD5String_priKey(NSString* string ,NSString* privateKeyPath)
{
    if (!_rsa_pri) {
        loadRSAPrivateWithFile(privateKeyPath);
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    //int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    
    int rsa_sign_valid = RSA_sign(NID_md5
                                  , digest, MD5_DIGEST_LENGTH
                                  , sig, &sig_len
                                  , _rsa_pri);
    
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}


NSString* rsa_encrypt_pubKey(NSString* content, NSString* publicKeyPath)
{
    if (!_rsa_pub) {
        loadRSAPublickWithFile(publicKeyPath);
    }
    
    int length = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }
    
    NSInteger flen = getBlockSizeWithRSAPaddingType(PADDING ,_rsa_pub);
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    int status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa_pub, PADDING);
    
    if (status) {
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        free(encData);
        encData = NULL;
        
        //NSString *ret = [returnData base64EncodedString];
        NSString *ret = [returnData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
        return ret;
    }
    
    free(encData);
    encData = NULL;
    
    return nil;
}

NSString* rsa_decrypt_priKey(NSString* content, NSString* privateKeyPath)
{
    if (!_rsa_pri) {
        loadRSAPrivateWithFile(privateKeyPath);
    }
    
    //NSData *data = [content base64DecodedData];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    int length = (int)[data length];
    
    NSInteger flen = getBlockSizeWithRSAPaddingType(PADDING ,_rsa_pub);
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    int status = RSA_private_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa_pri, PADDING);
    if (status) {
        NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData length:strlen(decData) encoding:NSASCIIStringEncoding];
        free(decData);
        decData = NULL;
        return decryptString;
    }
    
    free(decData);
    decData = NULL;
    
    return nil;
}
