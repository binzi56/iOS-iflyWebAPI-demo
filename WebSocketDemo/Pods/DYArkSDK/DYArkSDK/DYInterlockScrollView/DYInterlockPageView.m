//
//  DYInterlockPageViewController.m
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/10.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import "DYInterlockPageView.h"
#import <Masonry.h>
#import <YYCGUtilities.h>

@interface DYInterlockPageView ()
<
UIScrollViewDelegate,
DYMenuViewDelegate
>

@property (nonatomic, strong) DYMenuListViewModel *menuListViewModel;
@property (nonatomic, assign) kDYMenuListViewModelType menuViewType;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL isMenuFixed;
@property (nonatomic, assign) CGSize menuViewSize;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *menuScrollView;
@property (nonatomic, strong) DYMenuView *headerMenuView;
@property (nonatomic, strong) UIScrollView *contentScrollview;

@property (nonatomic, assign) CGFloat headerMenuViewDefaultOriginY;

@property (nonatomic, strong) NSMutableArray<UIView *> *subPageViewList;

@end

@implementation DYInterlockPageView

- (void)reloadData
{
    if (![self.dataSource respondsToSelector:@selector(subPageViewForInterlockPageView:page:headerHeight:)]) {
        NSAssert(NO, @"respondsToSelector subPageViewForInterlockPageView:page:headerHeight: failed");
        return;
    }
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    _selectedIndex = -1;
    _menuListViewModel = nil;
    _isMenuFixed = NO;
    if ([self.dataSource respondsToSelector:@selector(menuListViewModelForInterlockPageView:)]) {
        _menuListViewModel = [self.dataSource menuListViewModelForInterlockPageView:self];
    }
    
    //滑动时，菜单栏是否固定在顶部
    if ([self.dataSource respondsToSelector:@selector(isFixedMenuForInterlockPageView:)]) {
        _isMenuFixed = [self.dataSource isFixedMenuForInterlockPageView:self];
    }
    
    //菜单栏样式
    _menuViewType = _menuListViewModel.type;
    
    //菜单栏的头部(显示在菜单栏上面，滑动的时候可能消失)
    if ([self.dataSource respondsToSelector:@selector(interlockPageView:headerView:)]) {
        if (!_headerView) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.mas_equalTo(self);
                make.top.mas_equalTo(self);
                make.width.mas_equalTo(self);
            }];
            _headerView = view;
        }
        [self.dataSource interlockPageView:self headerView:_headerView];
        
        [_headerView setNeedsLayout];
        [_headerView layoutIfNeeded];
    }
    
    if (!_headerView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        _headerView = view;
    }
    
    _headerMenuViewDefaultOriginY = _headerView.frame.size.height;
    
    //没有菜单栏
    if (!_menuListViewModel.list.count) {
        [self resetContentView];
        return;
    }
    
    _menuViewSize = _menuListViewModel.menuSize;
    
    DYMenuView *view = [DYMenuView menuViewWithListViewModel:_menuListViewModel];
    _headerMenuView = view;
    view.delegate = self;
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(self.headerMenuViewDefaultOriginY);
        make.width.mas_offset(self.menuViewSize.width);
        make.height.mas_offset(self.menuViewSize.height);
    }];
    
    if ([self.dataSource respondsToSelector:@selector(interlockPageView:headerMenuView:)]) {
        [self.dataSource interlockPageView:self headerMenuView:_headerMenuView];
    }
    
    [_headerMenuView setNeedsLayout];
    [_headerMenuView layoutIfNeeded];
    
    [self resetContentView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)resetContentView
{
    if (_menuListViewModel.list.count) {
        [self resetContentScrollView];
        return;
    }
    
    for (UIView *view in _contentScrollview.subviews) {
        [view removeFromSuperview];
    }
    [_contentScrollview removeFromSuperview];
    _contentScrollview.delegate = nil;
    _contentScrollview = nil;
    
    if (![self.dataSource respondsToSelector:@selector(subPageViewForInterlockPageView:page:headerHeight:)]) {
        NSAssert(NO, @"subPageViewForInterlockPageView:page:headerHeight: failed");
        return;
    }
    
    _subPageViewList = [NSMutableArray array];
    UIView *view = [self.dataSource subPageViewForInterlockPageView:self page:0 headerHeight:_headerMenuViewDefaultOriginY + _menuViewSize.height];
    if (!view) {
        NSAssert(NO, @"subPageViewForInterlockPageView should not be nil");
        view = UIView.new;
    }
    
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
    }];
    
    [_subPageViewList addObject:view];
    
    if (_headerView && _headerView.superview == self) {
        [self bringSubviewToFront:_headerView];
    }
    
    self.selectedIndex = 0;
}

