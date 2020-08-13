//
//  RSAUtils.h
//  Wolf
//
//  Created by Tim on 2017/5/2.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>


//以下方法从文件读取公私秘钥
//验证签名 Sha1 + RSA
BOOL rsa_verifyString_pubKey(NSString* string ,NSString* signString ,NSString* publicKeyPath);
//验证签名 md5 + RSA
BOOL rsa_verifyMD5String_pubKey(NSString* string ,NSString* signString ,NSString* publicKeyPath);
//签名sha1
NSString* rsa_signString_priKey(NSString* string ,NSString* privateKeyPath);
//签名md5
NSString* rsa_signMD5String_priKey(NSString* string ,NSString* privateKeyPath);

//公钥加密
NSString* rsa_encrypt_pubKey(NSString* content, NSString* publicKeyPath);
//私钥解密
NSString* rsa_decrypt_priKey(NSString* content, NSString* privateKeyPath);
