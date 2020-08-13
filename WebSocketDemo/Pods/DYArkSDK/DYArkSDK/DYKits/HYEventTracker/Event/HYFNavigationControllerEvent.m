////  HYFNavigationControllerEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFNavigationControllerEvent.h"

@implementation HYFNavigationControllerEvent
{
    NSMutableArray<ETTraceObject*> *_viewControllers;
    ETNavigationControllerEventType _type;
}

- (instancetype)initWithNavigationController:(UINavigationController*)navigationController
                             viewControllers:(NSArray*)viewControllers
                                        type:(ETNavigationControllerEventType)type {
    if (self = [super init]) {
        if (navigationController) {
            [self.tracedObj setupWithObject:navigationController];
        }
        if (viewControllers.count) {
            _viewControllers = [NSMutableArray new];
            for (UIViewController* VC in viewControllers) {
                ETTraceObject *obj = [[ETTraceObject alloc] initWithObject:VC];
                [_viewControllers addObject:obj];
            }
        }
        _type = type;
    }
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    NSString *ext = nil;
    if (_viewControllers.count > 1 ) {
        NSMutableString *objs = [NSMutableString new];
        [objs appendString:@"["];
        for (ETTraceObject* obj in _viewControllers) {
            [objs appendString:[obj objectDescription]];
            [objs appendString:@", "];
        }
        [objs appendString:@"=]"];
        ext = objs;
    } else if(_viewControllers.count == 1) {
        ext = [[_viewControllers objectAtIndex:0] objectDescription];
    }
    [des appendString:[NSString stringWithFormat:@"%@ %@:%@", [self.tracedObj objectDescription], [self stringFromEventType], ext]];
    [des appendString:self.rightBorder];
    return des;
}

- (NSString*)stringFromEventType {
    NSString *str = nil;
    switch (_type) {
        case ETNavigationControllerEventTypePushViewController:
            str = @"pushViewController";
            break;
        case ETNavigationControllerEventTypePopViewController:
            str = @"popViewController";
            break;
        case ETNavigationControllerEventTypePopToViewController:
            str = @"popToViewController";
            break;
        case ETNavigationControllerEventTypePopToRootViewController:
            str = @"popToRootViewController";
            break;
        case ETNavigationControllerEventTypeSetViewControllers:
            str = @"setViewControllers";
            break;
        default:
            break;
    }
    return str;
}

@end
