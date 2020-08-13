//
//  KWSExtensionManager.h
//  KiwiSDK
//
//  Created by pengfeihuang on 15/8/6.
//  Copyright (c) 2015年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ENABLE_SAFE ([KWSExtensionManager sharedInstance].enableSafeOperation)

@interface KWSExtensionManager : NSObject

+ (KWSExtensionManager *)sharedInstance;

@property(nonatomic,assign) BOOL enableSafeOperation;

@end
