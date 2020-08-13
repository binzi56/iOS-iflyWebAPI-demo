//
//  PluginManager.h
//  kiwi
//
//  Created by pengfeihuang on 16/7/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginTypes.h"

@interface PluginManager : NSObject<IPlugInstaller>

#pragma mark - public

- (void)addPlugin:(id<IPlugin>)plugin;

- (void)removePlugin:(id<IPlugin>)plugin;

- (void)unmountAllPlugins;

- (NSArray *)currentPlugins;

- (BOOL)checkAllPluginsHasSubView;

@end