- (void)resetContentScrollView
{    
    CGFloat originY = 0.f;
    //CGFloat fixedHeaderHeight = _isMenuFixed ? _menuViewSize.height : 0.f;
    
    //_contentScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, originY, kScreenWidth, self.frame.size.height - fixedHeaderHeight)];
    _contentScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, originY, kScreenWidth, self.frame.size.height)];
    _contentScrollview.pagingEnabled = YES;
    _contentScrollview.bounces = NO;
    _contentScrollview.contentSize = CGSizeMake(self.frame.size.width * _menuListViewModel.list.count, _contentScrollview.frame.size.height);
    _contentScrollview.showsHorizontalScrollIndicator = NO;
    _contentScrollview.delegate = self;

    if (_headerView && _headerView.superview) {
        [self insertSubview:_contentScrollview belowSubview:_headerView];
    }
    else if (_headerMenuView) {
        [self insertSubview:_contentScrollview belowSubview:_headerMenuView];
    }
    else {
        [self addSubview:_contentScrollview];
    }
    
    [_contentScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self);
        make.top.mas_offset(originY);
        make.height.mas_offset(self.contentScrollview.frame.size.height);
    }];
    
    for (UIView *view in _contentScrollview.subviews) {
        [view removeFromSuperview];
    }
    
    if (![self.dataSource respondsToSelector:@selector(subPageViewForInterlockPageView:page:headerHeight:)]) {
        NSAssert(NO, @"subPageViewForInterlockPageView:page:headerHeight: failed");
        return;
    }
    
    __block NSUInteger selectedIndex = 0;
    __block BOOL isSetIndex = NO;
    //缓存的默认选中
    if (_menuListViewModel.selectedIndex >= 0 &&
        _menuListViewModel.selectedIndex < _menuListViewModel.list.count) {
        selectedIndex = _menuListViewModel.selectedIndex;
        isSetIndex = YES;        
    }
        
    _subPageViewList = [NSMutableArray array];
    [_menuListViewModel.list enumerateObjectsUsingBlock:^(DYMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [self.dataSource subPageViewForInterlockPageView:self page:idx headerHeight:_headerMenuViewDefaultOriginY + _menuViewSize.height];
        if (!view) {
            NSAssert(NO, @"subPageViewForInterlockPageView should not be nil");
            view = UIView.new;
        }
//        [self.contentScrollview addSubview:view];
//        [view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.and.height.mas_equalTo(self.contentScrollview);
//            make.top.mas_equalTo(self.contentScrollview);
//            make.left.mas_equalTo(self.contentScrollview).mas_offset(self.contentScrollview.frame.size.width * idx);
//        }];
        
        [self.subPageViewList addObject:view];
        
        [self.contentScrollview addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(self.contentScrollview);
            make.top.mas_equalTo(self.contentScrollview);
            make.left.mas_equalTo(self.contentScrollview).mas_offset(self.contentScrollview.frame.size.width * idx);
        }];
        
        if (!isSetIndex && obj.isDefaultSelected) {
            selectedIndex = idx;
            isSetIndex == YES;
        }
    }];
    
    [_headerMenuView resetWithSelectedIndex:selectedIndex];
}

- (void)subPageViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

#pragma mark -
- (NSArray<UIView *> *)subViewList
{
    return _subPageViewList;
}

