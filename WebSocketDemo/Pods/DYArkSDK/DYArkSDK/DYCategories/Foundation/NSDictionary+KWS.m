#import "NSDictionary+KWS.h"
#import "NSString+KWS.h"

@implementation NSDictionary (KWSSafe)

- (NSNumber *)safeNumberForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)object;
        if ([NSString isNumberString:str]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            return [f numberFromString:str];
        }
    }
    
    if (![object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSNull class]]) {
        return @(0);
    }
    return object;
}

- (NSNumber *)safeNumberOrNilForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)object;
        if ([NSString isNumberString:str]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            return [f numberFromString:str];
        }
    }
    
    if (![object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

- (NSString *)safeStringForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if (![object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return object;
}

- (NSString *)safeStringOrNilForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if (![object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

- (NSArray *)safeArrayForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if (![object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

- (NSDictionary *)safeDictionaryForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if (![object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

@end
