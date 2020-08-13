//
//  ServiceManager.m
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "HYServiceManager.h"
#import <pthread.h>
#import "KiwiSDKMacro.h"

@interface HYServiceManager() {
    pthread_mutex_t _lock;
}

@property(nonatomic,strong) NSMutableDictionary* serviceContextDict;
@property(nonatomic,strong) NSMutableDictionary* serviceExtraContextDict;
@property(nonatomic,strong) NSMutableDictionary* serviceDict;

@end

@implementation HYServiceManager

- (instancetype)init
{
    if (self = [super init]) {
        _serviceContextDict = [NSMutableDictionary dictionaryWithCapacity:10];
        _serviceDict = [NSMutableDictionary dictionaryWithCapacity:5];
        _serviceExtraContextDict = [NSMutableDictionary dictionaryWithCapacity:5];
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}

#pragma mark - public

- (BOOL)registerService:(Class)cls toProtocol:(Protocol *)protocol extraProtocol:(Protocol *)extraProtocol
{
    NSAssert(cls != nil, @"should not be nil");
    NSAssert(protocol != NULL, @"should not be null");
    
    if (cls && protocol != NULL) {
        NSString* protocolStr = NSStringFromProtocol(protocol);
        
        if (!protocolStr) {
            return NO;
        }
        
        if (![cls conformsToProtocol:@protocol(IWFService)]) {
            KWSLogError(@"%@ not conformsToProtocol IWFService", cls);
            NSAssert(NO, @"should conformsToProtocol IWFService");
            return NO;
        }
        
        pthread_mutex_lock(&_lock);
        _serviceContextDict[protocolStr] = cls;
        pthread_mutex_unlock(&_lock);
        
        if (extraProtocol) {
            NSString* extraProtocolStr = NSStringFromProtocol(extraProtocol);
            pthread_mutex_lock(&_lock);
            _serviceExtraContextDict[extraProtocolStr] = protocolStr;
            pthread_mutex_unlock(&_lock);
        }
        return YES;
    }
    return NO;
}

- (BOOL)unregisterService:(Protocol *)protocol
{
    if (protocol != NULL) {
        
        NSString* protocolStr = NSStringFromProtocol(protocol);
        
        if (!protocolStr) {
            return NO;
        }
        
        pthread_mutex_lock(&_lock);
        //把注册相关信息清掉
        [_serviceContextDict removeObjectForKey:protocolStr];
        
        //实例对象也清楚
        [_serviceDict removeObjectForKey:protocolStr];
        
        pthread_mutex_unlock(&_lock);
    }
    
    return NO;
}

- (BOOL)unregisterExtraProtocol:(Protocol *)protocol
{
    if (protocol != NULL) {
        
        NSString* protocolStr = NSStringFromProtocol(protocol);
        
        if (!protocolStr) {
            return NO;
        }
        
        pthread_mutex_lock(&_lock);
        
        [_serviceExtraContextDict removeObjectForKey:protocolStr];
        
        pthread_mutex_unlock(&_lock);
    }
    
    return NO;
}

- (id<IWFService>)serviceWithProtocol:(Protocol *)protoco
{
    Protocol *baseProtocol = protoco;
    NSString* baseProtocolStr = NSStringFromProtocol(baseProtocol);
    
    if (!baseProtocolStr){
        return nil;
    }
    
    pthread_mutex_lock(&_lock);
    id<IWFService> service = [self.serviceDict objectForKey:baseProtocolStr];
    pthread_mutex_unlock(&_lock);
    
    //可能是命中ExtraProtocol
    if (!service) {
        NSString* protocolStr = [self baseProtocolStrWithExtraProtocol:baseProtocol];
        if (protocolStr){
            pthread_mutex_lock(&_lock);
            service = [self.serviceDict objectForKey:baseProtocolStr];
            pthread_mutex_unlock(&_lock);
            
            baseProtocol = NSProtocolFromString(protocolStr);
            baseProtocolStr = protocolStr;
        }
    }
    
    
    //如果service不存在那么就去创建然后调用start
    if (!service) {
        
        Class cls = [self classWithProtocol:baseProtocol];
        
        if (!cls) {
            NSAssert(NO, @"missing class %@", NSStringFromProtocol(baseProtocol));
            KWSLogError(@"missing class %@", NSStringFromProtocol(baseProtocol));
            return nil;
        }
        
        BOOL shareSingleton = NO;
        
        SEL shareSel = @selector(sharedObject);
        
        if (![cls respondsToSelector:shareSel]) {
            
            shareSel = @selector(sharedInstance);
            
            if ([cls respondsToSelector:shareSel]) {
                shareSingleton = YES;
            }
        } else {
            shareSingleton = YES;
        }
        
        if (shareSingleton) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            service = [cls performSelector:shareSel];
#pragma clang diagnostic pop
        } else {
            pthread_mutex_lock(&_lock);
            service = [[cls alloc] init];
            pthread_mutex_unlock(&_lock);
        }
        
        if (service) {
            
            //如果创建出来的实例不支持对应的接口，那么强制报错出来
            if (![service conformsToProtocol:baseProtocol]) {
                NSAssert(NO , @"service not conformsToProtocol: %@", baseProtocol);
                KWSLogError(@"service not conformsToProtocol: %@", baseProtocol);
                return nil;
            }
            
            BOOL singleton = shareSingleton;
            
            if (!singleton) {
                
                //如果没实现sharedInstance，那么看其是否实现了singleton
                if([service respondsToSelector:@selector(singleton)]) {
                    singleton = [service singleton];
                }
                
            } else {
                //如果没有实现sharedInstance并且没实现singleton的话默认单例
                //只有在不实现sharedInstance且实现了singleton并返回NO才是新对象
                singleton = YES;
            }
            
            //如果是单例才存起来，否则直接返回
            if (singleton) {
                pthread_mutex_lock(&_lock);
                self.serviceDict[baseProtocolStr] = service;
                pthread_mutex_unlock(&_lock);
            }
        }
    }
    
    return service;
}

#pragma mark - private

- (Class)classWithProtocol:(Protocol *)protocol
{
    if (protocol != NULL) {
        
        NSString* protocolStr = NSStringFromProtocol(protocol);
        
        if (!protocolStr) {
            return nil;
        }
        
        pthread_mutex_lock(&_lock);
        Class cls = self.serviceContextDict[protocolStr];
        pthread_mutex_unlock(&_lock);
        return cls;
    }
    
    return nil;
}

- (NSString *)baseProtocolStrWithExtraProtocol:(Protocol *)extraProtocol
{
    if (extraProtocol != NULL) {
        
        NSString* extraProtocolStr = NSStringFromProtocol(extraProtocol);
        
        if (!extraProtocolStr) {
            return nil;
        }
        
        pthread_mutex_lock(&_lock);
        NSString* baseProtocolStr = self.serviceExtraContextDict[extraProtocolStr];
        pthread_mutex_unlock(&_lock);
        return baseProtocolStr;
    }
    
    return nil;
}

- (id)objectForKeyedSubscript:(Protocol*)key
{
    return [self serviceWithProtocol:key];
}

@end
