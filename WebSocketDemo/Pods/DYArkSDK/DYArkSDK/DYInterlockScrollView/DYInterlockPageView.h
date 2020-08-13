//
//  DYInterlockPageViewController.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/10.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYMenuModel.h"
#import "DYMenuView.h"

@protocol DYInterlockPageViewDataSource;
@protocol DYInterlockPageViewDelegate;
@interface DYInterlockPageView : UIView

@property (nonatomic, weak) id<DYInterlockPageViewDataSource> dataSource;
@property (nonatomic, weak) id<DYInterlockPageViewDelegate> delegate;

@property (nonatomic, readonly, assign) BOOL isMenuFixed;
@property (nonatomic, readonly, strong) UIView *headerView;
@property (nonatomic, readonly, strong) DYMenuView *headerMenuView;
@property (nonatomic, readonly, strong) UIScrollView *contentScrollview;
@property (nonatomic, readonly, assign) CGFloat headerMenuViewDefaultOriginY;

//菜单栏对应显示的页面，没有菜单栏时，只有一个
- (NSArray<UIView *> *)subViewList;

//- (void)setupSubViewWithSubViewIndex:(NSInteger)index;

//刷新页面
- (void)reloadData;
//对应的页面中，有scrollView滑动(用于触发菜单栏，菜单栏头部的移动)
- (void)subPageViewDidScroll:(UIScrollView *)scrollView;

- (NSInteger)selectedIndex;

@end

@protocol DYInterlockPageViewDataSource <NSObject>

@required
//菜单栏对应显示的页面，没有菜单栏时，只有一个
- (UIView *)subPageViewForInterlockPageView:(DYInterlockPageView *)interlockPageView page:(NSUInteger)page headerHeight:(CGFloat)headerHeight;

@optional
//菜单栏数据源
- (DYMenuListViewModel *)menuListViewModelForInterlockPageView:(DYInterlockPageView *)interlockPageView;
//滑动时，菜单栏是否固定在顶部
- (BOOL)isFixedMenuForInterlockPageView:(DYInterlockPageView *)interlockPageView;
//菜单栏的头部(显示在菜单栏上面，滑动的时候可能消失)
- (void)interlockPageView:(DYInterlockPageView *)interlockPageView headerView:(UIView *)headerView;
//菜单栏
- (void)interlockPageView:(DYInterlockPageView *)interlockPageView headerMenuView:(UIView *)headerMenuView;

@end

@protocol DYInterlockPageViewDelegate <NSObject>

- (void)interlockPageView:(DYInterlockPageView *)interlockPageView didChangeSelectedIndex:(NSInteger)selectedIndex;

@end
