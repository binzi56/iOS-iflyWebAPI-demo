//
//  DYMutilDelegates.h
//
//  Created by flyhuang on 15/8/17.
//  Copyright (c) 2018年 dianyun. All rights reserved.
//

#import "DYMutilDelegates.h"

@interface DYMutilDelegates ()

@property (strong, nonatomic) NSHashTable *delegateHashTable;

@end

@implementation DYMutilDelegates

- (instancetype)init
{
    if (self = [super init]) {
        _delegateHashTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addDelegate:(id)delegate
{
    if (!delegate) {
        return;
    }
    
    if (![self.delegateHashTable containsObject:delegate]) {
        [self.delegateHashTable addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate
{
    if (!delegate) {
        return;
    }
    
    [self.delegateHashTable removeObject:delegate];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{

    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (id target in self.delegateHashTable) {
        if ([target respondsToSelector:aSelector]) {
            return YES;
        }
    }

    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        for (id target in self.delegateHashTable) {
            if ((sig = [target methodSignatureForSelector:aSelector])) {
                return sig;
            }
        }
    }
    
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSHashTable* table = [self.delegateHashTable copy];
    for (id target in table) {
        if ([target respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:target];
        }
    }
}

@end
