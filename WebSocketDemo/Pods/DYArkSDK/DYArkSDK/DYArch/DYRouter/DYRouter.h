//
//  DYRouter.h
//  DYRouter
//
//  Created by flyhuang on 2018/11/6.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DYRouterTypes.h"

@class DYRouterConfig;

@interface DYRouterConfig : NSObject

//页面url里action的key
//http://xxxx?dyaction=xxxx, dyaction为key
@property (nonatomic, strong) NSString *actionKey;
//自定义路由查找
@property (nonatomic, strong) DYRouterCustomFilterBlock customActionFilter;
//自定义路由查找
@property (nonatomic, strong) DYRouterCustomActionMapBlock customActionMap;

@end

#define DYRouterPath(_pageID_) \
+ (void)load { \
[DYRouter registerRouter:_pageID_ class:self]; \
}

@protocol IDYRouterDelegate <NSObject>

@optional

- (void)dyrouterFailureOpenUrl:(NSString *)url;

- (BOOL)dyrouterValidate:(DYRouterAction *)action url:(NSString *)url;

- (NSString *)dyrouterPreprocessUrl:(NSString *)url;

@end

@interface DYRouter : NSObject

@property(nonatomic,weak) id<IDYRouterDelegate> delegate;

+ (instancetype)router;

+ (instancetype)routerWithAction:(NSString *)name
                 translateParams:(DYRouterTranslateBlock)translateParams
                      controller:(DYRouterControllerBlock)controller
                        validate:(DYRouterValidateBlock)validate
                          action:(DYRouterActionBlock)action;

+ (instancetype)routerAliasWithAction:(NSString *)name
                                alias:(NSString *)alias;

+ (void)addRouterWithName:(NSString *)name
             routerAction:(id<IDYRouterAction>)router;

+ (void)registerRouter:(NSString *)name
                 class:(Class)clazz;

- (void)setup:(DYRouterConfig *)cfg;

/*
 * 打开指定name的路由，params存放oc类型对应类的key和value
 */
- (void)open:(NSString *)name
      params:(NSDictionary *)params;

- (void)open:(NSString *)name
      params:(NSDictionary *)params
      config:(DYRouterActionConfig *)config;

- (BOOL)canOpen:(NSString *)url;

/*
 * 根据url打开路由，params存放oc类型对应类的key和value
 */
- (BOOL)openUrl:(NSString *)url;

@end

