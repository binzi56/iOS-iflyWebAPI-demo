//
//  KWAccurateTimer.h
//  kiwi
//
//  Created by pengfeihuang on 16/7/28.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KWAccurateTimerBlock)(void);

@interface KWAccurateTimer : NSObject

+ (KWAccurateTimer *)startWithTimeInterval:(NSTimeInterval)timeInterval
                                   repeats:(BOOL)isRepeat
                                   timeout:(KWAccurateTimerBlock)timeout;

- (void)invalidate;

@end
