//
//  KWSExtensionManager.m
//  KiwiSDK
//
//  Created by pengfeihuang on 15/8/6.
//  Copyright (c) 2015年 YY.Inc. All rights reserved.
//

#import "KWSExtensionManager.h"

@implementation KWSExtensionManager

+ (KWSExtensionManager *)sharedInstance
{
    static KWSExtensionManager *_shareInstance = nil;
    static  dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _shareInstance = [[KWSExtensionManager alloc] init];
    });
    return _shareInstance;
}

@end
