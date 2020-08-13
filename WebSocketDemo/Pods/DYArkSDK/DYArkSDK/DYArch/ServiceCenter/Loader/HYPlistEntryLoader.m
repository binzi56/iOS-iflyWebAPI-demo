//
//  HYPlistServiceLoader.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYPlistEntrtyLoader.h"
#import "VersionHelper.h"

static NSString* kEntryImplKey          = @"impl";
static NSString* kEntryMockImplKey      = @"mockImpl";
static NSString* kEntryProtocolKey      = @"protocol";
static NSString* kEntryExtraProtocolKey = @"extraProtocol";
static NSString* kEntryTypeKey          = @"type";

@implementation HYPlistEntrtyLoader

- (HYServiceEntryConfig*)loadHYServiceEntryConfig
{
    if (!self.filePath) {
        return nil;
    }
    
    NSArray *serviceList = [[NSArray alloc] initWithContentsOfFile:self.filePath];
    
    if (!serviceList) {
        return nil;
    }
    
    HYServiceEntryConfig* config = [[HYServiceEntryConfig alloc] init];
    NSMutableArray* entryList = [NSMutableArray arrayWithCapacity:serviceList.count];
    
    for (NSDictionary* dict in serviceList) {
        NSString* clsStr = [dict objectForKey:kEntryImplKey];
        
        if ([VersionHelper isInternalVersion]) {
            if (self.enableMock) {
                NSString* mockClsStr = [dict objectForKey:kEntryMockImplKey];
                
                if (mockClsStr && mockClsStr.length) {
                    clsStr = mockClsStr;
                }
            }
        }
        
        NSString* protocolStr = [dict objectForKey:kEntryProtocolKey];
        NSString* extraProtocolStr = [dict objectForKey:kEntryExtraProtocolKey];
        
        if (clsStr && protocolStr) {
            Class cls = NSClassFromString(clsStr);
            Protocol* protocol = NSProtocolFromString(protocolStr);
            Protocol* extraProtocol = NSProtocolFromString(extraProtocolStr);
            
            if (cls && protocol != NULL) {
                
                HYServiceEntryType type = HYServiceEntryTypeShareObject;
                HYServiceEntry* entry = [[HYServiceEntry alloc] initWithClass:cls protocol:protocol extraProtocol:extraProtocol type:type];
                [entryList addObject:entry];
            }
            
        }
    }
    
    config.entrys = entryList;
    return config;
}

@end
