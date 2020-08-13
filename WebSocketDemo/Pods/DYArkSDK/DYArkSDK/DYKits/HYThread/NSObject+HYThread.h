//
//  NSObject+ThreadAbout.h
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//
//
//【NOTE】
//线程相关调用保护

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
    
    void dispatch_async_main_queue_safe(dispatch_block_t block);
    
    
#ifdef __cplusplus
}
#endif


@interface NSObject (ThreadAbout)

- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName;
- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName userInfo:(nullable NSDictionary *)aUserInfo;
- (void)postNotificationInMainThreadWithName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

@end

NS_ASSUME_NONNULL_END
