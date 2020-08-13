//
//  UIScrollView+KWS.h
//  KiwiSDK
//
//  Created by liyipeng on 16/6/2.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

typedef enum {
    EmptyListEmpty = 0,
    EmptyListLoading,
    EmptyListNetworkBroken,
    EmptyListFail,
    EmptyListStateCount
} EmptyListState;

@protocol IEmptyListView <NSObject>

@required

@property(nonatomic, assign) UIOffset contentPositionAdjustment;
@property(nonatomic, assign) EmptyListState state;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;


- (void)setImage:(UIImage *)image forState:(EmptyListState)state;
- (void)setTitle:(NSString *)title forState:(EmptyListState)state;
- (void)setSubTitle:(NSString *)subTitle forState:(EmptyListState)state;

@end

@interface UIScrollView (KWS) <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property(nonatomic, assign) CGFloat emptyTopInset;

/**
 *  @brief 设置默认的EmptyListView
 *  @param aClass UIView<IEmptyListView>
 */
+ (void)registerClassForDefaultEmptyListView:(Class<IEmptyListView>)aClass;

- (void)setupEmptyListView;

- (UIView<IEmptyListView>*)emptyListView;

- (void)setEmptyListView:(UIView<IEmptyListView>*)view;

- (void)setDidTouchBlock:(void(^)())block;

- (void)setShouldDisplayBlock:(BOOL(^)())block;

- (void)setEmptyDataSetWillAppear:(void(^)())block;

- (void)setEmptyDataSetDidAppear:(void(^)())block;

- (void)setEmptyDataSetWillDisAppear:(void(^)())block;

- (void)setEmptyDataSetDidDisAppear:(void(^)())block;

/**
 *  @brief  更新列表背景状态。
 */
- (BOOL)setState:(EmptyListState)state;

- (void)setTitle:(NSString *)title forState:(EmptyListState)state;

- (void)setSubTitle:(NSString *)subTitle forState:(EmptyListState)state;

- (void)setImage:(UIImage *)image forState:(EmptyListState)state;

/**
 设置和interactivePopGestureRecognizer的关系，防止可以横向滚动的scrollview影响滑动返回;
 */
- (void)requireFailForInteractivePopGestureRecognizer;

@end
