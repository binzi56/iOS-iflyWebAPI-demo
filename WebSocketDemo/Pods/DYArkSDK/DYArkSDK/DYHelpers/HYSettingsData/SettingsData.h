//
//  yysettings.h
//  ipadyy
//
//  Created by Justin on 14-4-16.
//  Copyright (c) 2014年 YY.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsData : NSObject

+ (instancetype)sharedObject;

- (id)getValueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)removeValueForKey:(NSString *)key;

- (void)setCustomValue:(id<NSCoding>)value forKey:(NSString *)key;
- (id<NSCoding>)getCustomValueForKey:(NSString *)key;

@end
