//
//  UIScrollView+KWS.m
//  KiwiSDK
//
//  Created by liyipeng on 16/6/2.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "UIScrollView+KWS.h"
#import "KiwiSDKMacro.h"
#import <objc/runtime.h>
#import <objc/NSObject.h>
#import <JRSwizzle/JRSwizzle.h>

static char const * const kEmptyListView = "EmptyListView";
static char const * const kEmptyListViewDidTouch = "EmptyListViewDidTouch";
static char const * const kEmptyListWillAppear = "EmptyListWillAppear";
static char const * const kEmptyListDidAppear = "EmptyListDidAppear";
static char const * const kEmptyListWillDisppear = "EmptyListWillDisppear";
static char const * const kEmptyListDidDisppear = "EmptyListDidDisppear";
static char const * const kEmptyListViewShouldDisplay = "EmptyListViewShouldDisplay";
static void * kTopInset  = &kTopInset;

static Class defaultEmptyListClass;

@implementation UIScrollView (KWS)

+ (void)registerClassForDefaultEmptyListView:(Class<IEmptyListView>)aClass
{
    defaultEmptyListClass = aClass;
}

#pragma mark - Private

- (UIView<IEmptyListView>*)emptyListView
{
    UIView<IEmptyListView> *view = objc_getAssociatedObject(self, kEmptyListView);
    if (!view) {
        
        if (!defaultEmptyListClass) {
            return nil;
        }
        
        view = [[defaultEmptyListClass alloc] initWithFrame:self.bounds];
        
        if ([view isKindOfClass:[UIView class]] && [view conformsToProtocol:@protocol(IEmptyListView)] ) {
            view.frame = self.bounds;
            view.userInteractionEnabled = NO;
            objc_setAssociatedObject(self, kEmptyListView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            view = nil;
        }
    }
    return view;
}

- (void)setEmptyListView:(UIView<IEmptyListView>*)view;
{
    objc_setAssociatedObject(self, kEmptyListView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setShouldDisplayBlock:(BOOL(^)())block
{
    objc_setAssociatedObject(self, kEmptyListViewShouldDisplay, block, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)())shouldDisplayBlock
{
    return objc_getAssociatedObject(self, kEmptyListViewShouldDisplay);
}

- (void)setDidTouchBlock:(void(^)())block
{
    objc_setAssociatedObject(self, kEmptyListViewDidTouch, block, OBJC_ASSOCIATION_COPY);
}

- (void(^)())didTouchBlock
{
    return objc_getAssociatedObject(self, kEmptyListViewDidTouch);
}

- (void(^)())emptyDataSetWillAppearBlock
{
    return objc_getAssociatedObject(self, kEmptyListWillAppear);
}

- (void)setEmptyDataSetWillAppear:(void(^)())block
{
    objc_setAssociatedObject(self, kEmptyListWillAppear, block, OBJC_ASSOCIATION_COPY);
}

- (void(^)())emptyDataSetDidAppearBlock
{
    return objc_getAssociatedObject(self, kEmptyListDidAppear);
}

- (void)setEmptyDataSetDidAppear:(void(^)())block
{
    objc_setAssociatedObject(self, kEmptyListDidAppear, block, OBJC_ASSOCIATION_COPY);
}

- (void(^)())emptyDataSetWillDisappearBlock
{
    return objc_getAssociatedObject(self, kEmptyListWillDisppear);
}

- (void)setEmptyDataSetWillDisAppear:(void(^)())block
{
    objc_setAssociatedObject(self, kEmptyListWillDisppear, block, OBJC_ASSOCIATION_COPY);
}

- (void(^)())emptyDataSetDidDisAppearBlock
{
    return objc_getAssociatedObject(self, kEmptyListDidDisppear);
}

- (void)setEmptyDataSetDidDisAppear:(void(^)())block
{
    objc_setAssociatedObject(self, kEmptyListDidDisppear, block, OBJC_ASSOCIATION_COPY);
}

#pragma mark - Public

- (void)setEmptyTopInset:(CGFloat)emptyTopInset
{
    objc_setAssociatedObject(self, &kTopInset, [NSString stringWithFormat:@"%@",@(emptyTopInset)], OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)emptyTopInset
{
    return [objc_getAssociatedObject(self, &kTopInset) floatValue];
}

- (void)setupEmptyListView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIScrollView swizzledItemsCount];
    });
    
    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
}

