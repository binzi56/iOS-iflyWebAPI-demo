//
//  DYMediator.m
//  kiwi
//
//  Created by lslin on 16/9/12.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "DYMediator.h"

#import <objc/runtime.h>
#import "HYLogMacros.h"

#ifdef HY_MEDIATOR_NOT_ASSERT

#define DYMediatorAssert(condition, desc, ...) KWSLogInfo(desc, ##__VA_ARGS__)

#else

#define DYMediatorAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)

#endif

#pragma mark - DYMediator

@implementation DYMediator
{
    NSMutableDictionary *_cachedTarget;
}

#pragma mark - Class

+ (instancetype)sharedObject
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cachedTarget = [NSMutableDictionary new];
    }
    return self;
}

/*
 scheme://[target]/[action]?[params]
 
 url sample:
 kiwi://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = url.scheme;
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] != 2) {
            continue;
        }
        NSString *value = [elts lastObject];
        value = [value stringByRemovingPercentEncoding]; //base64解码，scheme参数应该统一做一次base64编码，防止参数里带特殊符号，如果参数本身是url，应该做2次base64编码，action里面再做一次base64解码
        [params setObject:value forKey:[elts firstObject]];
    }
    
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    id result = [self performAction:actionName forTarget:url.host params:params isCacheTarget:NO];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performSelector:(NSString*)selectorName forClass:(NSString *)className {
    Class cls = NSClassFromString(className);
    if (!cls) {
        DYMediatorAssert(0, @"class:%@ not exist", className);
        return nil;
    }
    
    SEL sel = NSSelectorFromString(selectorName);
    if (![cls respondsToSelector:sel]) {
        DYMediatorAssert(0, @"class:%@ selector:%@ not exist",className, selectorName);
        return nil;
    }
    
    NSMethodSignature* methodSig = [cls methodSignatureForSelector:sel];
    if(methodSig == nil || [methodSig numberOfArguments] != 2) {
        DYMediatorAssert(0, @"class:%@ selector:%@ arguments invalid", className, selectorName);
        return nil;
    }
    
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(id)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [cls performSelector:sel];
#pragma clang diagnostic pop
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setSelector:sel];
    [invocation setTarget:cls];
    [invocation invoke];
    
    return [self returnValueForInvocation:invocation methodSignature:methodSig];
}

- (id)performAction:(NSString *)action forTarget:(NSString *)target params:(NSDictionary *)params isCacheTarget:(BOOL)isCacheTarget {
    
    NSString *actionName = [NSString stringWithFormat:@"HYAction_%@:", action];
    NSString *targetName = [NSString stringWithFormat:@"HYTarget_%@", target];
    return [self doPerformAction:actionName forTarget:targetName params:params isCacheTarget:isCacheTarget];
}

- (id)performNativeAction:(NSString *)action forTarget:(NSString *)target params:(NSDictionary *)params isCacheTarget:(BOOL)isCacheTarget {
    NSString *actionName = [NSString stringWithFormat:@"HYNativeAction_%@:", action];
    NSString *targetName = [NSString stringWithFormat:@"HYTarget_%@", target];
    return [self doPerformAction:actionName forTarget:targetName params:params isCacheTarget:isCacheTarget];
}

- (void)releaseCacheTarget:(NSString *)target {
    NSString *targetName = [NSString stringWithFormat:@"HYTarget_%@", target];
    @synchronized(self) {
        [_cachedTarget removeObjectForKey:targetName];
    }
}

#pragma mark private
- (id)doPerformAction:(NSString *)action forTarget:(NSString *)target params:(NSDictionary *)params isCacheTarget:(BOOL)isCacheTarget {
    Class targetCls = NSClassFromString(target);
    if (!targetCls) {
        DYMediatorAssert(0, @"target:%@ not exist", target);
        KWSLogInfo(@"[DYMediator] target:%@ invalid", target);
        return nil;
    }
    
    NSObject *targetObj = nil;
    if (isCacheTarget) {
        targetObj = [self cachedTargetWithName:target];
    } else {
        targetObj = [[targetCls alloc] init];
    }
    SEL sel = NSSelectorFromString(action);
    return [self safePerformAction:sel target:targetObj params:params];
}
- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    if (![target respondsToSelector:action]) {
        DYMediatorAssert(0, @"target:%@ action:%@ not exist", target, action);
        KWSLogInfo(@"[DYMediator] target:%@ action:%@ invalid", target, action);
        return nil;
    }
    
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        DYMediatorAssert(0, @"target:%@ action:%@ method signature invalid", target, action);
        return nil;
    }
    
    if ([methodSig numberOfArguments] != 3 || strcmp([methodSig getArgumentTypeAtIndex:2], @encode(id)) != 0) {
        DYMediatorAssert(0, @"target:%@ action:%@ argument invalid", target, action);
        KWSLogInfo(@"[DYMediator] target:%@ action:%@ arguments:%@ invalid", target, action, methodSig);
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(id)) == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setArgument:&params atIndex:2];
    [invocation setSelector:action];
    [invocation setTarget:target];
    [invocation invoke];
    
    return [self returnValueForInvocation:invocation methodSignature:methodSig];
}

- (id)returnValueForInvocation:(NSInvocation *)invocation methodSignature:(NSMethodSignature*)methodSignature {
    const char* retType = [methodSignature methodReturnType];
    if (strcmp(retType, @encode(void)) == 0) {
        return nil;
    }
    
    NSArray *interType = @[@"c",@"i", @"s", @"l", @"q", @"C", @"I", @"S", @"L",@"Q",@"B",@"f",@"d"];
    if ([interType containsObject:[NSString stringWithUTF8String:retType]]) {
        switch (retType[0]) {
#define HYF_RET_ARG_CASE(_typeString, _type) \
case _typeString: {                              \
_type result = 0;\
[invocation getReturnValue:&result];\
return @(result);\
}
                HYF_RET_ARG_CASE('c', char)
                HYF_RET_ARG_CASE('C', unsigned char)
                HYF_RET_ARG_CASE('s', short)
                HYF_RET_ARG_CASE('S', unsigned short)
                HYF_RET_ARG_CASE('i', int)
                HYF_RET_ARG_CASE('I', unsigned int)
                HYF_RET_ARG_CASE('l', long)
                HYF_RET_ARG_CASE('L', unsigned long)
                HYF_RET_ARG_CASE('q', long long)
                HYF_RET_ARG_CASE('Q', unsigned long long)
                HYF_RET_ARG_CASE('f', float)
                HYF_RET_ARG_CASE('d', double)
                HYF_RET_ARG_CASE('B', BOOL)
                
        }
    }
    
    if ([[NSString stringWithUTF8String:retType] hasPrefix:@"^"]) {
        void *result = NULL;
        [invocation getReturnValue:&result];
        return @((long)result);
    }
    
    if (strcmp(retType, @encode(SEL)) == 0) {
        SEL result;
        [invocation getReturnValue:&result];
        return NSStringFromSelector(result);
    }
    
    
    if (strcmp(retType, @encode(char *)) == 0) {
        char * result = NULL;
        [invocation getReturnValue:&result];
        return @((long)result);
    }
    
    if (strcmp(retType, @encode(CGSize)) == 0) {
        CGSize result;
        [invocation getReturnValue:&result];
        return [NSValue valueWithCGSize:result];
    }
    
    return nil;
}

- (NSObject*)cachedTargetWithName:(NSString*)targetName {
    @synchronized(self) {
        NSObject *obj = [_cachedTarget objectForKey:targetName];
        if (!obj) {
            Class targetCls = NSClassFromString(targetName);
            obj = [[targetCls alloc] init];
            [_cachedTarget setObject:obj forKey:targetName];
        }
        return obj;
    }
}

#pragma mark - key & value

+ (NSString *)wildcardKeyWithPropertyName:(NSString *)name inClass:(Class)clz
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(clz, &count);
    @onWFExit {
        free(properties);
    };
    
    for (int i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
        if([name isEqualToString:[propertyName lowercaseString]])
            return propertyName;
    }
    return nil;
}

+ (BOOL)isValidWithPropertyName:(NSString *)name value:(id)value inClass:(Class)clz
{
    objc_property_t property = class_getProperty(clz, [name UTF8String]);
    if (property == NULL) {
        return NO;
    }
    
    unsigned int attrCount = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);// "Ti,N,V_propertyName"
    @onWFExit {
        free(attrs);
    };
    if (attrCount == 0) {
        return NO;
    }
    
    for (int i = 0; i < attrCount; ++ i) {
        switch (attrs[i].name[0]) {
            case 'T':
            {
                NSString *propertyType = [NSString stringWithUTF8String:attrs[i].value];
                return [self isValidWithPropertyType:propertyType value:value];
                break;
            }
            default:
                break;
        }
    }
    return NO;
}

+ (BOOL)isValidWithPropertyType:(NSString *)propertyType value:(id)value
{
    // 如果是字符串，会传进 \"NSString"，需要转换为 NSString
    if ([propertyType hasPrefix:@"@"]) {
        NSString *typeName = [propertyType substringFromIndex:1];
        typeName = [typeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if ([value isKindOfClass:NSClassFromString(typeName)]) {
            return YES;
        } else if ([typeName hasPrefix:@"?"]) {
            // Block
            if ([NSStringFromClass([value class]) hasSuffix:@"Block"]) {
                return YES;
            }
            
        } else if ([typeName hasPrefix:@"<"] && [typeName hasSuffix:@">"]) {
            //Protocol
            typeName = [typeName stringByReplacingOccurrencesOfString:@"<" withString:@""];
            typeName = [typeName stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            Protocol *protocol = NSProtocolFromString(typeName);
            
            if (protocol && [value conformsToProtocol:protocol]) {
                return YES;
            }
        }
        DYLogError(@"propertyType: %@, typeName: %@, but valueClass: %@", propertyType, typeName, NSStringFromClass([value class]));
    } else {
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        if ([value isKindOfClass:[NSNumber class]]) {
            static NSArray *numberTypes = nil;
            if (!numberTypes) {
                numberTypes = @[@"c", @"i", @"s", @"l", @"l", @"q", @"C", @"I", @"S", @"L", @"Q", @"f", @"d", @"B"];
            }
            
            if ([numberTypes containsObject:propertyType]) {
                return YES;
            }
        }
        
        const char *valueType = [value respondsToSelector:@selector(objCType)] ? [value objCType] : [NSStringFromClass([value class]) UTF8String];
        if ([[NSString stringWithUTF8String:valueType] isEqualToString:propertyType]) {
            return YES;
        }
        
        DYLogError(@"propertyType: %@ valueType: %@", propertyType, [NSString stringWithUTF8String:valueType]);
    }
    return NO;
}

+ (void)performTarget:(id)target
                class:(Class)clazz
             kvcDicts:(NSDictionary *)kvcDicts
{
    for (NSString *key in kvcDicts.allKeys) {
        
        id value = kvcDicts[key];
        
        if ([self isValidWithPropertyName:key
                                    value:value
                                  inClass:clazz]) {
            
            [target setValue:value forKey:key];
            
        } else {
            NSString *wildcardKey = [self wildcardKeyWithPropertyName:key inClass:clazz];
            if (wildcardKey.length && [self isValidWithPropertyName:wildcardKey
                                                              value:value
                                                            inClass:clazz]) {
                
                [target setValue:value forKey:wildcardKey];
                
            } else {
                DYLogError(@"%@", [NSString stringWithFormat:@"failed to setValue: %@ forKey: %@", value, key]);
            }
        }
    }
}

@end
