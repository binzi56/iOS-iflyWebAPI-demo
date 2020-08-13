//
//  HYSpinLock.m
//  HYBase
//
//  Created by 杜林 on 2017/8/9.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "HYSpinLock.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>

@interface HYSpinLock ()
{
    OSSpinLock _lockiOS10Early;
    os_unfair_lock _lockiOS10AndLater;
}
@end

@implementation HYSpinLock

static bool newLockEnable() {
    static bool enable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *system = [[UIDevice currentDevice] systemVersion];
        enable = !([system compare:@"10.0" options:NSNumericSearch] == NSOrderedAscending);
    });
    return enable;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (newLockEnable()) {
            _lockiOS10AndLater = OS_UNFAIR_LOCK_INIT;
        }else{
            _lockiOS10Early = OS_SPINLOCK_INIT;
        }
    }
    return self;
}

- (void)lock
{
    if (newLockEnable()) {
        os_unfair_lock_lock(&_lockiOS10AndLater);
    }else{
        OSSpinLockLock(&_lockiOS10Early);
    }
}

- (void)unlock
{
    if (newLockEnable()) {
        os_unfair_lock_unlock(&_lockiOS10AndLater);
    }else{
        OSSpinLockUnlock(&_lockiOS10Early);
    }
}

@end
