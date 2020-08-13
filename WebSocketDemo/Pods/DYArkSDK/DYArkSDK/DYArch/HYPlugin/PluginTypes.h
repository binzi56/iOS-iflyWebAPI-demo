//
//  PluginTypes.h
//  kiwi
//
//  Created by pengfeihuang on 16/7/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCenter.h"
#import "PluginProtocols.h"

typedef NS_ENUM(NSInteger, PluginLoadMode) {
    PluginLoadModeNone            = 0,/**< */
    PluginLoadModeDelay           = 1, /**< 延时加载：时间由 delayTime 决定 */
    PluginLoadModeTrigger         = 2, /**< 触发式加载：被调用时才自动加载 */
    PluginLoadModeDepend          = 3, /**< 依赖式加载：依赖的插件加载完后再加载自己 */
    PluginLoadModeDependMaxDelay  = 4, /**< 依赖并加最大延时：如果超过一定时间，依赖项还没完成，则自动加载 */
};

#pragma mark -

@interface PluginLoadPolicy : NSObject

@property (assign, nonatomic) PluginLoadMode loadMode;
@property (assign, nonatomic) CGFloat delayTime; /**< 延时，单位秒 */
@property (strong, nonatomic) NSArray *dependTasks; /**< 依赖项，id<ITask> */

+ (id)policyWithMode:(PluginLoadMode)mode;

+ (id)policyWithDelay:(CGFloat)delay;

+ (id)policyWithDependTasks:(NSArray *)dependTasks;

+ (id)policyWithMode:(PluginLoadMode)mode delay:(CGFloat)delay depends:(NSArray *)depends;

- (BOOL)isDependTasksDone;

@end

#pragma mark -

@interface BasePlugin : NSObject<IPlugin>

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) PluginLoadPolicy *loadPolicy;
@property (assign, nonatomic) PluginLoadStatus loadStatus;
@property (assign, nonatomic) BOOL finished;

/**
 *  根据协议创建插件。identifier 使用默认的类名，加载策略为立即加载。
 *
 *  @param protocol 插件依赖的协议
 *
 *  @return 插件实例
 */
+ (id)pluginWithProtocol:(Protocol *)protocol;

/**
 *  根据协议、identifier、加载策略创建插件。
 *
 *  @param protocol   插件依赖的协议
 *  @param identifier 插件标识符
 *  @param loadPolicy 加载策略
 *
 *  @return 插件实例
 */
+ (id)pluginWithProtocol:(Protocol *)protocol identifier:(NSString *)identifier loadPolicy:(PluginLoadPolicy *)loadPolicy;

@end
