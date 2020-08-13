////  UITableView+HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UITableView+HYFEventTracker.h"

#import <objc/runtime.h>

#import "HYFEventTrackerCenter.h"
#import "HYFTableViewEvent.h"
#import "NSObject+HYFEventTracker.h"

void ET_tableViewDidSelectRowAtIndexPath(id self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath) {
    
    HYFTableViewEvent *event = [[HYFTableViewEvent alloc] initWithTableView:tableView delegate:self indexPath:indexPath type:ETTableViewEventTypeDidSelectRowAtIndexPath];
    [[HYFEventTrackerCenter sharedInstance] addEvent:event];
    
    //调到这里肯定实现了ET_tableView:didSelectRowAtIndexPath:，去除warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:[NSObject ET_newSelFormOriginalSel:@selector(tableView:didSelectRowAtIndexPath:)] withObject:tableView withObject:indexPath];
#pragma clang diagnostic pop
}

@implementation UITableView (HYFEventTracker)

- (void)ET_setDelegate:(id<UITableViewDelegate>)delegate {
    if ([delegate isKindOfClass:[NSObject class]]) {
        SEL sel = @selector(tableView:didSelectRowAtIndexPath:);
        SEL newSel = [NSObject ET_newSelFormOriginalSel:sel];
        Method originMethod = class_getInstanceMethod(delegate.class, sel);
        IMP originIMP = method_getImplementation(originMethod);
        
        IMP newIMP = (IMP)ET_tableViewDidSelectRowAtIndexPath;
        
        if (originMethod
            && !(originIMP==newIMP)) {
            class_addMethod(delegate.class, newSel, newIMP, method_getTypeEncoding(originMethod));
            [delegate.class ET_swizzleMethod:sel newSel:newSel];
        }
    }
    [self ET_setDelegate:delegate];
}

+ (void)ET_swizzle {
    [UITableView ET_swizzleMethod:@selector(setDelegate:)
                           newSel:@selector(ET_setDelegate:)];
}

@end
