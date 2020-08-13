#import "NSMutableDictionary+KWS.h"

@implementation NSMutableDictionary (KWSSafe)

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (anObject != nil && aKey != nil) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
