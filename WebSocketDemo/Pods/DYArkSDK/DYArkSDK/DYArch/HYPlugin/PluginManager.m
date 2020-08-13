//
//  PluginManager.m
//  kiwi
//
//  Created by pengfeihuang on 16/7/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "PluginManager.h"
#import "KiwiSDKMacro.h"
#import "NSTimer+YYAdd.h"

static NSString * const kPluginTaskKeyPathFinished = @"finished";

@interface PluginManager()

@property(nonatomic, strong) NSMutableArray* plugins;
@property(nonatomic, strong) NSMutableArray* waitToDependPlugins;
@property(nonatomic, strong) NSMutableArray* waitToTriggerPlugins;

@property(nonatomic, strong) NSMutableDictionary* delayPlugin2Timer;/**< 由于延时的 Plugin 需要取消，所以不能用 dispatch_after，所以每个延时的插件对应一个 Timer。*/

@end

@implementation PluginManager

- (instancetype)init
{
    if (self = [super init]) {
        _plugins = [NSMutableArray array];
        _waitToDependPlugins = [NSMutableArray array];
        _waitToTriggerPlugins = [NSMutableArray array];
        _delayPlugin2Timer = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self unmountAllPlugins];
    
    DYLogInfo(@"{Plugin} unmountAllPlugins");
}

- (void)addPlugin:(id<IPlugin>)plugin
{
    KWSLogInfo(@"{Plugin} addPlugin %@: %@", plugin, plugin.identifier);
    
    if (!plugin) {
        return;
    }
    
    if (![self.plugins containsObject:plugin]) {
        if (!plugin.loadPolicy) {
            [self doAddPlugin:plugin];
        } else {
            [self delayAddPlugin:plugin];
        }
    }
}

- (void)removePlugin:(id<IPlugin>)plugin
{
    if (plugin) {
        if (plugin.loadStatus == PluginLoadStatusDidMount) {
            KWSLogInfo(@"{Plugin} removePlugin %@: %@", plugin, plugin.identifier);
            if ([plugin respondsToSelector:@selector(pluginWillUnmount)]) {
                KWSLogInfo(@"{Plugin} %@ pluginWillUnmount", plugin);
                [plugin pluginWillUnmount];
            }
            
            [self.plugins removeObject:plugin];
            
            plugin.loadStatus = PluginLoadStatusDidUnmount;
            
            if ([plugin respondsToSelector:@selector(pluginDidUnmount)]) {
                KWSLogInfo(@"{Plugin} %@ pluginDidUnmount", plugin);
                [plugin pluginDidUnmount];
            }
        } else if (plugin.loadStatus == PluginLoadStatusWaiting) {
            KWSLogInfo(@"{Plugin} cancelPlugin %@: %@", plugin, plugin.identifier);
            
            plugin.loadStatus = PluginLoadStatusCanceled;
            
            [self.waitToDependPlugins removeObject:plugin];
            [self.waitToTriggerPlugins removeObject:plugin];
            
            [self removeDelayTimerForPlugin:plugin];
        }
    }
}

- (void)unmountAllPlugins
{
    KWSLogInfo(@"{Plugin} unmountAllPlugins");
    
    for (NSInteger i = self.plugins.count - 1; i >= 0; i--) {
        
        id<IPlugin> plugin = [self.plugins objectAtIndex:i];
        
        if ([plugin respondsToSelector:@selector(pluginWillUnmount)]) {
            KWSLogInfo(@"{Plugin} %@ pluginWillUnmount", plugin);
            [plugin pluginWillUnmount];
        }
        
        [self.plugins removeObjectAtIndex:i];
        
        if ([plugin respondsToSelector:@selector(pluginDidUnmount)]) {
            KWSLogInfo(@"{Plugin} %@ pluginDidUnmount", plugin);
            [plugin pluginDidUnmount];
        }
    }
    
    for (id<IPlugin> plugin in self.waitToDependPlugins) {
        [self removeObserverOfPlugin:plugin];
    }
    
    [self.waitToDependPlugins removeAllObjects];
    [self.waitToTriggerPlugins removeAllObjects];
    
    for (NSString *key in self.delayPlugin2Timer) {
        NSTimer *timer = self.delayPlugin2Timer[key];
        [timer invalidate];
        KWSLogInfo(@"{Plugin} invalidate Timer for Plugin:%@", key);
    }
    [self.delayPlugin2Timer removeAllObjects];
}

