////  HYFTableViewEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

typedef NS_ENUM(NSInteger, ETTableViewEventType) {
    ETTableViewEventTypeDidSelectRowAtIndexPath = 1,
};

@interface HYFTableViewEvent : HYFEventBase

- (instancetype)initWithTableView:(UITableView*)tableView
                         delegate:(id<UITableViewDelegate>)delegate
                        indexPath:(NSIndexPath*)indexPath
                             type:(ETTableViewEventType) type;

@end
