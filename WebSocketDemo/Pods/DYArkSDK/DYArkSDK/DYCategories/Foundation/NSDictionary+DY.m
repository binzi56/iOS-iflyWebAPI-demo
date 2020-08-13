//
//  NSDictionary+DY.m
//  DYArkSDK
//
//  Created by EasyinWan on 2019/1/9.
//

#import "NSDictionary+DY.h"
#import <objc/runtime.h>
#import "NSObject+YYAdd.h"
#import "HYLogMacros.h"
#import "KiwiSDKMacro.h"

#ifdef DEBUG
#define DY_invalidSafeDictionaryWithKey(KEY)                                                        \
(                                                                                                   \
    (!(KEY)) ?                                                                                      \
    ({                                                                                              \
        NSAssert(NO,                                                                                \
            @"NSDictionary assert => invalid obj %s:%d name:%@ class:%@ val:%@",                    \
            __PRETTY_FUNCTION__,                                                                    \
            __LINE__,                                                                               \
            @""#KEY,                                                                                \
            NSStringFromClass([(KEY) class]),                                                       \
            (KEY));                                                                                 \
            YES;                                                                                    \
    })                                                                                              \
    :                                                                                               \
    NO                                                                                              \
)
#else
#define DY_invalidSafeDictionaryWithKey(KEY)                                                        \
(                                                                                                   \
    (!(KEY)) ?                                                                                      \
    ({                                                                                              \
        DYLogError(@"NSDictionary error => invalid obj %s:%d name:%@ class:%@ val:%@\n %@",         \
            __PRETTY_FUNCTION__,                                                                    \
            __LINE__,                                                                               \
            @""#KEY,                                                                                \
            NSStringFromClass([(KEY) class]),                                                       \
            (KEY),                                                                                  \
            [NSThread callStackSymbols]);                                                           \
            YES;                                                                                    \
    })                                                                                              \
    :                                                                                               \
    NO                                                                                              \
)
#endif

@implementation NSDictionary (DY)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(initWithObjects:forKeys:count:) with:@selector(safe_initWithObjects:forKeys:count:)];
        [self swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:) with:@selector(safe_dictionaryWithObjects:forKeys:count:)];
        [self swizzleClassMethod:@selector(dictionaryWithObject:forKey:) with:@selector(safe_dictionaryWithObject:forKey:)];
        //[self swizzleClassMethod:@selector(dictionaryWithObjectsAndKeys:) with:@selector(safe_dictionaryWithObjectsAndKeys:)];
        [self swizzleClassMethod:@selector(dictionaryWithDictionary:) with:@selector(safe_dictionaryWithDictionary:)];
        //objects & keys can be nil
        //[self swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:) with:@selector(safe_dictionaryWithObjects:forKeys:)];
    });
}

- (BOOL)hasKey:(NSString *)key
{
    if (DY_invalidSafeDictionaryWithKey(key)) return NO;
    id val = [self objectForKey:key];
    return val?YES:NO;
}

- (instancetype)safe_initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger count = [self.class objects:objects keys:keys count:cnt safeObjects:safeObjects safeKeys:safeKeys];
    return [self safe_initWithObjects:safeObjects forKeys:safeKeys count:count];
}

+ (instancetype)safe_dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger count = [self objects:objects keys:keys count:cnt safeObjects:safeObjects safeKeys:safeKeys];
    return [self safe_dictionaryWithObjects:safeObjects forKeys:safeKeys count:count];
}

+ (NSUInteger)objects:(const id [])objects keys:(const id <NSCopying> [])keys count:(NSUInteger)cnt safeObjects:(__strong id *)safeObjects safeKeys:(__strong id *)safeKeys
{
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt && j < cnt; ++i) {
        id key = keys[i];
        id obj = objects[i];
        if (DY_invalidSafeDictionaryWithKey(key) ||
            DY_invalidSafeDictionaryWithKey(obj)) {
            continue;
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        ++j;
    }
    return j;
}

+ (instancetype)safe_dictionaryWithObject:(id)obj forKey:(id)key
{
    if (DY_invalidSafeDictionaryWithKey(key) ||
        DY_invalidSafeDictionaryWithKey(obj)) {
        return [self dictionary];
    }
    return [self safe_dictionaryWithObject:obj forKey:key];
}

