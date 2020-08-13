//
//  HYTestService.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/9.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYTestService.h"
#import "KiwiSDKMacro.h"

@implementation HYTestService

+ (HYTestService *)sharedObject
{
    static HYTestService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[HYTestService alloc] init];
    });
    return service;
}

- (void)foo
{
    KWSLogInfo(@"");
}

@end

HYExportService(IHYTestAnontionService, HYAnontionService);

@implementation HYAnontionService

+ (HYAnontionService *)sharedObject
{
    static HYAnontionService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[HYAnontionService alloc] init];
    });
    return service;
}

- (void)foo
{
    KWSLogInfo(@"");
}

@end

@implementation HYPlistService

- (void)hello
{
    KWSLogInfo(@"");
}

@end
