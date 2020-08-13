//
//  NSMutableArray+DY.m
//  DYArkSDK
//
//  Created by Admin on 2019/1/16.
//

#import "NSMutableArray+DY.h"
#import <objc/runtime.h>
#import "NSObject+YYAdd.h"
#import "KiwiSDKMacro.h"

#ifdef DEBUG
    #define DY_ArrayAssert(IDX, COUNT)                                                                          \
    {                                                                                                           \
        NSAssert(NO,                                                                                            \
                @"NSMutableArray assert => index out of range %s:%d index {%lu} beyond bounds [0...%lu]",       \
                __PRETTY_FUNCTION__,                                                                            \
                __LINE__,                                                                                       \
                (unsigned long)(IDX),                                                                           \
                MAX((unsigned long)(COUNT) - 1, 0));                                                            \
    }
#else
    #define DY_ArrayAssert(IDX, COUNT)                                                                          \
    {                                                                                                           \
        DYLogError(@"NSMutableArray error => index out of range %s:%d index {%lu} beyond bounds [0...%lu]",     \
                __PRETTY_FUNCTION__,                                                                            \
                __LINE__,                                                                                       \
                (unsigned long)(IDX),                                                                           \
                MAX((unsigned long)(COUNT) - 1, 0));                                                            \
    }
#endif

#ifdef DEBUG
    #define DY_invalidSafeArrayWithObj(OBJ)                                                             \
    (                                                                                                   \
        (!(OBJ)) ?                                                                                      \
        ({                                                                                              \
            NSAssert(NO,                                                                                \
                @"NSMutableArray assert => invalid obj %s:%d name:%@ class:%@ val:%@",                  \
                __PRETTY_FUNCTION__,                                                                    \
                __LINE__,                                                                               \
                @""#OBJ,                                                                                \
                NSStringFromClass([(OBJ) class]),                                                       \
                (OBJ));                                                                                 \
                YES;                                                                                    \
        })                                                                                              \
        :                                                                                               \
        NO                                                                                              \
    )
#else
    #define DY_invalidSafeArrayWithObj(OBJ)                                                             \
    (                                                                                                   \
        (!(OBJ)) ?                                                                                      \
        ({                                                                                              \
            DYLogError(@"NSMutableArray error => invalid obj %s:%d name:%@ class:%@ val:%@\n %@",       \
                __PRETTY_FUNCTION__,                                                                    \
                __LINE__,                                                                               \
                @""#OBJ,                                                                                \
                NSStringFromClass([(OBJ) class]),                                                       \
                (OBJ),                                                                                  \
                [NSThread callStackSymbols]);                                                           \
                YES;                                                                                    \
        })                                                                                              \
        :                                                                                               \
        NO                                                                                              \
    )
#endif

#ifdef DEBUG
    #define CheckIsIndexOutOfRange(IDX)                                                                         \
    (                                                                                                           \
        (self.count <= (IDX)) ?                                                                                 \
        ({                                                                                                      \
            DY_ArrayAssert((IDX), (self.count));                                                                \
            YES;                                                                                                \
        })                                                                                                      \
        :                                                                                                       \
        NO                                                                                                      \
    )
#else
    #define CheckIsIndexOutOfRange(IDX)                                                                         \
    (                                                                                                           \
        (self.count <= (IDX)) ?                                                                                 \
        ({                                                                                                      \
            DY_ArrayAssert((IDX), (self.count));                                                                \
            YES;                                                                                                \
        })                                                                                                      \
        :                                                                                                       \
        NO                                                                                                      \
    )
#endif

#ifdef DEBUG
    #define DY_CountDiffAssert(SET_COUNT, ARRAY_COUNT)                                                              \
    (                                                                                                               \
        ((SET_COUNT) != (ARRAY_COUNT)) ?                                                                            \
        ({                                                                                                          \
            NSAssert(NO,                                                                                            \
                @"NSMutableArray assert => %s:%d count of array {%lu} differs from count of index set {%lu}",       \
                __PRETTY_FUNCTION__,                                                                                \
                __LINE__,                                                                                           \
                (unsigned long)(SET_COUNT),                                                                         \
                (unsigned long)(ARRAY_COUNT));                                                                      \
            YES;                                                                                                    \
        })                                                                                                          \
        :                                                                                                           \
        NO                                                                                                          \
    )
#else
    #define DY_CountDiffAssert(SET_COUNT, ARRAY_COUNT)                                                              \
    (                                                                                                               \
        ((SET_COUNT) != (ARRAY_COUNT)) ?                                                                            \
        ({                                                                                                          \
            DYLogError(@"NSMutableArray error => %s:%d count of array {%lu} differs from count of index set {%lu}", \
                __PRETTY_FUNCTION__,                                                                                \
                __LINE__,                                                                                           \
                (unsigned long)(SET_COUNT),                                                                         \
                (unsigned long)(ARRAY_COUNT));                                                                      \
            YES;                                                                                                    \
        })                                                                                                          \
        :                                                                                                           \
        NO                                                                                                          \
    )
#endif

