//
//  HYDelayCallbackManager.h
//  HYCommon
//
//  Created by 杜林 on 2017/11/21.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYDelayCallbackManager;

@protocol HYDelayCallbackManagerDelegate <NSObject>

- (void)delayCallbackManager:(HYDelayCallbackManager *)manager didCallbackWithContext:(id)context;

@end

@interface HYDelayCallbackManager : NSObject

@property (nonatomic, weak) id<HYDelayCallbackManagerDelegate> delegate;

- (void)addCallbackContext:(id)context;

@end
