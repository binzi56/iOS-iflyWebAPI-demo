//
//  PluginTypes.m
//  kiwi
//
//  Created by pengfeihuang on 16/7/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "PluginTypes.h"

@implementation PluginLoadPolicy

+ (id)policyWithMode:(PluginLoadMode)mode
{
    return [self policyWithMode:mode delay:0 depends:nil];
}

+ (id)policyWithDelay:(CGFloat)delay
{
    return [self policyWithMode:PluginLoadModeDelay delay:delay depends:nil];
}

+ (id)policyWithDependTasks:(NSArray *)dependTasks
{
    return [self policyWithMode:PluginLoadModeDepend delay:0 depends:dependTasks];
}

+ (id)policyWithMode:(PluginLoadMode)mode delay:(CGFloat)delay depends:(NSArray *)depends
{
    PluginLoadPolicy *policy = [[PluginLoadPolicy alloc] init];
    policy.loadMode = mode;
    policy.delayTime = delay;
    policy.dependTasks = depends;
    return policy;
}

- (BOOL)isDependTasksDone
{
    for (id<ITask> task in self.dependTasks) {
        if (!task.finished) {
            return NO;
        }
    }
    return YES;
}

@end

#pragma mark -

@interface BasePlugin()

@property (strong, nonatomic) EventCenter* eventCenter;

@end

@implementation BasePlugin

+ (id)pluginWithProtocol:(Protocol *)protocol
{
    return [self pluginWithProtocol:protocol identifier:nil loadPolicy:nil];
}

+ (id)pluginWithProtocol:(Protocol *)protocol identifier:(NSString *)identifier loadPolicy:(PluginLoadPolicy *)loadPolicy
{
    id plugin = [[[self class] alloc] init];
    
    if (protocol && ![plugin conformsToProtocol:protocol]) {
        return nil;
    }
    
    BasePlugin *wrapperPlugin = plugin;
    if (identifier) {
        wrapperPlugin.identifier = identifier;
    }
    if (loadPolicy) {
        wrapperPlugin.loadPolicy = loadPolicy;
    }
    
    return wrapperPlugin;
}

- (instancetype)init
{
    if (self = [super init]) {
        _eventCenter = [[EventCenter alloc] init];
    }
    return self;
}

- (NSString*)identifier
{
    return _identifier == nil ? NSStringFromClass([self class]) : _identifier;
}

- (void)registerEvent:(NSString*)event object:(id)object callback:(EventTriggerBlock)callback
{
    [self.eventCenter registerEvent:event object:object callback:callback];
}

- (void)unRegisterEventWithObject:(id)object
{
    [self.eventCenter unRegisterEventWithObject:object];
}

- (void)dispatchEvent:(NSString*)event userInfo:(NSDictionary*)userInfo
{
    [self.eventCenter dispatchEvent:event userInfo:userInfo];
}

@end
