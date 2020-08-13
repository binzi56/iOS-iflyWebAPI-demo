//
//  HYJSONHelper.m
//  HYBase
//
//  Created by Gideon on 2017/5/3.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "HYJSONHelper.h"
#import "KiwiSDKMacro.h"

@implementation NSString(HYJSONHelper)

- (id)hyObjectFromJSONString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        KWSLogInfo(@"%@", error);
        return nil;
    }
    return obj;
}

@end

@implementation NSData(HYJSONHelper)

- (id)hyObjectFromJSONData
{
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    if (error) {
        KWSLogInfo(@"%@", error);
        return nil;
    }
    return obj;
}

@end

@implementation NSDictionary(HYJSONHelper)

- (NSString *)hyJSONString
{
    //默认使用kNilOptions，不使用NSJSONWritingPrettyPrinted
    NSError *error = nil;
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        data = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    } else {
        KWSLogError(@"invalid Json object");
    }
    
    if ([data length] == 0 || error){
        KWSLogInfo(@"%@, %lu", error, (unsigned long)[data length]);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end


@implementation NSArray(HYJSONHelper)

- (NSString *)hyJSONString
{
    //默认使用kNilOptions，不使用NSJSONWritingPrettyPrinted
    NSError *error = nil;
    NSData *data = nil;
    if ([NSJSONSerialization isValidJSONObject:self]) {
        data = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    } else {
        KWSLogError(@"invalid Json object");
    }
    
    if ([data length] == 0 || error){
        KWSLogInfo(@"%@, %lu", error, (unsigned long)[data length]);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
