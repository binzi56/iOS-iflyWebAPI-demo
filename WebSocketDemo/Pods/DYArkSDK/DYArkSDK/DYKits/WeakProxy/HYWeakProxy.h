////  HYWeakProxy.h
//  KiwiSDK
//
//  Created by Haisheng Ding on 2018/7/31.
//  Copyright © 2018年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYWeakProxy : NSObject

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end
