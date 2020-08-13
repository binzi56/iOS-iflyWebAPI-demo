//
//  HYGCDQueuePool.h
//  HYBase
//
//  Created by lslin on 2017/9/29.
//  Copyright © 2017年 huya.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HY_DISPATCH_QUEUE_POOL_ID_BIZ  (0) //业务
#define HY_DISPATCH_QUEUE_POOL_ID_MODEL (1) //数据

#define HY_DISPATCH_QUEUE_POOL_DEFAULT_QUEUE_COUNT 4

#ifdef __cplusplus
extern "C" {
#endif
    
    void hy_dispatch_async(long poolID, dispatch_block_t block);
    void hy_dispatch_async_biz(dispatch_block_t block);
    void hy_dispatch_async_model(dispatch_block_t block);
    
#ifdef __cplusplus
}
#endif


#pragma mark -

@protocol HYGCDQueuePoolManagerDelegate <NSObject>

@required
- (BOOL)hyGCDQueuePoolManagerEnable;

@end

@interface HYGCDQueuePoolManager : NSObject

@property (nonatomic, weak) id<HYGCDQueuePoolManagerDelegate> delegate;

+ (instancetype)sharedObject;

@end
