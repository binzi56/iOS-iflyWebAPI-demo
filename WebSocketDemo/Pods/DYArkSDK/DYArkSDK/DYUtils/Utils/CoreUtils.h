//
//  CoreUtils.h
//  yysdk
//
//  Created by 王 金华 on 12-9-7.
//  Copyright (c) 2012年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CARRIER_CMCC,
    CARRIER_UNICOM,
    CARRIER_CTL,
    CARRIER_UNKNOWN
} CarrierType;

@interface TagContent : NSObject

@property (atomic) NSRange range;
@property (strong, atomic) NSString *content;

@end

@interface CoreUtils : NSObject

+ (NSString *)getMacAddress;
+ (NSString *)readPList:(NSString *)plistFileName valueForKey:(NSString *)key;
+ (NSString *)getAppIdentifier;
+ (NSString *)getAppVersion;
+ (NSArray *)extractContentsBetweenTags:(NSString *)sourceString openingTag:(NSString *)openingTag closingTag:(NSString *)closingTag;
+ (NSString *)SPCode;
+ (NSString *)CountryCode;
+ (CarrierType)getCarrierType;
+ (NSString *)getDeviceModel;
+ (NSString *)getOSVersion;
+ (int64_t)convertVersionToInt:(NSString *)ver;
+ (NSString *)findXmlTag:(NSString *)src start:(NSString *)start end:(NSString *)end;
+(NSString *) getIPWithHostName:(const NSString *)hostName;

@end
