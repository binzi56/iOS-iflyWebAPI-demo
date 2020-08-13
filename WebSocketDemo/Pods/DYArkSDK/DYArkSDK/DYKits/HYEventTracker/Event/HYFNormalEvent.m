////  HYFNormalEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFNormalEvent.h"

@implementation HYFNormalEvent
{
    NSString *_name;
    NSString *_event;
}

- (instancetype)initWithName:(NSString*)name event:(NSString*)event {
    if (self = [super init]) {
        if (name) {
            _name = [name copy];
        }
        if (event) {
            _event = [event copy];
        }
    }
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    [des appendString:[NSString stringWithFormat:@"%@:%@", _name, _event]];
    [des appendString:self.rightBorder];
    return des;
}


@end
