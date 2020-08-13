//
//  NSArray+DY.h
//  AFNetworking
//
//  Created by EasyinWan on 2018/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (DY)

- (ObjectType)safeObjectAtIndex:(NSUInteger)index;

- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