@implementation NSMutableArray (DY)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("__NSArrayM");
        [class swizzleInstanceMethod:@selector(addObject:) with:@selector(safe_addObject:)];
        [class swizzleInstanceMethod:@selector(insertObject:atIndex:) with:@selector(safe_insertObject:atIndex:)];
        [class swizzleInstanceMethod:@selector(removeObjectAtIndex:) with:@selector(safe_removeObjectAtIndex:)];
        [class swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) with:@selector(safe_replaceObjectAtIndex:withObject:)];
        [class swizzleInstanceMethod:@selector(exchangeObjectAtIndex:withObjectAtIndex:) with:@selector(safe_exchangeObjectAtIndex:withObjectAtIndex:)];
        [class swizzleInstanceMethod:@selector(removeObject:inRange:) with:@selector(safe_removeObject:inRange:)];
        [class swizzleInstanceMethod:@selector(removeObjectIdenticalTo:inRange:) with:@selector(safe_removeObjectIdenticalTo:inRange:)];
        [class swizzleInstanceMethod:@selector(removeObjectsInRange:) with:@selector(safe_removeObjectsInRange:)];
        [class swizzleInstanceMethod:@selector(replaceObjectsInRange:withObjectsFromArray:range:) with:@selector(safe_replaceObjectsInRange:withObjectsFromArray:range:)];
        [class swizzleInstanceMethod:@selector(replaceObjectsInRange:withObjectsFromArray:) with:@selector(safe_replaceObjectsInRange:withObjectsFromArray:)];
        [class swizzleInstanceMethod:@selector(setArray:) with:@selector(safe_setArray:)];
        [class swizzleInstanceMethod:@selector(insertObjects:atIndexes:) with:@selector(safe_insertObjects:atIndexes:)];
        [class swizzleInstanceMethod:@selector(removeObjectsAtIndexes:) with:@selector(safe_removeObjectsAtIndexes:)];
        [class swizzleInstanceMethod:@selector(replaceObjectsAtIndexes:withObjects:) with:@selector(safe_replaceObjectsAtIndexes:withObjects:)];
        [class swizzleInstanceMethod:@selector(setObject:atIndexedSubscript:) with:@selector(safe_setObject:atIndexedSubscript:)];
        
        //otherArray nullable
        //- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;
        //anObject nullable
        //- (void)removeObject:(ObjectType)anObject;
        //anObject nullable
        //- (void)removeObjectIdenticalTo:(ObjectType)anObject;
        //otherArray nullable
        //- (void)removeObjectsInArray:(NSArray<ObjectType> *)otherArray;
    });
}

//底层最终会调用insertObject:atIndex:
//这里只是为了能看callStack
- (void)safe_addObject:(id)obj
{
    return [self safe_addObject:obj];
}

- (void)safe_insertObject:(id)obj atIndex:(NSUInteger)index
{
    if (DY_invalidSafeArrayWithObj(obj)) {
        return;
    }
    //count 等于 index 的情况并不会闪退
    if (!(self.count == index) &&
        CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_insertObject:obj atIndex:index];
}

- (void)safe_removeObjectAtIndex:(NSUInteger)index
{
    if (CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_removeObjectAtIndex:index];
}

- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj
{
    if (CheckIsIndexOutOfRange(index) ||
        DY_invalidSafeArrayWithObj(obj)) {
        return;
    }
    return [self safe_replaceObjectAtIndex:index withObject:obj];
}

- (void)safe_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    if (CheckIsIndexOutOfRange(idx1) ||
        CheckIsIndexOutOfRange(idx2)) {
        return;
    }
    return [self safe_exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)safe_removeObject:(id)obj inRange:(NSRange)range
{
    //obj is nullable
    if (!obj) return;
    NSUInteger index = range.location + range.length;
    if (!(self.count == index) &&
        CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_removeObject:obj inRange:range];
}

- (void)safe_removeObjectIdenticalTo:(id)obj inRange:(NSRange)range
{
    //obj is nullable
    if (!obj) return;
    NSUInteger index = range.location + range.length;
    if (!(self.count == index) &&
        CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_removeObjectIdenticalTo:obj inRange:range];
}

- (void)safe_removeObjectsInRange:(NSRange)range
{
    NSUInteger index = range.location + range.length;
    if (!(self.count == index) &&
        CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_removeObjectsInRange:range];
}

