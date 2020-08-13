//
//  HYTestService.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/9.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYServiceCenter.h"

@protocol IHYTestService <IWFService>

- (void)foo;

@end

@interface HYTestService : NSObject<IHYTestService>

@end

@protocol IHYTestAnontionService <IWFService>

- (void)foo;

@end

@interface HYAnontionService : NSObject<IHYTestAnontionService>

@end


@protocol IHYTestPlistService <IWFService>

- (void)hello;

@end

@interface HYPlistService : NSObject<IHYTestPlistService>

@end
