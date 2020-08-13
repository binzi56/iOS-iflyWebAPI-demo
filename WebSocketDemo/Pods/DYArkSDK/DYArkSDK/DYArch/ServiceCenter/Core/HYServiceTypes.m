//
//  ServiceTypes.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYServiceTypes.h"

@implementation HYServiceEntryConfig

@end

@interface HYServiceEntry()

@property(nonatomic,strong) Class cls;
@property(nonatomic,strong) Protocol* protocol;
@property(nonatomic,strong) Protocol* extraProtocol;
@end

@implementation HYServiceEntry

- (id)initWithClass:(Class)theClass
           protocol:(Protocol *)protocol
      extraProtocol:(Protocol *)extraProtocol
               type:(HYServiceEntryType)type
{
    if (self = [super init]) {
        _cls = theClass;
        _protocol = protocol;
        _extraProtocol = extraProtocol;
        _type = type;
    }
    return self;
}

- (id)initWithClass:(Class)theClass
           protocol:(Protocol *)protocol
               type:(HYServiceEntryType)type
{
    return [self initWithClass:theClass protocol:protocol extraProtocol:nil type:type];
}

@end