- (NSArray*)currentPlugins
{
    return [self.plugins copy];
}

- (BOOL)checkAllPluginsHasSubView
{
    for (id<IPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(pluginHasSubview)]) {
            if([plugin pluginHasSubview]) {
                return YES;
            }
        }
    }
    return NO;
}

- (id<IPlugin>)installedPlugin:(NSString *)identifier protocol:(Protocol *)aProtocol
{
    id<IPlugin> plugin = [self pluginWithIdentifyier:identifier inPlugins:self.plugins];
    
    if (plugin && [plugin conformsToProtocol:aProtocol]) {
        return plugin;
    }
    
    plugin = [self pluginWithIdentifyier:identifier inPlugins:self.waitToTriggerPlugins];
    
    if (plugin && [plugin conformsToProtocol:aProtocol]) {
        [self.waitToTriggerPlugins removeObject:plugin];
        [self doAddPlugin:plugin];
        return plugin;
    }
    
    return nil;
}

#pragma mark - Private

- (id<IPlugin>)pluginWithIdentifyier:(NSString *)identifier inPlugins:(NSArray *)plugins
{
    for (id<IPlugin> plugin in plugins) {
        if ([plugin.identifier isEqualToString:identifier]) {
            return plugin;
        }
    }
    return nil;
}

- (id<IPlugin>)pluginWithDependTask:(id<ITask>)task inPlugins:(NSArray *)plugins
{
    for (id<IPlugin> plugin in plugins) {
        if ([plugin.loadPolicy.dependTasks containsObject:task]) {
            return plugin;
        }
    }
    return nil;
}

- (void)doAddPlugin:(id<IPlugin>)plugin
{
    if ([self.plugins containsObject:plugin]) {
        KWSLogInfo(@"{Plugin} aleady exists plugin %@: %@", plugin, plugin.identifier);
        return;
    }
    KWSLogInfo(@"{Plugin} doAddPlugin %@: %@", plugin, plugin.identifier);
    if ([plugin respondsToSelector:@selector(pluginWillMount)]) {
        KWSLogInfo(@"{Plugin} %@ pluginWillMount", plugin);
        [plugin pluginWillMount];
    }
    
    [self.plugins safeAddObject:plugin];
    
    if ([plugin respondsToSelector:@selector(pluginDidMount)]) {
        KWSLogInfo(@"{Plugin} %@ pluginDidMount", plugin);
        [plugin pluginDidMount];
    }
    plugin.loadStatus = PluginLoadStatusDidMount;
}

- (void)delayAddPlugin:(id<IPlugin>)plugin
{
    if (!plugin) {
        return;
    }
    KWSLogInfo(@"{Plugin} delayAddPlugin %@: %@", plugin, plugin.identifier);
    plugin.loadStatus = PluginLoadStatusWaiting;
    switch (plugin.loadPolicy.loadMode) {
        case PluginLoadModeDelay: {
            if (plugin.loadPolicy.delayTime > 0) {
                [self addDelayTimerForPlugin:plugin];
            } else {
                [self doAddPlugin:plugin];
            }
            break;
        }
        case PluginLoadModeTrigger: {
            [self.waitToTriggerPlugins safeAddObject:plugin];
            break;
        }
        case PluginLoadModeDepend: {
            [self handleDependsTaskPlugin:plugin];
            break;
        }
        case PluginLoadModeDependMaxDelay: {
            [self handleDependsTaskPlugin:plugin];
            if (plugin.loadPolicy.delayTime > 0) {
                [self addDelayTimerForPlugin:plugin];
            }
            break;
        }
        default:
            break;
    }
}

