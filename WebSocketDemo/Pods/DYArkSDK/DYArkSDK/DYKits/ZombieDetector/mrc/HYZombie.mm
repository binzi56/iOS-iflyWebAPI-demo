////  HYZombie.m
//  HYZombieDetector
//
//  Created by Haisheng Ding on 2018/5/23.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Use -fno-objc-arc flag.
#endif

#import "HYZombie.h"
#import "HYZombieDetector.h"
#import "HYThreadStack.h"
#import "HYLogMacros.h"
#import <objc/runtime.h>

@implementation HYZombie

+ (Class)zombieIsa
{
    return [self class];
}

+ (NSInteger)zombieInstanceSize
{
    return class_getInstanceSize([HYZombie zombieIsa]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(aSelector) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* sig = [super methodSignatureForSelector:@selector(doNothing)];
    return sig;
}

- (void)doNothing
{
    DYLogInfo(@"我只是保护一下crash，什么也不干");
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [self doNothing];
}

-(void)dealloc{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    [super dealloc];
}

-(instancetype)retain
{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (id)copy
{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (id)mutableCopy
{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

-(oneway void)release{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
}

- (instancetype)autorelease{
    @autoreleasepool {
        HYThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (void)handleZombieWithSelector:(NSString *)selectorName zombieStack:(HYThreadStack *)zombieStack deallocStack:(HYThreadStack *)deallocStack
{
    @autoreleasepool {
        if ([HYZombieDetector sharedInstance].handle) {
            NSString *deallocStackInfo = nil;
            NSString *zombieStackInfo = nil;
            if (deallocStack) {
                deallocStackInfo = [[NSString alloc]initWithUTF8String:deallocStack->currentStackInfo().c_str()];
            }
            if (zombieStack) {
                zombieStackInfo = [[NSString alloc]initWithUTF8String:zombieStack->currentStackInfo().c_str()];
            }
            
            
            [HYZombieDetector sharedInstance].handle(self.realClass, self, selectorName, deallocStackInfo, zombieStackInfo);
        }
    }
    
    if ([HYZombieDetector sharedInstance].crashWhenDetectedZombie) {
        assert(0); ///如果不保护，刚直接进入assert中断程序
    }
}

@end
