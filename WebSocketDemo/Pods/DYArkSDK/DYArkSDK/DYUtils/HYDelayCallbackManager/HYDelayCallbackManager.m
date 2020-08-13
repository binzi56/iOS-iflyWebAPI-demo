//
//  HYDelayCallbackManager.m
//  HYCommon
//
//  Created by 杜林 on 2017/11/21.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import "KiwiSDKMacro.h"
#import "HYDelayCallbackManager.h"

@interface HYDelayCallbackManager ()

@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) NSMutableArray *contexts;

@end

@implementation HYDelayCallbackManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contexts = [NSMutableArray array];
        [self createSource];
    }
    return self;
}

- (void)tryCallback
{
    BOOL hasMore = [self callbackContext];
    
    //如果还有缓存的数据，则继续上传
    //保证在NSDefaultRunLoopMode下才发送信号量，保证scrollView滑动时的性能
    if (hasMore) {
        [self delayAddSemaphore:0.1f];
    }
}

- (BOOL)callbackContext
{
    //上传步长为1
    id context = [self.contexts firstObject];
    if (!context) {
        return NO;
    }
    
    [self.contexts removeObjectAtIndex:0];
    
    //上报
    if ([self.delegate respondsToSelector:@selector(delayCallbackManager:didCallbackWithContext:)]) {
        [self.delegate delayCallbackManager:self didCallbackWithContext:context];
    }
    
    return YES;
}

#pragma mark - merge

- (void)merge
{
    //合并1s内的打点操作，并在NSDefaultRunLoopMode下才发送信号量，保证scrollView滑动时的性能
    [self delayAddSemaphore:1.f];
}

- (void)delayAddSemaphore:(CGFloat)delay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addSemaphore) object:nil];
    [self performSelector:@selector(addSemaphore) withObject:nil afterDelay:delay];
}

#pragma mark - dispatch source

- (void)createSource
{
    [self clearSource];
    
    BlockWeakSelf(weakSelf, self);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(_source, ^{
        [weakSelf response];
    });
    dispatch_resume(_source);
}

- (void)addSemaphore
{
    //保证在主线程发送信号，保证当主线程繁忙时，不会响应信号量，空闲时会响应1次之前累积的信号量
    if (_source) {
        dispatch_source_merge_data(_source, 1);
    }
}

- (void)clearSource
{
    if (_source) {
        dispatch_source_cancel(_source);
        _source = nil;
    }
}

//响应信号量回调
- (void)response
{
    [self tryCallback];
}

#pragma mark -

- (void)addCallbackContext:(id)context
{
    if (context) {
        //保证信号量在主线程，且保证contexts线程安全
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contexts addObject:context];
            
            [self merge];
        });
    }
}

@end
