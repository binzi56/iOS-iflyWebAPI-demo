////  HYFTableViewEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFTableViewEvent.h"

@implementation HYFTableViewEvent
{
    ETTraceObject* _delegate;
    NSIndexPath *_indexPath;
    ETTableViewEventType _type;
}

- (instancetype)initWithTableView:(UITableView*)tableView
                         delegate:(id<UITableViewDelegate>)delegate
                        indexPath:(NSIndexPath*)indexPath
                             type:(ETTableViewEventType) type {
    if (self = [super init]) {
        if (tableView) {
            [self.tracedObj setupWithObject:tableView];
        }
        
        if (delegate && [delegate conformsToProtocol:@protocol(UITableViewDelegate)] ) {
            _delegate = [[ETTraceObject alloc] initWithObject:delegate];
        }
        
        if (indexPath) {
            _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        }
        _type = type;
    }
    
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    [des appendString:[NSString stringWithFormat:@"%@ delegate:%@ %@: %@", [self.tracedObj objectDescription], [_delegate objectDescription], [self stringFromEventType], _indexPath]];
    [des appendString:self.rightBorder];
    return des;
}

- (NSString*)stringFromEventType {
    NSString *str = nil;
    switch (_type) {
        case ETTableViewEventTypeDidSelectRowAtIndexPath:
            str = @"didSelectRowAtIndexPath";
            break;
            
        default:
            break;
    }
    return str;
}

@end
