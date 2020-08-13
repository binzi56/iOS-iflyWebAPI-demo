//
//  DYInterlockScrollView.m
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/8.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import "DYInterlockScrollView.h"
#import <Masonry.h>
#import "DYSafeAreaMacros.h"

@interface DYInterlockScrollView ()
<
DYMenuViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, strong) UIView *topHeaderBgView;                  //顶部菜单背景
@property (nonatomic, strong) DYMenuView *topHeaderMenuView;              //顶部菜单
@property (nonatomic, strong) UIScrollView *topScrollView;                      //顶部scrollView

@property (nonatomic, strong) DYMenuListViewModel *menuListViewModel;
@property (nonatomic, assign) kDYMenuListViewModelType menuViewType;
@property (nonatomic, assign) NSInteger topSelectedIndex;
@property (nonatomic, assign) NSInteger preTopSelectedIndex;

@property (nonatomic, strong) NSMutableArray<DYInterlockPageView *> *viewList;

@end

@implementation DYInterlockScrollView

- (void)topHeaderBgViewWithFrame:(CGRect)frame
{
    if (!_topHeaderBgView) {
        UIView *view = [[UIView alloc] initWithFrame:frame];
        [self addSubview:view];
        _topHeaderBgView = view;
    }
    
}

- (void)reloadData
{
    if (![self.dataSource respondsToSelector:@selector(menuListViewModel)]) {
        NSAssert(NO, @"respondsToSelector menuModelList failed");
        return;
    }
    
    _menuListViewModel = [self.dataSource menuListViewModel];
    
    if (!_menuListViewModel.list.count) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(interlockScrollViewWillReload:)]) {
        [self.delegate interlockScrollViewWillReload:self];
    }
    
    //[_topHeaderBgView removeFromSuperview];
    //_topHeaderBgView = nil;
    [_topHeaderMenuView removeFromSuperview];
    _topHeaderMenuView = nil;
    [_topScrollView removeFromSuperview];
    _topScrollView.delegate = nil;
    _topScrollView = nil;
    
    _topSelectedIndex = -1;
    _preTopSelectedIndex = -1;
    _menuViewType = _menuListViewModel.type;
    
    if (!_topHeaderBgView) {
        [self topHeaderBgViewWithFrame:(CGRect){0.f, 0.f, self.frame.size.width, _menuListViewModel.menuSize.height}];
    }
    else {
        for (UIView *subView in _topHeaderBgView.subviews) {
            //以防移除了菜单以外的VIEW
            if (subView.class == DYMenuView.class) {
                [subView removeFromSuperview];
            }
        }
    }
    
    DYMenuView *view = [DYMenuView menuViewWithListViewModel:_menuListViewModel];
    _topHeaderMenuView = view;
    view.frame = (CGRect){0.f, 0.f, _menuListViewModel.menuSize.width, _menuListViewModel.menuSize.height};
    view.delegate = self;
    [self.topHeaderBgView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topHeaderBgView).mas_offset(self.menuListViewModel.bgViewOffsetX);
        make.width.mas_offset(self.menuListViewModel.menuSize.width);
        make.bottom.mas_equalTo(self.topHeaderBgView);
        make.height.mas_offset(self.menuListViewModel.menuSize.height);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGFloat originY = CGRectGetMaxY(view.frame);
    CGFloat topScrollViewHeight = self.frame.size.height - originY;
    
    self.topScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0.f, originY, self.frame.size.width, topScrollViewHeight}];
    [self addSubview:self.topScrollView];
    [self.topScrollView setContentSize:(CGSize){self.frame.size.width * _menuListViewModel.list.count, self.topScrollView.frame.size.height}];
    self.topScrollView.pagingEnabled = YES;
    self.topScrollView.delegate = self;
    self.topScrollView.showsHorizontalScrollIndicator = NO;
    self.topScrollView.showsVerticalScrollIndicator = NO;
    
    if (![self.dataSource respondsToSelector:@selector(viewWithPage:)]) {
        NSAssert(NO, @"respondsToSelector viewWithPage: failed");
        return;
    }
    
    _viewList = [NSMutableArray array];
    [_menuListViewModel.list enumerateObjectsUsingBlock:^(DYMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DYInterlockPageView *view = [self.dataSource viewWithPage:idx];
        if (!view) {
            NSAssert(NO, @"viewWithPage should not be nil ");
            view = DYInterlockPageView.new;
        }
        CGRect frame = view.frame;
        frame.origin.x = self.frame.size.width * idx;
        frame.origin.y = 0.f;
        frame.size.width = self.frame.size.width;
        frame.size.height = self.topScrollView.frame.size.height;
        view.frame = frame;
        [self.topScrollView addSubview:view];
        
        [self.viewList addObject:view];
    }];
    
    for (DYInterlockPageView *view in _viewList) {
        [view reloadData];
    }
    
    //缓存的默认选中
    if (_menuListViewModel.selectedIndex >= 0 &&
        _menuListViewModel.selectedIndex < _menuListViewModel.list.count) {
        [_topHeaderMenuView resetWithSelectedIndex:_menuListViewModel.selectedIndex];
    }
    else {
        __block NSUInteger selectedIndex = 0;
        [_menuListViewModel.list enumerateObjectsUsingBlock:^(DYMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isDefaultSelected) {
                selectedIndex = idx;
                *stop = YES;
            }
        }];
        [_topHeaderMenuView resetWithSelectedIndex:selectedIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(interlockScrollViewDidFinishReload:)]) {
        [self.delegate interlockScrollViewDidFinishReload:self];
    }
}

