//
//  DYRouterTypes.h
//  DYRouter
//
//  Created by flyhuang on 2018/11/6.
//  Copyright © 2018年 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DYRouterActionConfig : NSObject

//外部只能取值，不能赋值
@property(nonatomic,strong) NSDictionary* routerParams;

@end

@protocol IDYRouterAction <NSObject>

@optional

/*
 * 例如：http://xxx?dyaction=playerHome&playerId=1232454
 * 当某个界面需要通过url方式直接跳转的时候，我们需要从url里解析出参数转为对应的oc类型
 * 这里我们需要把playerId转为对应的oc类型
 */
- (NSDictionary *)dyrouterTranslateParams:(NSDictionary *)params;

/*
 * 校验参数，如果参数不满足则返回false,界面不进行跳转
 */
- (BOOL)dyrouterValidateParams:(NSDictionary *)params;


@required

/*
 * 初始化对应路由的controller
 */
- (UIViewController *)dyrouterController;

/*
 * 路由匹配时需要完成的动作，例如pushViewController
 */
- (void)dyrouterAction:(UIViewController *)controller
                config:(DYRouterActionConfig *)config;

@end

typedef __kindof UIViewController* (^DYRouterControllerBlock)(void);

typedef void (^DYRouterActionBlock)(__kindof UIViewController *controller, DYRouterActionConfig *config);

typedef __kindof NSDictionary* (^DYRouterTranslateBlock)(NSDictionary *params);

typedef BOOL (^DYRouterValidateBlock)(NSDictionary *params);

@interface DYRouterAction : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) DYRouterControllerBlock controllerBlock;
@property (nonatomic, strong) DYRouterActionBlock actionBlock;
@property (nonatomic, strong) DYRouterTranslateBlock translateBlock;
@property (nonatomic, strong) DYRouterValidateBlock validateBlock;
@property (nonatomic, strong) id<IDYRouterAction> router;

@end

typedef __kindof DYRouterAction* (^DYRouterCustomFilterBlock)(NSArray *actions , NSString *url);
typedef __kindof NSString* (^DYRouterCustomActionMapBlock)(NSString *url);




