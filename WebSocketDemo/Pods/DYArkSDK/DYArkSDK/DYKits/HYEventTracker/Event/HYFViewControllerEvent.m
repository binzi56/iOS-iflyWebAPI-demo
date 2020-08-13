////  HYFViewControllerEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFViewControllerEvent.h"

@implementation HYFViewControllerEvent
{
    ETViewControllerEventType _type;
    id _ext;
}

- (instancetype)initWithViewController:(UIViewController*)viewController
                                   ext:(id)ext
                                  type:(ETViewControllerEventType)type {
    if (self = [super init]) {
        if (viewController) {
            [self.tracedObj setupWithObject:viewController];
        }
        _ext = ext;
        _type = type;
    }
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    if (_type == ETViewControllerEventTypeSetTitle && [_ext isKindOfClass:[NSString class]]) {
        [des appendString:[NSString stringWithFormat:@"%@ %@:%@", [self.tracedObj objectDescription], [self stringFromEventType], _ext]];
    } else {
        [des appendString:[NSString stringWithFormat:@"%@ %@", [self.tracedObj objectDescription], [self stringFromEventType]]];
    }
    [des appendString:self.rightBorder];
    
    return des;
}

- (NSString*)stringFromEventType {
    NSString *str = nil;
    switch (_type) {
        case ETViewControllerEventTypeViewDidLoad:
            str = @"viewDidLoad";
            break;
        case ETViewControllerEventTypeViewLoadView:
            str = @"LoadView";
            break;
        case ETViewControllerEventTypeViewDidAppear:
            str = @"viewDidAppear";
            break;
        case ETViewControllerEventTypeViewWillAppear:
            str = @"viewWillAppear";
            break;
        case ETViewControllerEventTypeViewWillDisappear:
            str = @"viewWillDisappear";
            break;
        case ETViewControllerEventTypeViewDidDisappear:
            str = @"viewDidDisappear";
            break;
        case ETViewControllerEventTypePresentViewController:
            str = @"Presented";
            break;
        case ETViewControllerEventTypeDismissViewController:
            str = @"Dismissed";
            break;
        case ETViewControllerEventTypeSetTitle:
            str = @"SetTitle";
            break;
        default:
            break;
    }
    return str;
}

@end
