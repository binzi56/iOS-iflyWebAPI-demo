//
//  PluginProtocols.h
//  kiwi
//
//  Created by pengfeihuang on 16/7/14.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCenter.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(uint32_t, PluginLoadStatus)
{
    PluginLoadStatusNone = 0,
    PluginLoadStatusDidMount = 1,
    PluginLoadStatusDidUnmount = 2,
    PluginLoadStatusWaiting = 3,
    PluginLoadStatusCanceled = 4,
};

#pragma mark -

@protocol ITask <NSObject>

@optional
@property (assign, nonatomic) BOOL finished;

@end

#pragma mark -

@class PluginLoadPolicy;

@protocol IPlugin <NSObject, ITask>

@required

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) PluginLoadPolicy *loadPolicy;
@property (assign, nonatomic) PluginLoadStatus loadStatus;

- (void)registerEvent:(NSString*)event object:(id)object callback:(EventTriggerBlock)callback;

- (void)unRegisterEventWithObject:(id)object;

- (void)dispatchEvent:(NSString*)event userInfo:(NSDictionary*)userInfo;

@optional

//插件即将加进管理器
- (void)pluginWillMount;

//插件已经加进管理器
- (void)pluginDidMount;

//插件即将从管理中被移除
- (void)pluginWillUnmount;

//插件被移除完毕
- (void)pluginDidUnmount;

//插件需要更新
- (void)pluginNeedUpdate;

//插件是否有展开界面
- (BOOL)pluginHasSubview;

//插件需要重置为默认
- (void)pluginNeedResetDefault;

//视图safeAreaDidChanged
- (void)channelViewSafeAreaDidChanged:(UIEdgeInsets)insets;

@end

@protocol IPlugInstaller <NSObject>

@required

- (id<IPlugin>)installedPlugin:(NSString *)identifier protocol:(Protocol *)aProtocol;

@end

#pragma mark -

@protocol IPlugContainer <NSObject,IPlugInstaller>

@required

- (EventCenter*)plugEventCenter;

- (UIViewController*)plugRootController;

@optional

- (UIViewController*)plugContainerController:(id<IPlugin>)plugin;

- (UIView*)plugContainer:(id<IPlugin>)plugin;

@end
