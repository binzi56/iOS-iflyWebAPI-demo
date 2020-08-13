//
//  UIControl+BtnQuickLimit.h
//  AFNetworking
//
//  Created by DF on 2018/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (BtnQuickLimit)
// 间隔多少秒才能响应事件
@property(nonatomic, assign) NSTimeInterval  acceptEventInterval;
//是否能执行方法
@property(nonatomic, assign) BOOL ignoreEvent;
@end

NS_ASSUME_NONNULL_END
