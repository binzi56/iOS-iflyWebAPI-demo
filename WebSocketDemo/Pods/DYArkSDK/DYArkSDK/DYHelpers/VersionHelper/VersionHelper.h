//
//  VersionHelper.h
//  kiwi
//
//  Created by Gideon-MacbookPro on 15/7/2.
//  Copyright (c) 2015年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KWSVersionPlatform) {
    KWSVersionPlatformIPhone = 1,
    KWSVersionPlatformIPad
};

@interface VersionHelper : NSObject

+ (BOOL)isSnapshotVersion;

+ (BOOL)isInternalVersion;

+ (BOOL)isDebugVersion;

///是否为外部公测的版本
+ (BOOL)isBeta;
@end
