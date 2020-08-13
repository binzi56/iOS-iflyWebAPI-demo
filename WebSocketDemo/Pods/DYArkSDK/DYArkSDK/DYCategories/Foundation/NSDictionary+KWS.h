#import <Foundation/Foundation.h>

@interface NSDictionary (KWSSafe)

- (NSNumber *)safeNumberForKey:(NSString *)key;
- (NSNumber *)safeNumberOrNilForKey:(NSString *)key;

- (NSString *)safeStringForKey:(NSString *)key;
- (NSString *)safeStringOrNilForKey:(NSString *)key;

- (NSArray *)safeArrayForKey:(NSString *)key;
- (NSDictionary *)safeDictionaryForKey:(NSString *)key;

@end
