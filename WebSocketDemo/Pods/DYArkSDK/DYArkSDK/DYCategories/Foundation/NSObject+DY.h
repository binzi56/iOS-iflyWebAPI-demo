//
//  NSObject+YYAdd.h
//  YYCategories <https://github.com/ibireme/YYCategories>
//
//  Created by ibireme on 14/10/8.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>


/**
 Common tasks for NSObject.
 */
@interface NSObject (DY)

- (void)dy_sendNotification:(NSString *)name obj:(id)object;

- (id)dy_addObserver:(NSString *)name
               block:(void(^)(NSNotification *notification))block;

- (void)dy_removeObserver:(NSString *)name;

- (void)dy_clearEvents;

@end
