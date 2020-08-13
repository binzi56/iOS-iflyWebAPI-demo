////  HYFNormalEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

@interface HYFNormalEvent : HYFEventBase

- (instancetype)initWithName:(NSString*)name event:(NSString*)event;

@end
