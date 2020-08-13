//
//  DYInterlockScrollView.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/8.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYMenuListViewModel.h"
#import "DYInterlockPageView.h"

@protocol DYInterlockScrollViewDataSource;
@protocol DYInterlockScrollViewDelegate;
@interface DYInterlockScrollView : UIView

@property (nonatomic, weak) id<DYInterlockScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<DYInterlockScrollViewDelegate> delegate;

@property (nonatomic, readonly, strong) UIView *topHeaderBgView;                //顶部菜单背景

@property (nonatomic, readonly, assign) NSInteger topSelectedIndex;

- (void)topHeaderBgViewWithFrame:(CGRect)frame;
//刷新页面
- (void)reloadData;
//菜单栏对应显示的页面
- (NSArray<DYInterlockPageView *> *)pageViewList;

- (void)resetWithSelectedIndex:(NSInteger)topSelectedIndex;

@end

@protocol DYInterlockScrollViewDataSource <NSObject>
@required
//主菜单数据源
- (DYMenuListViewModel *)menuListViewModel;
//主菜单对应的view
- (DYInterlockPageView *)viewWithPage:(NSUInteger)page;

@end

@protocol DYInterlockScrollViewDelegate <NSObject>

- (void)scrollView:(DYInterlockScrollView *)scrollView didChangeSelectedIndex:(NSInteger)selectedIndex;

- (void)interlockScrollViewWillReload:(DYInterlockScrollView *)scrollView;

- (void)interlockScrollViewDidFinishReload:(DYInterlockScrollView *)scrollView;

@end
