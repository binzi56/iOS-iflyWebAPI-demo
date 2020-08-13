//
//  AESUtils.h
//  Wolf
//
//  Created by Tim on 2017/5/2.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>


NSString* aes_encrypt(NSString *message , NSString *password);

NSString* aes_decrypt(NSString *base64EncodedString , NSString *password);

NSData* aes_encryptData(NSData *data , NSString *password);

NSData* aes_decryptData(NSData *data , NSString *password);
