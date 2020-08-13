////  HYFControlEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFControlEvent.h"

@implementation HYFControlEvent
{
    NSString *_sel;
    ETControllerEventType _type;
}

- (instancetype)initWithSEL:(SEL)sel target:(id)target type:(ETControllerEventType)type {
    if (self = [super init]) {
        if (target) {
            [self.tracedObj setupWithObject:target];
        }
        if (sel) {
            _sel = NSStringFromSelector(sel);
        }
        _type = type;
    }
    
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    [des appendString:[NSString stringWithFormat:@"%@ %@: %@", [self.tracedObj objectDescription], [self stringFromEventType], _sel]];
    [des appendString:self.rightBorder];
    return des;
}

- (NSString*)stringFromEventType {
    NSString *str = nil;
    switch (_type) {
        case ETControlEventTypeSendAction:
            str = @"sendAction";
            break;
            
        default:
            break;
    }
    return str;
}


@end