//+ (instancetype)safe_dictionaryWithObjectsAndKeys:(id)firstObject, ...
//{
//    if (!firstObject) {
//        return [self dictionary];
//    }
//
//    SEL sel = @selector(safe_dictionaryWithObjectsAndKeys:);
//    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
//    if (!sig) { [self doesNotRecognizeSelector:sel]; return nil; }
//    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
//    if (!inv) { [self doesNotRecognizeSelector:sel]; return nil; }
//    [inv setTarget:self];
//    [inv setSelector:sel];
//
//    DYLogInfo(@"%s %@", __func__, [NSThread callStackSymbols]);
//    DYLogInfo(@"self:%@ sig.numberOfArguments:%ld", self, sig.numberOfArguments);
//
//    NSUInteger numberOfArguments = sig.numberOfArguments;
//    if (numberOfArguments & 1) {
//        numberOfArguments -= 1;
//    }
//    if (numberOfArguments > 2) {
//        va_list args;
//        va_start(args, firstObject);
//        id param;
//        id obj = firstObject;
//        for (NSUInteger i = 2; (param = va_arg(args, id)); ++i) {
//            //        [inv setArgument:&firstObject atIndex:2];
//            //        [inv setArgument:&param atIndex:i];
//            if (i & 1) {
//                [inv setArgument:&obj atIndex:i - 1];   //obj
//                [inv setArgument:&param atIndex:i];     //key
//                obj = nil;
//                continue;
//            }
//            obj = param;
//        }
//        va_end(args);
//    }
//
//    [inv invoke];
//
//    if ([sig methodReturnLength] > 0) {
//        NSDictionary *returnValue;
//        [inv getReturnValue:&returnValue];
//        return returnValue;
//    }
//    return nil;
//}

+ (instancetype)safe_dictionaryWithDictionary:(NSDictionary<id, id> *)dict
{
    //dict is nullable
    if (!dict) {
        return [self dictionary];
    }
    if (DYCheckInvalidAndKindOfClass(dict, NSDictionary)) {
        return [self dictionary];
    }
    return [self safe_dictionaryWithDictionary:dict];
}

@end


@implementation NSMutableDictionary (DY)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSDictionaryM");
        [class swizzleInstanceMethod:@selector(setObject:forKey:) with:@selector(safe_setObject:forKey:)];
        [class swizzleInstanceMethod:@selector(setObject:forKeyedSubscript:) with:@selector(safe_setObject:forKeyedSubscript:)];
        [class swizzleInstanceMethod:@selector(removeObjectForKey:) with:@selector(safe_removeObjectForKey:)];
        
    });
}

- (void)safe_setObject:(id)obj forKey:(id)key {
    if (DY_invalidSafeDictionaryWithKey(obj) ||
        DY_invalidSafeDictionaryWithKey(key)) {
        return;
    }
    [self safe_setObject:obj forKey:key];
}

- (void)safe_setObject:(id)obj forKeyedSubscript:(id)key {
    //obj can be nil.
    //for instance => abc[@"d"] = nil;
    if (DY_invalidSafeDictionaryWithKey(key)) {
        return;
    }
    [self safe_setObject:obj forKeyedSubscript:key];
}

- (void)safe_removeObjectForKey:(id)key
{
    if (DY_invalidSafeDictionaryWithKey(key)) {
        return;
    }
    [self safe_removeObjectForKey:key];
}

#pragma mark - others
//- (void)testCase
//{
//    NSString *emptyKey = nil;
//    NSString *emptyObj = nil;
//    //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", emptyObj, emptyKey, @"2", @"3", @"3", nil];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"3", nil];
//    //DYLogInfo(@"dict:%@", dict);
//    //NSDictionary *dict = [NSDictionary dictionaryWithObject:emptyObj forKey:emptyKey];
//    //NSDictionary *dict = @{@"key" : emptyObj, emptyKey : @"val", @"3" : @"3"};
//    //NSDictionary *dict = [NSDictionary dictionaryWithObject:@"val" forKey:nil];
//    //NSDictionary *dict = [NSDictionary dictionaryWithDictionary:nil];
//    //NSDictionary *dict = [NSDictionary dictionaryWithObjects:nil forKeys:nil];
//    //[dict setObject:nil forKey:nil];
//    
//    //NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
//    //[mutableDict removeObjectForKey:nil];
//    //[mutableDict removeObjectsForKeys:nil];
//    //[mutableDict setDictionary:nil];
//    
//    //    - (instancetype)initWithDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
//    //    - (instancetype)initWithDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary copyItems:(BOOL)flag;
//    //    - (instancetype)initWithObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType <NSCopying>> *)keys;
//    
//    //dict[emptyKey] = nil;
//    
//    //    Class class = NSClassFromString(@"DYTestModel");
//    //    SEL sel = @selector(modelWithType:tag:title:);
//    //    NSMethodSignature *sig = [class methodSignatureForSelector:sel];
//    //    if (!sig) { [class doesNotRecognizeSelector:sel]; return nil; }
//    //    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
//    //    if (!inv) { [class doesNotRecognizeSelector:sel]; return nil; }
//    //    [inv setTarget:self];
//    //    [inv setSelector:sel];
//    
//    //    + (instancetype)modelWithType:(DYTestModelType)type
//    //tag:(NSUInteger)tag
//    //title:(NSString *)title;
//    
//    //[inv setArgument:&firstObject atIndex:2];
//}

@end
