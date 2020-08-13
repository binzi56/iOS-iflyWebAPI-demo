//
//  HYAnontionServiceLoader.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYAnontionEntryLoader.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "HYJSONHelper.h"

static NSArray<NSString *>* BHReadConfiguration(char *section)
{
    NSMutableArray *configs = [NSMutableArray array];
    
    Dl_info info;
    dladdr(BHReadConfiguration, &info);
    
#ifndef __LP64__
    //        const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", section, & size);
#endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        char *string = (char*)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
//        DYLogInfo(@"config = %@", str);
        if(str) [configs addObject:str];
    }
    
    return configs;
    
}

@implementation HYAnontionEntryLoader

+ (NSArray<NSString *> *)annotationServices
{
    static NSArray<NSString *> *services = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        services = BHReadConfiguration(HYServiceSectName);
    });
    return services;
}

- (HYServiceEntryConfig*)loadHYServiceEntryConfig
{
    HYServiceEntryConfig* config = [[HYServiceEntryConfig alloc] init];
    
    NSArray* serviceEntrys = [self entrysWithAnnotation:[HYAnontionEntryLoader annotationServices] type:HYServiceEntryTypeShareObject];
    
    NSMutableArray* list = [NSMutableArray arrayWithArray:serviceEntrys];
    [list addObjectsFromArray:serviceEntrys];
    
    config.entrys = list;
    
    return config;
}

- (NSArray<HYServiceEntry*>*)entrysWithAnnotation:(NSArray<NSString *>*)services type:(HYServiceEntryType)type
{
    NSMutableArray* servicesEntrys = [NSMutableArray arrayWithCapacity:services.count];
    
    for (NSString *map in services) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [jsonData hyObjectFromJSONData];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                
                NSString *protocolName = [json allKeys][0];
                NSString *clsName  = [json allValues][0];
                
                if (protocolName && clsName) {
                    Protocol* proto = NSProtocolFromString(protocolName);
                    Class cls = NSClassFromString(clsName);
                    
                    if (cls && proto != NULL) {
                        HYServiceEntry* entry = [[HYServiceEntry alloc] initWithClass:cls protocol:proto type:type];
                        [servicesEntrys addObject:entry];
                    }
                }
            }
        }
    }
    return servicesEntrys;
}

@end
