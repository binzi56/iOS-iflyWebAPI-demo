//
//  VersionHelper.m
//  kiwi
//
//  Created by Gideon-MacbookPro on 15/7/2.
//  Copyright (c) 2015年 YY Inc. All rights reserved.
//

#import "VersionHelper.h"
#import "DYArkSDKManager.h"

@implementation VersionHelper

+ (BOOL)isSnapshotVersion
{
    return (DYEnvironmentVersionSnapshot  ==  [DYArkSDKManager sharedInstance].environment);
}

+ (BOOL)isInternalVersion
{
    return [self isSnapshotVersion] || [self isDebugVersion];
}

+ (BOOL)isDebugVersion
{
    return (DYEnvironmentVersionDebug  ==  [DYArkSDKManager sharedInstance].environment);
}

+ (BOOL)isBeta
{
    return [DYArkSDKManager sharedInstance].isBeta;
}

@end
