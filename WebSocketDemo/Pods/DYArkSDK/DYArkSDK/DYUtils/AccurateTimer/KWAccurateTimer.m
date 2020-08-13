//
//  KWAccurateTimer.m
//  kiwi
//
//  Created by pengfeihuang on 16/7/28.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "KWAccurateTimer.h"

@interface KWAccurateTimer()

@property(nonatomic,strong) KWAccurateTimerBlock block;
@property(nonatomic,assign) NSTimeInterval timeInterval;
@property(nonatomic,assign) BOOL isRepat;
@property(nonatomic,assign) BOOL ignoreFirstCallback;
@property(nonatomic,strong) CADisplayLink* displayLink;

@end

@implementation KWAccurateTimer

+ (KWAccurateTimer *)startWithTimeInterval:(NSTimeInterval)timeInterval
                                   repeats:(BOOL)isRepeat
                                   timeout:(KWAccurateTimerBlock)timeout
{
    KWAccurateTimer* timer = [[KWAccurateTimer alloc] init];
    timer.timeInterval = timeInterval;
    timer.isRepat = isRepeat;
    timer.block = timeout;
    [timer setupDisplayLink];
    return timer;
}

- (void)dealloc
{
    [self invalidate];
}

#pragma mark - public

- (void)invalidate
{
    [self removeDisplayLink];
}

#pragma mark - private

- (void)setupDisplayLink
{
    [self removeDisplayLink];
    
    if (!self.displayLink) {
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkBlock)];
        //由于忽略了第一帧的调用，所以帧数减一。（默认会以1/60的速度调用第一次，frameInterval在第二次后才为设定的值）
        NSInteger frameInterval = MAX(floor(self.timeInterval * 1000 / 17) - 1, 1);
        self.ignoreFirstCallback = frameInterval > 1;//如果帧数为1，不忽略第一次回调
        displayLink.frameInterval = frameInterval;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = displayLink;
    }
}

- (void)removeDisplayLink
{
    if (self.displayLink) {
        [self.displayLink invalidate];
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (void)displayLinkBlock
{
    if (self.ignoreFirstCallback) {
        self.ignoreFirstCallback = NO;
        return;
    }
    
    if (self.block) {
        self.block();
    }
    
    if (!self.isRepat) {
        [self invalidate];
    }
}

@end
