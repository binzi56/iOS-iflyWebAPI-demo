#import <Foundation/Foundation.h>

@interface NSMutableDictionary (KWSSafe)

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey;

@end
