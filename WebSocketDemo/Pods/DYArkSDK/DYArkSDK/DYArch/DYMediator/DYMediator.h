//
//  DYMediator.h
//  kiwi
//
//  Created by lslin on 16/9/12.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DYMediatorAction(returnType,action) -(returnType) HYAction_##action:(NSDictionary*)params;

#define DYMediatorNativeAction(returnType,action) -(returnType) HYNativeAction_##action:(NSDictionary*)params;

@interface DYMediator : NSObject

+ (instancetype)sharedObject;

/**
 * scheme跳转，使用这种路由方式不需要注册。
 * @param url 跳转scheme
 * @param completion
 * @return 方法调用结果。1.如果selector返回值为char,int,short,long,long long,float,double,bool,BOOL,指针时转换成NSNumber，指针使用longValue；2.如果selector返回值为SEL转化成NSString。3.如果selector返回值为void返回nil。4.调用失败时返回nil
 */
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;

/**
 * 调用指定类的类方法
 * @param selectorName 方法名
 * @param className 类名
 * @return 方法调用结果。1.如果selector返回值为char,int,short,long,long long,float,double,bool,BOOL,指针时转换成NSNumber，指针使用longValue；2.如果selector返回值为SEL转化成NSString。3.如果selector返回值为void返回nil。4.调用失败时返回nil
 */
- (id)performSelector:(NSString*)selectorName forClass:(NSString *)className;

/**
 * 调用target-action方法，该方法用来模块间横向依赖解藕
 * @param action action名，action自动加上HYAction_前缀,HYAction_前缀的action可以响应scheme跳转
 * @param target target名，target自动加上HYTarget_前缀
 * @isCacheTarget 是否缓存target，频繁调用方法使用YES提高性能。如果NO的话调用时会new一个新的target
 * @return action调用结果。1.如果selector返回值为char,int,short,long,long long,float,double,bool,BOOL,指针时转换成NSNumber，指针使用longValue；2.如果selector返回值为SEL转化成NSString。3.如果selector返回值为void返回nil。4.调用失败时返回nil
 */
- (id)performAction:(NSString *)action forTarget:(NSString *)target params:(NSDictionary *)params isCacheTarget:(BOOL)isCacheTarget;

/**
 * 调用target-action方法，该方法用来模块间横向依赖解藕
 * @param action nativeAction名，action自动加上HYNativeAction_前缀，HYNativeAction_前缀的action不响应scheme跳转，防止恶意调用通过远程方式调用本地模块
 * @param target target名，target自动加上HYTarget_前缀
 * @isCacheTarget 是否缓存target，频繁调用方法使用YES提高性能。如果NO的话调用时会new一个新的target
 * @return action调用结果。1.如果selector返回值为char,int,short,long,long long,float,double,bool,BOOL,指针时转换成NSNumber，指针使用longValue；2.如果selector返回值为SEL转化成NSString。3.如果selector返回值为void返回nil。4.调用失败时返回nil
 */
- (id)performNativeAction:(NSString *)action forTarget:(NSString *)target params:(NSDictionary *)params isCacheTarget:(BOOL)isCacheTarget;

/**
 * 释放target缓存
 * @param target target名，target自动加上HYTarget_前缀
 */
- (void)releaseCacheTarget:(NSString *)target;

/**
 * 设置target的kvc键值对
 * @param target target名，target自动加上HYTarget_前缀
 */
+ (void)performTarget:(id)target
                class:(Class)clazz
             kvcDicts:(NSDictionary *)kvcDicts;

@end