- (BOOL)setState:(EmptyListState)state
{
    [self.emptyListView setState:state];
    
    return YES;
}

- (void)setTitle:(NSString *)title forState:(EmptyListState)state
{
    [self.emptyListView setTitle:title forState:state];
}

- (void)setSubTitle:(NSString *)subTitle forState:(EmptyListState)state
{
    [self.emptyListView setSubTitle:subTitle forState:state];
}

- (void)setImage:(UIImage *)image forState:(EmptyListState)state
{
    [self.emptyListView setImage:image forState:state];
}

- (void)requireFailForInteractivePopGestureRecognizer
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    UINavigationController *navigationController = nil;
    
    for (UIViewController *child in rootViewController.childViewControllers) {
        if ([child isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController*)child;
            break;
        }
    }
    
    if (![navigationController isKindOfClass:[UINavigationController class]]) {
        KWSLogInfo(@"rootViewController is not UINavigationController");
        return;
    }
    
    if (navigationController.interactivePopGestureRecognizer) {
        
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                [gesture requireGestureRecognizerToFail:navigationController.interactivePopGestureRecognizer];
                KWSLogInfo(@"panGesture requireGestureRecognizerToFail interactivePopGestureRecognizer");
                break;
            }
        }
    }
}

#pragma mark - datasource

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return (UIView*)[self emptyListView];
}

#pragma mark - delegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    if (self.shouldDisplayBlock) {
        return self.shouldDisplayBlock();
    }
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (self.didTouchBlock) {
        self.didTouchBlock();
    }
}

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView
{
    [self adjustEmptyDataSetView];
    
    if ([self emptyDataSetWillAppearBlock]) {
        [self emptyDataSetWillAppearBlock]();
    }
}

- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView
{
    [self adjustEmptyDataSetView];
    
    if ([self emptyDataSetDidAppearBlock]) {
        [self emptyDataSetDidAppearBlock]();
    }
}

- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView
{
    if ([self emptyDataSetWillDisappearBlock]) {
        [self emptyDataSetWillDisappearBlock]();
    }
}

- (void)emptyDataSetDidDisappear:(UIScrollView *)scrollView
{
    if ([self emptyDataSetDidDisAppearBlock]) {
        [self emptyDataSetDidDisAppearBlock]();
    }
}

- (void)adjustEmptyDataSetView
{
    //Y坐标如果>0强制转为0
    UIView *v = objc_getAssociatedObject(self, "emptyDataSetView");
    
    if (v && CGRectGetMinY(v.frame) != 0) {
        CGRect frame = v.frame;
        frame.origin.y = 0;
        v.frame = frame;
    }
    
    //强制设置height等于scrollView
    CGFloat height = self.frame.size.height;
    if (self.emptyTopInset == 0) {
        if (v && CGRectGetHeight(v.frame) < height) {
            CGRect frame = v.frame;
            v.frame = frame;
        }
    }
    else {
     CGRect frame = v.frame;
        v.frame = CGRectMake(0, self.emptyTopInset, CGRectGetWidth(frame), CGRectGetHeight(frame));
    }
    
    //防止emptyDataSetView盖住其他view
    if (v && [self.subviews count] >= 2 && v != [self.subviews firstObject]) {
        [self sendSubviewToBack:v];
    }
}

#pragma mark - Swizzled

+ (void)swizzledItemsCount
{
    NSError *error;
    
    [self jr_swizzleMethod:NSSelectorFromString(@"dzn_itemsCount")
                withMethod:NSSelectorFromString(@"dzn_itemsCountSwizzled")
                     error:&error];
}

- (NSInteger)dzn_itemsCountSwizzled
{
    if ([self shouldDisplayBlock]) {
        //有block，显示不显示由block决定
        return 0;
    } else {
        return [self dzn_itemsCountSwizzled];
    }
}


@end
