//
//  yysettings.m
//  ipadyy
//
//  Created by Justin on 14-4-16.
//  Copyright (c) 2014年 YY.com. All rights reserved.
//

#import "SettingsData.h"
#import "AppFileUtils.h"
#import "HYLogMacros.h"

@interface SettingsData ()
@end

@implementation SettingsData

+ (instancetype)sharedObject
{
    static SettingsData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void){
        sharedInstance = [[SettingsData alloc] init];
    });
    return sharedInstance;
}

- (id)getValueForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (!value || !key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeValueForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCustomValue:(id<NSCoding>)value forKey:(NSString *)key
{
    @try {
        if (value) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
            if (data != nil) {
                [self setValue:data forKey:key];
            }
        } else {
            [self setValue:value forKey:key];
        }
    } @catch (NSException *exception) {
        DYLogError(@"%@", [exception description]);
    }
}

- (id<NSCoding>)getCustomValueForKey:(NSString *)key
{
    id result = nil;
    
     @try {
        result = [self getValueForKey:key];
        
        if ([result isKindOfClass:[NSData class]]) {
            result = [NSKeyedUnarchiver unarchiveObjectWithData:result];
        }
     } @catch (NSException* exception) {
         DYLogError(@"%@", [exception description]);
     }
    return result;
}


@end