- (void)safe_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray range:(NSRange)otherRange
{
    //otherArray is nullable
    NSUInteger index = range.location + range.length;
    NSUInteger otherIndex = otherRange.location + otherRange.length;
    if ((!(self.count == index) && CheckIsIndexOutOfRange(index)) ||
        (!(otherArray.count == otherIndex) && otherIndex >= otherArray.count)) {
        DY_ArrayAssert(otherIndex, otherArray.count);
        return;
    }
    return [self safe_replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)safe_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray
{
    //otherArray is nullable
    NSUInteger index = range.location + range.length;
    if (!(self.count == index) && CheckIsIndexOutOfRange(index)) {
        return;
    }
    return [self safe_replaceObjectsInRange:range withObjectsFromArray:otherArray];
}

- (void)safe_setArray:(NSArray<id> *)otherArray
{
    //otherArray is nullable
    if (!otherArray) return;
    if (DYCheckInvalidAndKindOfClass(otherArray, NSArray)) return;
    return [self safe_setArray:otherArray];
}

- (void)safe_insertObjects:(NSArray<id> *)objects atIndexes:(NSIndexSet *)indexes
{
    //objects nullable but range of indexes cannot larger than objects.count
    //indexes cannot be nil
    if (DYCheckInvalidAndKindOfClass(indexes, NSIndexSet)) return;
    NSUInteger firstIndex = indexes.firstIndex;
    NSUInteger lastIndex = indexes.lastIndex;
    if (NSNotFound == firstIndex ||
        NSNotFound == lastIndex ||
        (objects.count + self.count < lastIndex)) { //insertObjects 时 objects.count + self.count == lastIndex 并不会导致闪退
        DY_ArrayAssert(lastIndex, objects.count + self.count);
        return;
    }
    
    return [self safe_insertObjects:objects atIndexes:indexes];
}

- (void)safe_removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    //indexes cannot be nil
    if (DYCheckInvalidAndKindOfClass(indexes, NSIndexSet)) return;
    if (![self isValidIndexSet:indexes]) {
        return;
    }
    return [self safe_removeObjectsAtIndexes:indexes];
}

- (void)safe_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<id> *)objects
{
    //indexes cannot be nil
    if (DYCheckInvalidAndKindOfClass(indexes, NSIndexSet)) return;
    //objects is nullable
    if (!objects) return;
    if (DYCheckInvalidAndKindOfClass(objects, NSArray)) return;
    
    //count of array could not differ from count of index set
    if (DY_CountDiffAssert(indexes.count, objects.count)) return;
    
    [self safe_replaceObjectsAtIndexes:indexes withObjects:objects];
}


- (void)safe_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    if (DY_invalidSafeArrayWithObj(obj)) return;
    if (!(self.count == idx) && CheckIsIndexOutOfRange(idx)) {
        return;
    }
    return [self safe_setObject:obj atIndexedSubscript:idx];
}

#pragma mark - others
- (BOOL)isValidIndexSet:(NSIndexSet *)indexes
{
    if (DYCheckInvalidAndKindOfClass(indexes, NSIndexSet)) return NO;
    NSUInteger firstIndex = indexes.firstIndex;
    NSUInteger lastIndex = indexes.lastIndex;
    //[NSIndexSet indexSet] => NSNotFound == firstIndex && NSNotFound == lastIndex
    //In this case, app could not crash
    if (NSNotFound == firstIndex && NSNotFound == lastIndex) return YES;
    if (CheckIsIndexOutOfRange(lastIndex)) return NO;
    return YES;
}

//- (void)testCase
//{
//    NSMutableArray *list = [NSMutableArray array];
//    NSMutableArray *otherList = [NSMutableArray arrayWithArray:@[@"otherA", @"otherB", @"otherC"]];
//    //[list addObject:nil];
//    //[list removeObjectAtIndex:2];
//    [list insertObject:@"a" atIndex:0];
//    [list insertObject:@"b" atIndex:1];
//    //    [list insertObject:@"c" atIndex:3];
//    //    [list replaceObjectAtIndex:2 withObject:@"b"];
//    //[list replaceObjectAtIndex:1 withObject:nil];
//    //[list addObjectsFromArray:nil];
//    //[list exchangeObjectAtIndex:3 withObjectAtIndex:0];
//    //[list removeObject:@"b" inRange:NSMakeRange(1, 2)];
//    //[list removeObject:nil];
//    //[list removeObjectIdenticalTo:nil inRange:NSMakeRange(1, 2)];
//    //[list removeObjectIdenticalTo:nil];
//    //[list removeObjectsInArray:nil];
//    //[list removeObjectsInRange:NSMakeRange(1, 2)];
//    //[list replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:nil range:NSMakeRange(0, 0)];
//    //[list replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:otherList range:NSMakeRange(1, 3)];
//    //[list replaceObjectsInRange:(NSRange){0, 0} withObjectsFromArray:nil range:(NSRange){0, 1}];//bad
//    //[list replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:nil];
//    //[list setArray:nil];
//    //[list insertObjects:@[@"c", @"d", @"e"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){1, 3}]];
//    //[list insertObjects:@[@"c", @"d", @"e"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){2, 4}]];
//    //[list removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){2, 1}]];
//    //[list removeObjectsAtIndexes:nil];
//    //firstIndex == NSNotFound && lastIndex == NSNotFound
//    //[list removeObjectsAtIndexes:[NSIndexSet indexSet]];
//    //[list removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){2, 1}]];
//    //[list replaceObjectsAtIndexes:nil withObjects:nil];
//    //[list replaceObjectsAtIndexes:[NSIndexSet indexSet] withObjects:nil];
//    //[list replaceObjectsAtIndexes:[NSIndexSet indexSet] withObjects:@[]];
//    //[list replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){1, 1}] withObjects:@[@"abc", @"cde"]];
//    //list[1] = nil;
//    //list[2] = @"c";
//    //list[3] = @"c";
//}

@end
