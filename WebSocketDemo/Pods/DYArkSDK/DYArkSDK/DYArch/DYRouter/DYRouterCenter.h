//
//  DYRouterCenter.h
//  DYRouter
//
//  Created by flyhuang on 2018/11/6.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYRouterTypes.h"

@interface DYRouterCenter : NSObject

+ (instancetype)shareInstance;

- (NSArray<DYRouterAction *> *)routerActions;

- (void)addRouterAction:(NSString *)name
        translateParams:(DYRouterTranslateBlock)translateParams
             controller:(DYRouterControllerBlock)controller
               validate:(DYRouterValidateBlock)validate
                 action:(DYRouterActionBlock)action;

- (void)addRouterWithName:(NSString *)name
             routerAction:(id<IDYRouterAction>)router;

- (void)addRouterAction:(NSString *)name
                 action:(DYRouterAction*)action;

- (DYRouterAction *)actionWithName:(NSString *)name;

@end
