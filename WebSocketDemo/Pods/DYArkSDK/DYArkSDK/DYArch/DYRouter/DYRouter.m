//
//  DYRouter.m
//  DYRouter
//
//  Created by flyhuang on 2018/11/6.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import "DYRouter.h"
#import "DYRouterCenter.h"
#import "NSString+KWS.h"
#import "DYMediator.h"
#import "HYLogMacros.h"

@implementation DYRouterConfig

@end

@interface DYRouter()

@property (nonatomic, strong) DYRouterConfig *config;

@end

@implementation DYRouter

+ (instancetype)shareInstance
{
    static DYRouter *router;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        router = [[self.class alloc]init];
    });
    
    return router;
}

+ (void)load
{
    
}

+ (instancetype)router
{
    return [self shareInstance];
}

+ (instancetype)routerWithAction:(NSString *)name
                 translateParams:(DYRouterTranslateBlock)translateParams
                      controller:(DYRouterControllerBlock)controller
                        validate:(DYRouterValidateBlock)validate
                          action:(DYRouterActionBlock)action
{
    [[DYRouterCenter shareInstance] addRouterAction:name
                                    translateParams:translateParams
                                         controller:controller
                                           validate:validate
                                             action:action];
    
    return [self shareInstance];
}

+ (instancetype)routerAliasWithAction:(NSString *)name
                                alias:(NSString *)alias
{
    DYRouterAction *action = [[self shareInstance] actionWithName:name];
    
    if (action) {
        [[DYRouterCenter shareInstance] addRouterAction:name action:action];
    }
    
    return [self shareInstance];
}

+ (void)addRouterWithName:(NSString *)name
             routerAction:(id<IDYRouterAction>)router
{
    [[DYRouterCenter shareInstance] addRouterWithName:name
                                         routerAction:router];
}

+ (void)registerRouter:(NSString *)name
                 class:(Class)clazz
{
    id<IDYRouterAction> router = [[clazz alloc] init];
    
    if ([router conformsToProtocol:@protocol(IDYRouterAction)]) {
        [[DYRouterCenter shareInstance] addRouterWithName:name routerAction:router];
    } else {
        NSAssert(NO, @"router not conformsToProtocol %@ %@", name, clazz);
    }
}

- (void)setup:(DYRouterConfig *)cfg
{
    self.config = cfg;
}

- (void)open:(NSString *)name
      params:(NSDictionary *)params
{
    [self open:name params:params config:nil];
}

- (void)open:(NSString *)name
      params:(NSDictionary *)params
      config:(DYRouterActionConfig *)config
{
    DYRouterAction *action = [[DYRouter router] actionWithName:name];
    
    if (action) {
        [self runAction:action params:params config:config];
    }
}

- (BOOL)canOpen:(NSString *)url
{
    DYRouterAction *action = [self actionWithUrl:url];
    return action != nil;
}

- (BOOL)openUrl:(NSString *)url
{
    if (url.length <= 0) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(dyrouterPreprocessUrl:)]) {
        url = [self.delegate dyrouterPreprocessUrl:url];
    }
    
    DYRouterAction *action = [self actionWithUrl:url];
    if (action) {
        
        BOOL runAction = YES;
        
        if ([self.delegate respondsToSelector:@selector(dyrouterValidate:url:)]) {
            runAction = [self.delegate dyrouterValidate:action url:url];
        }
        
        if (!runAction) {
            DYLogInfo(@"dyrouterValidate failed : %@", url);
            return NO;
        }
        
        NSDictionary *params = [NSDictionary new];
        //需要将url的params转为native的params
        if (action.router && [action.router respondsToSelector:@selector(dyrouterTranslateParams:)]) {
            NSDictionary *dict = [url decodeUrlParametersKeyToLowercase:YES valueReplacingPercentEscapes:YES];
            params = [action.router dyrouterTranslateParams:dict];
        } else if (action.translateBlock) {
            NSDictionary *dict = [url decodeUrlParametersKeyToLowercase:YES valueReplacingPercentEscapes:YES];
            params = action.translateBlock(dict);
        }

        [self runAction:action params:params config:nil];
        return YES;
    } else {
        
        if ([self.delegate respondsToSelector:@selector(dyrouterFailureOpenUrl:)]) {
            [self.delegate dyrouterFailureOpenUrl:url];
        }
        return NO;
    }
}

#pragma mark - private

- (NSString *)parseActionNameWithUrl:(NSString *)url
{
    NSDictionary *dict = [url decodeUrlParametersKeyToLowercase:YES valueReplacingPercentEscapes:YES];
    
    if (self.config.actionKey.length) {
        NSString *actionName = [dict objectForKey:self.config.actionKey];
        
        if (!actionName && self.config.customActionMap) {
            actionName = self.config.customActionMap(url);
        }
        return actionName;
    } else {
        return @"";
    }
}

- (DYRouterAction *)actionWithName:(NSString *)name
{
    DYRouterAction *action = [[DYRouterCenter shareInstance] actionWithName:name];
    return action;
}

- (DYRouterAction *)actionWithUrl:(NSString *)url
{
    NSString *actionName = [self parseActionNameWithUrl:url];
    DYRouterAction *action =  [self actionWithName:actionName];
    
    if (!action && self.config && self.config.customActionFilter) {
        NSArray *actions = [[DYRouterCenter shareInstance] routerActions];
        action = self.config.customActionFilter(actions , url);
    }
    
    return action;
}

- (void)runAction:(DYRouterAction *)action
           params:(NSDictionary *)params
           config:(DYRouterActionConfig *)config
{
    if (!config) {
        config = [[DYRouterActionConfig alloc] init];
    }
    
    config.routerParams = params;
    
    if (action) {
        
        BOOL shouldRunAction = YES;
        BOOL needLogin = YES;
        
        if (action.router) {
            
            UIViewController *controller = [action.router dyrouterController];
            
            if (params) {
                [DYMediator performTarget:controller class:[controller class] kvcDicts:params];
            }
            
            if ([action.router respondsToSelector:@selector(dyrouterValidateParams:)]) {
                shouldRunAction = [action.router dyrouterValidateParams:params];
            }
            
            if (shouldRunAction) {
                [action.router dyrouterAction:controller config:config];
            } else {
                DYLogError(@"validate params failed : %@ params: %@", action.name, params);
            }
            
        } else {
            UIViewController *controller = action.controllerBlock();
            if (params) {
                [DYMediator performTarget:controller class:[controller class] kvcDicts:params];
            }
            
            if (action.validateBlock) {
                shouldRunAction = action.validateBlock(params);
            }
            
            if (shouldRunAction) {
                action.actionBlock(controller, config);
            } else {
                DYLogError(@"validate params failed : %@ params: %@", action.name, params);
            }
        }
        
    }
}

@end
