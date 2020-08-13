//
//  HYTestLoader.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/9.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYTestLoader.h"
#import "HYTestService.h"

@implementation HYTestLoader

- (HYServiceEntryConfig*)loadHYServiceEntryConfig
{
    HYServiceEntryConfig* config = [[HYServiceEntryConfig alloc] init];
    
    NSMutableArray* entrys = [NSMutableArray arrayWithCapacity:2];
    HYServiceEntry* serviceEntry = [[HYServiceEntry alloc] initWithClass:NSClassFromString(@"HYTestService")
                                                                protocol:@protocol(IHYTestService)
                                                                    type:HYServiceEntryTypeShareObject];
    [entrys addObject:serviceEntry];
    config.entrys = entrys;
    
    return config;
}

@end
