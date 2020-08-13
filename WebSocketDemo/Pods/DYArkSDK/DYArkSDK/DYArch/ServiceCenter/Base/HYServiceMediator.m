//
//  HYServiceLoader.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYServiceMediator.h"
#import "HYTestLoader.h"
#import "HYAnontionEntryLoader.h"
#import "HYPlistEntrtyLoader.h"
#import "HYTestService.h"

@implementation WFServiceConfig


@end

@implementation WFServiceMediator

//服务中心中间间
+ (void)setupWithConfig:(WFServiceConfig*)config
{
    if (config.customEntryLoader) {
        [[HYServiceCenter sharedObject] registerLoader:config.customEntryLoader];
    }
    
    //HYAnontionEntryLoader* anonloader = [[HYAnontionEntryLoader alloc] init];
    //[[HYServiceCenter sharedObject] registerLoader:anonloader];
    
    if (config.servicesPlistPath) {
        HYPlistEntrtyLoader* plistLoader = [[HYPlistEntrtyLoader alloc] init];
        plistLoader.filePath = config.servicesPlistPath;
        plistLoader.enableMock = config.enableMock;
        [[HYServiceCenter sharedObject] registerLoader:plistLoader];
    }
    
    [WFServiceMediator loadServices:config.launchServices];
    
    if (config.delayLaunchServices && config.delayLaunchServices.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WFServiceMediator loadServices:config.delayLaunchServices];
        });
    }
    
    if (config.secondaryDelayLaunchServices && config.secondaryDelayLaunchServices.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WFServiceMediator loadServices:config.secondaryDelayLaunchServices];
        });
    }
}

+ (void)loadServices:(NSArray<Protocol*>*)services
{
    for (NSInteger i = 0; i < services.count; i++) {
        Protocol* proto = [services objectAtIndex:i];
        if (proto != NULL) {
            [HYServiceCenter service:proto];
        }
    }
}

+ (void)testSetup
{
    HYTestLoader* loader = [[HYTestLoader alloc] init];
    [[HYServiceCenter sharedObject] registerLoader:loader];
    
    
    [HYService(IHYTestService) foo];
    
    HYAnontionEntryLoader* anonloader = [[HYAnontionEntryLoader alloc] init];
    [[HYServiceCenter sharedObject] registerLoader:anonloader];
    [HYService(IHYTestAnontionService) foo];
    
    HYPlistEntrtyLoader* plistLoader = [[HYPlistEntrtyLoader alloc] init];
    plistLoader.filePath = [[NSBundle mainBundle] pathForResource:@"testServices" ofType:@"plist"];
    [[HYServiceCenter sharedObject] registerLoader:plistLoader];
    
    [HYService(IHYTestPlistService) hello];
}

@end
