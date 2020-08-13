////  HYFEventBase.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 除了组件内部创建的对象，tracker组件不应该持有任何被trace的对象
 */
@interface ETTraceObject: NSObject

@property (nonatomic, assign) Class objectClass;
@property (nonatomic, assign) void *objectAddress;

- (instancetype)initWithObject:(NSObject*)object;
- (void)setupWithObject:(NSObject*)object;

- (NSString*)objectDescription;

@end

/**
 * event不应该持有任何被trace的对象
 */
@interface HYFEventBase : NSObject

@property (nonatomic, assign) NSUInteger sequence;
@property (nonatomic, strong) ETTraceObject* tracedObj;
@property (nonatomic, strong) NSString *leftBorder;
@property (nonatomic, strong) NSString *rightBorder;

- (NSString *)formatDate;

//事件输出内容，子类必须实现
- (NSString *)eventDescription;

- (NSMutableString *)baseDescription;

@end