- (void)addDelayTimerForPlugin:(id<IPlugin>)plugin
{
    [self removeDelayTimerForPlugin:plugin];
    
    BlockWeakSelf(weakSelf, self);
    
    NSTimer *timer = [NSTimer yy_scheduledTimerWithTimeInterval:plugin.loadPolicy.delayTime block:^(NSTimer * _Nonnull timer) {
        [weakSelf handleTimeoutWithDelayPlugin:plugin];
    } repeats:NO];
    
    [self.delayPlugin2Timer safeSetObject:timer forKey:plugin.identifier];
    
    KWSLogInfo(@"{Plugin} addDelayTimerForPlugin %@: %@", plugin, plugin.identifier);
}

- (void)removeDelayTimerForPlugin:(id<IPlugin>)plugin
{
    NSString *key = plugin.identifier;
    NSTimer *timer = self.delayPlugin2Timer[key];
    if (timer) {
        [timer invalidate];
        [self.delayPlugin2Timer removeObjectForKey:key];
        
        KWSLogInfo(@"{Plugin} removeDelayTimerForPlugin %@: %@", plugin, plugin.identifier);
    }
}

- (void)handleDependsTaskPlugin:(id<IPlugin>)plugin
{
    [self.waitToDependPlugins addObject:plugin];
    for (id<ITask> task in plugin.loadPolicy.dependTasks) {
        [(id)task addObserver:self forKeyPath:kPluginTaskKeyPathFinished options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)handleTimeoutWithDelayPlugin:(id<IPlugin>)plugin
{
    [self removeDelayTimerForPlugin:plugin];
    
    if ([self.waitToDependPlugins containsObject:plugin]) {
        KWSLogInfo(@"{Plugin} handleTimeoutWithDependsTaskPlugin %@: %@", plugin, plugin.identifier);
        [self removeObserverOfPlugin:plugin];
        [self addDependPlugin:plugin];
    } else {
        KWSLogInfo(@"{Plugin} handleTimeoutWithDelayPlugin %@: %@", plugin, plugin.identifier);
        [self doAddPlugin:plugin];
    }
}

- (void)removeObserverOfPlugin:(id<IPlugin>)plugin
{
    for (id<ITask> task in plugin.loadPolicy.dependTasks) {
        [(id)task removeObserver:self forKeyPath:kPluginTaskKeyPathFinished];
    }
}

- (void)addDependPlugin:(id<IPlugin>)plugin
{
    KWSLogInfo(@"{Plugin} addDependPlugin %@: %@", plugin, plugin.identifier);
    [self.waitToDependPlugins removeObject:plugin];
    [self removeDelayTimerForPlugin:plugin];
    //这里不应该置空，否则重进直播间就找不到依赖的插件了
    //plugin.loadPolicy.dependTasks = nil;
    [self doAddPlugin:plugin];
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    KWSLogInfo(@"{Plugin} observeValueForKeyPath: %@, newValue: %@", keyPath, [change objectForKey:NSKeyValueChangeNewKey]);
    if (object && [keyPath isEqualToString:kPluginTaskKeyPathFinished]) {
        NSNumber *finished = [change objectForKey:NSKeyValueChangeNewKey];
        BOOL finishedValue = [finished boolValue];
        if (!finishedValue) {
            return;
        }
        [object removeObserver:self forKeyPath:kPluginTaskKeyPathFinished];
        
        id<IPlugin> plugin = [self pluginWithDependTask:object inPlugins:self.waitToDependPlugins];
        KWSLogInfo(@"{Plugin} plugin: %@ dependsTask: %@ finished", plugin.identifier, object);
        
        if (plugin && [plugin.loadPolicy isDependTasksDone]) {
            [self addDependPlugin:plugin];
        }
    }
}

@end
