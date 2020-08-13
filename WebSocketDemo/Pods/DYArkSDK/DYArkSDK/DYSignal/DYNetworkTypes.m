//
//  DYNetworkTypes.m
//  DYArkSDK
//
//  Created by flyhuang on 2018/10/23.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import "DYNetworkTypes.h"
#import "KiwiSDKMacro.h"

@implementation Error

@end


@implementation NetworkServiceError

- (BOOL)hasError
{
    if (self.error) {
        return YES;
    }
    
    if (self.busiError && self.busiError.code != 0) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)code
{
    if (self.error) {
        return self.error.code;
    }
    
    if (self.busiError && self.busiError.code != 0) {
        return self.busiError.code;
    }
    
    return 0;
}

- (NSString*)description
{
    return [self errorDescribe];
}

- (NSString*)errorMessage
{
    NSString* errorTip = @"UnknownError";
    
    if (self.busiError && self.busiError.code != 0) {
        errorTip = self.busiError.message;
    } else if (self.error) {
        errorTip = L(@"ClientError");
    } else {
        errorTip = @"no error";
    }
    
    return errorTip;
}

- (NSString*)errorDescribe
{
    NSString* errorTip = @"UnknownError";
    
    if (self.busiError && self.busiError.code != 0) {
        errorTip = self.busiError.logDescription;
    } else if (self.error) {
        errorTip = L(@"ClientError");
    } else {
        errorTip = @"no error";
    }
    
    return errorTip;
}

@end


