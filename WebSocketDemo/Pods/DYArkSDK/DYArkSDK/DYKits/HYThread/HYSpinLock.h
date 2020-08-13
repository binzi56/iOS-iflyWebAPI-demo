//
//  HYSpinLock.h
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//
//
//【NOTE】
//对于自旋锁的封装，
//自旋锁有潜在的造成线程优先级翻转的问题，iOS10之后，iOS用不公平锁代替自旋锁
//使用自旋锁的业务场景，应该尽量使用这个类

#import <Foundation/Foundation.h>

@interface HYSpinLock : NSObject

- (void)lock;
- (void)unlock;

@end
