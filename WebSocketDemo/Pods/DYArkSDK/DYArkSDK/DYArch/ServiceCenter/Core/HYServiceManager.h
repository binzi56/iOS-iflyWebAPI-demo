//
//  ServiceManager.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYServiceTypes.h"

/*
 * 负责service的创建与映射管理，不负责加载逻辑
 * thread safe
 */
@interface HYServiceManager : NSObject<IWFServiceManager>

@end
