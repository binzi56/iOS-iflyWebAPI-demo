//
//  DYRouterCenter.m
//  DYRouter
//
//  Created by flyhuang on 2018/11/6.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import "DYRouterCenter.h"

@interface DYRouterCenter()

@property (nonatomic, strong) NSMutableDictionary<NSString*,DYRouterAction*> *actions;

@end

@implementation DYRouterCenter

+ (instancetype)shareInstance
{
    static DYRouterCenter *router;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        router = [[self.class alloc]init];
    });
    
    return router;
}

- (instancetype)init
{
    if (self = [super init]) {
        _actions = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return self;
}

- (void)addRouterAction:(NSString *)name
        translateParams:(DYRouterTranslateBlock)translateParams
             controller:(DYRouterControllerBlock)controller
               validate:(DYRouterValidateBlock)validate
                 action:(DYRouterActionBlock)action
{
    if (name.length && controller && action) {
        DYRouterAction *routerAction = [[DYRouterAction alloc] init];
        routerAction.translateBlock = translateParams;
        routerAction.controllerBlock = controller;
        routerAction.actionBlock = action;
        routerAction.validateBlock = validate;
        routerAction.name = name;
        [self addRouterAction:name action:routerAction];
    }
}

- (void)addRouterAction:(NSString *)name
                 action:(DYRouterAction*)action
{
    if (name.length && action) {
        [self.actions setObject:action forKey:name];
    }
}

- (void)addRouterWithName:(NSString *)name
             routerAction:(id<IDYRouterAction>)router
{
    if (name.length && [router conformsToProtocol:@protocol(IDYRouterAction)]) {
        DYRouterAction *routerAction = [[DYRouterAction alloc] init];
        routerAction.router = router;
        [self.actions setObject:routerAction forKey:name];
    }
}

- (NSArray<DYRouterAction *> *)routerActions
{
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:5];
    
    [self.actions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DYRouterAction * _Nonnull obj, BOOL * _Nonnull stop) {
        [actions addObject:obj];
    }];
    
    return actions;
}

- (DYRouterAction *)actionWithName:(NSString *)name
{
    if (name.length) {
        return [self.actions objectForKey:name];
    } else {
        return nil;
    }
}

@end
