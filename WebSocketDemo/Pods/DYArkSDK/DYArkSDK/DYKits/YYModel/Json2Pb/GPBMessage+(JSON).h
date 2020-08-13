//
//  GPBMessage+(JSON).h
//  Wolf
//
//  Created by huang pengfei on 2017/11/16.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
#import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "GPBDictionary.h"
#endif

@interface GPBMessage (JSON)

+ (void)json2pbInternal:(GPBMessage*)msg dict:(NSDictionary *)dict;

- (id)initWithJsonString:(NSString*)data;

- (NSDictionary*)toJsonDict;

- (NSString*)toJsonString;

@end
