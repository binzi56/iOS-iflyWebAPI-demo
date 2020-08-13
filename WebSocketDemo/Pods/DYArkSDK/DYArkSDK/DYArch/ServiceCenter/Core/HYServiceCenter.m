//
//  ServiceCenter.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYServiceCenter.h"
#import "HYServiceManager.h"
#import "HYLogMacros.h"

@interface HYServiceCenter()

@property(nonatomic,strong) HYServiceManager* serviceManager;

@end

@implementation HYServiceCenter

+ (instancetype)sharedObject
{
    static dispatch_once_t onceToken;
    static HYServiceCenter *shareObject;
    
    dispatch_once(&onceToken, ^{
        shareObject = [[HYServiceCenter alloc] init];
    });
    return shareObject;
}

+ (id<IWFServiceManager>)sharedManager
{
    return [HYServiceCenter sharedObject].serviceManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _serviceManager = [[HYServiceManager alloc] init];
    }
    return self;
}

- (id)serviceWithProtocol:(Protocol *)protocol
{
    return [_serviceManager serviceWithProtocol:protocol];
}

- (void)registerLoader:(id<IWFServiceEntryLoader>)loader
{
    [self startLoader:loader];
}

- (void)unregisterLoader:(id<IWFServiceEntryLoader>)loader
{
    [self stopLoader:loader];
}

#pragma mark - loader

- (void)startLoader:(id<IWFServiceEntryLoader>)loader
{
    HYServiceEntryConfig* config = [loader loadHYServiceEntryConfig];
    
    if (config) {
        for (HYServiceEntry* entry in config.entrys) {
            if (entry.type == HYServiceEntryTypeShareObject) {
                [self.serviceManager registerService:entry.cls toProtocol:entry.protocol extraProtocol:entry.extraProtocol];
            }  else {
                KWSLogError(@"not supposed type");
            }
        }
    }
}

- (void)stopLoader:(id<IWFServiceEntryLoader>)loader
{
    HYServiceEntryConfig* config = [loader loadHYServiceEntryConfig];
    
    if (config) {
        for (HYServiceEntry* entry in config.entrys) {
            if (entry.type == HYServiceEntryTypeShareObject) {
                [self.serviceManager unregisterService:entry.protocol];
                if (entry.extraProtocol) {
                    [self.serviceManager unregisterExtraProtocol:entry.extraProtocol];
                }
            } else {
                KWSLogError(@"not supposed type");
            }
        }
    }

}

- (id)objectForKeyedSubscript:(Protocol*)key
{
    return [self serviceWithProtocol:key];
}

#pragma mark - convinient

+ (id)service:(Protocol*)protocl
{
    return [[self sharedObject] serviceWithProtocol:protocl];
}


@end
