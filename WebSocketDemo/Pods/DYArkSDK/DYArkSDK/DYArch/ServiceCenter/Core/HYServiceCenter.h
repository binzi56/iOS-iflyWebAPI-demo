//
//  ServiceCenter.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYServiceTypes.h"

#define HYService(procol)     ((NSObject<procol> *)[HYServiceCenter service:@protocol(procol)])
#define WFService(procol)     ((NSObject<procol> *)[HYServiceCenter service:@protocol(procol)])

@class HYServiceManager;

@interface HYServiceCenter : NSObject

+ (instancetype)sharedObject;

+ (id<IWFServiceManager>)sharedManager;

- (id<IWFServiceManager>)serviceManager;

- (void)registerLoader:(id<IWFServiceEntryLoader>)loader;

- (void)unregisterLoader:(id<IWFServiceEntryLoader>)loader;

- (id)objectForKeyedSubscript:(Protocol*)key;

#pragma mark - convinient

+ (id)service:(Protocol*)protocl;

@end