- (NSArray<DYInterlockPageView *> *)pageViewList
{
    return _viewList;
}

- (void)resetWithSelectedIndex:(NSInteger)topSelectedIndex
{
    if (topSelectedIndex < 0 ||
        _menuListViewModel.list.count <= topSelectedIndex) {
        return;
    }
    [_topHeaderMenuView resetWithSelectedIndex:topSelectedIndex];
}

#pragma mark - DYMenuViewDelegate
- (void)menuView:(DYMenuView *)menuView
  didSelectIndex:(NSInteger)index
     selectedTag:(NSUInteger)selectedTag
      isAnimated:(BOOL)isAnimated
{
    if (index >= _menuListViewModel.list.count ||
        index == _topSelectedIndex) {
        return;
    }
    //NSLog(@"index:%ld", index);
    _preTopSelectedIndex = _topSelectedIndex;
    _topSelectedIndex = index;
    if (!self.topScrollView.isDragging) {
        [self.topScrollView setContentOffset:(CGPoint){self.frame.size.width * index, 0.f} animated:isAnimated];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollView:didChangeSelectedIndex:)]) {
        [self.delegate scrollView:self didChangeSelectedIndex:_topSelectedIndex];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_menuListViewModel.isSelectedBgViewFollowByScrolling) {
        [_topHeaderMenuView menuFollowByScrollingAnimationWithScrollView:scrollView];
    }
    else {
        if (!scrollView.isDragging) return;
        
        CGFloat fractionalPage = scrollView.contentOffset.x / self.frame.size.width;
        NSInteger page = lround(fractionalPage);
        if (_topSelectedIndex != page) {
            _topHeaderMenuView.selectedIndex = page;
        }
        
    }
    
//    CGFloat fractionalPage = scrollView.contentOffset.x / self.frame.size.width;
//    NSInteger page = lround(fractionalPage);
//
//    if (_menuListViewModel.isSelectedBgViewFollowByScrolling) {
//        if (_topSelectedIndex != page &&
//            scrollView.isDragging) {
//            _topHeaderMenuView.selectedIndex = page;
//        }
//
//        if (scrollView.contentOffset.x >= 0 &&
//            scrollView.contentOffset.x <= _viewList.count * self.frame.size.width) {
//
//            if (scrollView.isDragging)
//            {
//                _preTopSelectedIndex = _topSelectedIndex;
//
//                NSInteger targetPage = _topSelectedIndex;
//                CGFloat diff = scrollView.contentOffset.x - self.frame.size.width * _topSelectedIndex;
//                if (diff > 0) {
//                    targetPage += 1;
//                }
//                else {
//                    targetPage -= 1;
//                }
//
//                CGFloat progress = fabs(diff) / self.frame.size.width;
//                [_topHeaderMenuView changingIndexWithBeginIndex:_topSelectedIndex endIndex:targetPage progress:progress];
//            }
//            else {
//                NSInteger targetPage = _preTopSelectedIndex;
//
//                CGFloat diff = scrollView.contentOffset.x - self.frame.size.width * _topSelectedIndex;
//                NSInteger tabDiff = abs(targetPage - _topSelectedIndex);
//                if (tabDiff < 1) {
//                    tabDiff = 1;
//                    if (diff > 0) targetPage += 1;
//                    else targetPage -= 1;
//                }
//                CGFloat progress = fabs(diff) / (self.frame.size.width * tabDiff);
//                [_topHeaderMenuView changingIndexWithBeginIndex:_topSelectedIndex endIndex:targetPage progress:progress];
//            }
//        }
//        return;
//    }
//
//    if (!scrollView.isDragging) {
//        return;
//    }
//
//    //NSLog(@"page:%ld", page);
//    if (_topSelectedIndex != page) {
//        _topHeaderMenuView.selectedIndex = page;
//    }

}

@end
