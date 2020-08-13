#import <Foundation/Foundation.h>

@interface NSMutableArray (KWSSafe)

- (void)safeAddObject:(id)obj;
- (void)safeRemoveFirstObject;
- (void)safeRemoveObjectAtIndex:(NSUInteger)index;
- (void)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end