//- (void)setupSubViewWithSubViewIndex:(NSInteger)index
//{
//    if (index < 0 || index >= _subPageViewList.count) return;
//    UIView *view = _subPageViewList[index];
//    if (view.superview) return;
//    
//    [self.contentScrollview addSubview:view];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.and.height.mas_equalTo(self.contentScrollview);
//        make.top.mas_equalTo(self.contentScrollview);
//        make.left.mas_equalTo(self.contentScrollview).mas_offset(self.contentScrollview.frame.size.width * index);
//    }];
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollview)
    {
        //stop Vertical Scrolling
        scrollView.contentOffset = (CGPoint){scrollView.contentOffset.x, 0.f};
        
        // 内容区块滑动结束调整标题栏居中
        if (scrollView.isDragging) {
            CGFloat fractionalPage = scrollView.contentOffset.x / self.frame.size.width;
            NSInteger page = lround(fractionalPage);
            if (_headerMenuView.selectedIndex != page) {
//                _headerMenuView.selectedIndex = page;
                [_headerMenuView setSelectedIndexByScrolling:page];
            }
        }
        return;
    }
    
    //没有自定义的前置模块并且没有菜单栏，不需要移动菜单栏和菜单栏头部的逻辑
    if (_headerMenuViewDefaultOriginY <= 0 && !_menuListViewModel.list.count) return;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat originY =  _headerMenuViewDefaultOriginY + _menuViewSize.height;    
    offsetY += originY;
    //NSLog(@"offsetY:%f", offsetY);
    if (offsetY > 0)
    {
        CGRect fixedFrame = CGRectZero;
        CGFloat fixedY = _isMenuFixed ? _headerMenuView.frame.origin.y : CGRectGetMaxY(_headerMenuView.frame);
        
        fixedY = _headerMenuViewDefaultOriginY;
        fixedY += _isMenuFixed ? 0.f : _headerMenuView.frame.size.height;
        if (offsetY > fixedY)
        {

            offsetY = - (fixedY - offsetY);
            
            fixedFrame = _headerView.frame;
            fixedFrame.origin.y = _isMenuFixed ? (- _headerView.frame.size.height) : (- _headerView.frame.size.height - _headerMenuView.frame.size.height);
            _headerView.frame = fixedFrame;
            
            fixedFrame = _headerMenuView.frame;
            fixedFrame.origin.y = _isMenuFixed ? 0.f : - _headerMenuView.frame.size.height;
            _headerMenuView.frame = fixedFrame;
            
            return;
        }

        fixedFrame = _headerView.frame;
        fixedFrame.origin.y = -offsetY;
        _headerView.frame = fixedFrame;
        
        fixedFrame = _headerMenuView.frame;
        fixedFrame.origin.y = _headerMenuViewDefaultOriginY - offsetY;
        _headerMenuView.frame = fixedFrame;

    }
    else if (offsetY < 0)
    {
        CGRect fixedFrame = CGRectZero;
        CGFloat fixedY = _headerMenuView ? _headerMenuView.frame.origin.y : _headerMenuViewDefaultOriginY;
        CGFloat marginY = _headerMenuViewDefaultOriginY;

        if (fixedY - offsetY > marginY)
        {

            offsetY = - (fixedY - offsetY - marginY);
            
            fixedFrame = _headerView.frame;
            fixedFrame.origin.y = 0.f;
            _headerView.frame = fixedFrame;

            fixedFrame = _headerMenuView.frame;
            fixedFrame.origin.y = marginY;
            _headerMenuView.frame = fixedFrame;
            
            return;
        }
        
        fixedFrame = _headerView.frame;
        fixedFrame.origin.y = -offsetY;
        _headerView.frame = fixedFrame;
        
        fixedFrame = _headerMenuView.frame;
        fixedFrame.origin.y = _headerMenuViewDefaultOriginY - offsetY;
        _headerMenuView.frame = fixedFrame;
        
    }
}

#pragma mark - DYmenuViewDelegate
- (void)menuView:(DYMenuView *)menuView
  didSelectIndex:(NSInteger)index
     selectedTag:(NSUInteger)selectedTag
      isAnimated:(BOOL)isAnimated
{
    if (index >= _menuListViewModel.list.count ||
        (index == _selectedIndex && !_menuListViewModel.allowReselectIndex)) {
        return;
    }
    //NSLog(@"DYInterlockPage index:%ld", index);
    _selectedIndex = index;
    
    if (!self.contentScrollview.isDragging) {
        [self.contentScrollview setContentOffset:(CGPoint){self.contentScrollview.frame.size.width * index, 0.f} animated:isAnimated];
    }
    
    if ([self.delegate respondsToSelector:@selector(interlockPageView:didChangeSelectedIndex:)]) {
        [self.delegate interlockPageView:self didChangeSelectedIndex:_selectedIndex];
    }
}

@end
