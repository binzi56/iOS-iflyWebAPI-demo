////  UICollectionView+HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "UICollectionView+HYFEventTracker.h"

#import <objc/runtime.h>

#import "HYFEventTrackerCenter.h"
#import "HYFCollectionViewEvent.h"
#import "NSObject+HYFEventTracker.h"

void ET_collectionViewDidSelectRowAtIndexPath(id self, SEL _cmd, UICollectionView *collectionView, NSIndexPath *indexPath) {
    
    HYFCollectionViewEvent *event = [[HYFCollectionViewEvent alloc] initWithCollectionView:collectionView delegate:self indexPath:indexPath type:ETCollectionViewEventTypeDidSelectRowAtIndexPath];
    [[HYFEventTrackerCenter sharedInstance] addEvent:event];
    
    //调到这里肯定实现了ET_tableView:didSelectRowAtIndexPath:，去除warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:[NSObject ET_newSelFormOriginalSel:@selector(collectionView:didSelectItemAtIndexPath:)] withObject:collectionView withObject:indexPath];
#pragma clang diagnostic pop
}

@implementation UICollectionView (HYFEventTracker)

- (void)ET_setDelegate:(id<UICollectionViewDelegate>)delegate {
    if ([delegate isKindOfClass:[NSObject class]]) {
        SEL sel = @selector(collectionView:didSelectItemAtIndexPath:);
        SEL newSel = [NSObject ET_newSelFormOriginalSel:sel];
        Method originMethod = class_getInstanceMethod(delegate.class, sel);
        IMP originIMP = method_getImplementation(originMethod);
        
        IMP newIMP = (IMP)ET_collectionViewDidSelectRowAtIndexPath;
        
        if (originMethod
            && !(originIMP==newIMP)) {
            class_addMethod(delegate.class, newSel,newIMP, method_getTypeEncoding(originMethod));
            [delegate.class ET_swizzleMethod:sel newSel:newSel];
        }
    }
    [self ET_setDelegate:delegate];
}

+ (void)ET_swizzle {
    [UICollectionView ET_swizzleMethod:@selector(setDelegate:)
                                newSel:@selector(ET_setDelegate:)];
}

@end
