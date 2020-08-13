//
//  DYMenuView.m
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/9.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import "DYMenuView.h"
#import <UIView+BlocksKit.h>
#import <UIImage+YYAdd.h>
#import <Masonry.h>
#import <KiwiSDKMacro.h>
#import "POP.h"

static NSUInteger const kDYMenuListViewModelLabelTag = 10000;

@interface DYMenuView ()

@property (nonatomic, strong) UIColor *unselectTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, assign) CGFloat underLineSelectedBackgroundWidth;
@property (nonatomic, strong) UIFont *unselectTextFont;
@property (nonatomic, strong) UIFont *selectedTextFont;

@property (nonatomic, assign) kDYMenuListViewModelType type;
@property (nonatomic, assign) kDYMenuListViewModelAlignment viewAlignment;
@property (nonatomic, assign) kDYMenuListViewModelOrientationType orientationType;

@property (nonatomic, strong) NSArray<DYMenuModel *> *list;
@property (nonatomic, strong) NSMutableArray<UIView *> *menuViewList;
@property (nonatomic, strong) UIScrollView *infinityScrollView;

@property (nonatomic, strong) UIImageView *selectedBgView;

@property (nonatomic, assign) CGFloat menuViewMargin;
@property (nonatomic, assign) BOOL disableAnimated;

@property (nonatomic, assign) BOOL isTensileElasticityForUnderLineType;
@property (nonatomic, assign) CGFloat progressForStyleTensileElasticity;

@property (nonatomic, assign) BOOL isSelectedBgViewFollowByScrolling;
@property (nonatomic, strong) UIColor *followByScrollingTextColor;
@property (nonatomic, assign) CGFloat followByScrollingTextMinAlpha;

@property (nonatomic, assign) NSInteger preSelectedIndex;

@property (nonatomic, assign) kDYMenuViewSelectedIndexChangedType selectedIndexChangedType;
@property (nonatomic, assign) BOOL allowReselectIndex;

@end

@implementation DYMenuView

+ (instancetype)menuViewWithListViewModel:(DYMenuListViewModel *)viewModel
{
    DYMenuView *view = [[self.class alloc] init];
    view.bounds = (CGRect){0.f, 0.f, viewModel.menuSize.width, viewModel.menuSize.height};
    view.type = viewModel.type;
    //view.orientationType = viewModel.orientationType;
    view.unselectTextColor = viewModel.unselectTextColor ?: UIColor.lightGrayColor;
    view.selectedTextColor = viewModel.selectedTextColor ?: UIColor.blackColor;
    view.selectedBackgroundColor = viewModel.selectedBackgroundColor ?: UIColor.whiteColor;
    view.unselectTextFont = viewModel.unselectTextFont ?: view.defaultTextFont;
    view.selectedTextFont = viewModel.selectedTextFont ?: view.defaultTextFont;
    view.selectedIndex = viewModel.selectedIndex;
    view.selectedBackgroundImage = viewModel.selectedBackgroundImage ?: nil;
    view.underLineSelectedBackgroundWidth = viewModel.underLineSelectedBackgroundWidth;
    view.selectedBackgroundOffsetY = viewModel.selectedBackgroundOffsetY;
    view.list = viewModel.list.copy;
    view.menuViewMargin = viewModel.menuViewMargin > 0 ? viewModel.menuViewMargin : 5.f;
    view.backgroundColor = viewModel.bgColor ?: UIColor.whiteColor;
    view.isInfinityMode = viewModel.isInfinityMode;
    view.viewAlignment = viewModel.viewAlignment;
    view.isTensileElasticityForUnderLineType = viewModel.isTensileElasticityForUnderLineType;
    
    view.isSelectedBgViewFollowByScrolling = viewModel.isSelectedBgViewFollowByScrolling;
    view.followByScrollingTextColor = viewModel.followByScrollingTextColor;
    view.followByScrollingTextMinAlpha = viewModel.followByScrollingTextMinAlpha;
    
    view.customAnimationBlock = viewModel.customAnimationBlock;
    view.customTitleBlock = viewModel.customTitleBlock;
    
    view.allowReselectIndex = viewModel.allowReselectIndex;
    
    [view reset];
    return view;
}

- (void)reset
{
    if (!_list.count) return;
    
    [self refreshViews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat pWidth = (width - _menuViewMargin) / _list.count - _menuViewMargin;
    CGFloat pHeight = (height - _menuViewMargin) / _list.count - _menuViewMargin;
    if (!self.selectedBgView)
    {
        self.selectedBgView = [[UIImageView alloc] init];
    }
    if (kDYMenuListViewModelTypeDefault == _type)
    {
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            self.selectedBgView.frame = (CGRect){0.f, 0.f, width, pHeight};
//        }
//        else
        {
            self.selectedBgView.frame = (CGRect){_menuViewMargin, _menuViewMargin, pWidth, height - _menuViewMargin * 2};
        }
        UIImage *image = [[UIImage imageWithColor:_selectedBackgroundColor size:self.selectedBgView.frame.size] imageByRoundCornerRadius:5.f];
        self.selectedBgView.image = image;
    }
    else if (kDYMenuListViewModelTypeUnderLine == _type)
    {
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            CGFloat fixedX = 0.f;
//            CGFloat fixedWidth = width;
//            if (_underLineSelectedBackgroundWidth > 0 &&
//                width > _underLineSelectedBackgroundWidth)
//            {
//                fixedX = (width - _underLineSelectedBackgroundWidth) * 0.5f;
//                fixedWidth = _underLineSelectedBackgroundWidth;
//            }
//            //self.selectedBgView.frame = (CGRect){_menuViewMargin, pHeight - 3.f, width, 3.f};
//            self.selectedBgView.frame = (CGRect){_menuViewMargin + fixedX, pHeight - 3.f + _selectedBackgroundOffsetY, fixedWidth, 3.f};
//        }
//        else
        {
            CGFloat fixedX = 0.f;
            CGFloat fixedWidth = pWidth;
            if (_underLineSelectedBackgroundWidth > 0 &&
                pWidth > _underLineSelectedBackgroundWidth)
            {
                fixedX = (pWidth - _underLineSelectedBackgroundWidth) * 0.5f;
                fixedWidth = _underLineSelectedBackgroundWidth;
            }
            //self.selectedBgView = [[UIImageView alloc] initWithFrame:(CGRect){_menuViewMargin, _totalHeight - 3.f, pWidth, 3.f}];
            CGFloat selectedBgViewHeight = 4.f;
            self.selectedBgView.frame = (CGRect){_menuViewMargin + fixedX, height - selectedBgViewHeight + _selectedBackgroundOffsetY, fixedWidth, selectedBgViewHeight};
            self.selectedBgView.layer.cornerRadius = self.selectedBgView.frame.size.height * 0.5f;
            self.selectedBgView.layer.masksToBounds = YES;
        }
        self.selectedBgView.backgroundColor = _selectedBackgroundColor;
        self.selectedBgView.image = nil;
    }
    else if (kDYMenuListViewModelTypeBackgroundImage == _type)
    {
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            self.selectedBgView.frame = (CGRect){_menuViewMargin, _menuViewMargin + _selectedBackgroundOffsetY, width, pHeight - _menuViewMargin * 2};
//        }
//        else
        {
            //self.selectedBgView = [[UIImageView alloc] initWithFrame:(CGRect){_menuViewMargin, margin + _selectedBackgroundOffsetY, pWidth, _totalHeight - margin * 2}];
            self.selectedBgView.frame = (CGRect){_menuViewMargin, _menuViewMargin + _selectedBackgroundOffsetY, pWidth, height - _menuViewMargin * 2};
        }
        self.selectedBgView.image = _selectedBackgroundImage;
    }
    else if (kDYMenuListViewModelTypeHighlight == _type)
    {
        self.selectedBgView.hidden = YES;
    }
    
    if (self.selectedBgView && !self.selectedBgView.hidden)
    {
        if (_isInfinityMode) {
            [self.infinityScrollView insertSubview:self.selectedBgView atIndex:0];
        }
        else {
            [self insertSubview:self.selectedBgView atIndex:0];
        }
    }
    
    [_menuViewList enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        
        if (self.isInfinityMode) {
            
        }
        else {
            if (kDYMenuListViewModelOrientationTypeLandscape == self.orientationType)
            {
                view.frame = (CGRect){0.f, (self.menuViewMargin + pHeight) * idx + self.menuViewMargin, width, pHeight};
            }
            else
            {
                view.frame = (CGRect){(self.menuViewMargin + pWidth) * idx + self.menuViewMargin, 0.f, pWidth, height};
            }
        }
        UILabel *label = [view viewWithTag:kDYMenuListViewModelLabelTag];
        label.font = self.unselectTextFont ?: self.defaultTextFont;
    }];
    
    [self handleIndexChangedWithAnimated:NO];
}

#pragma mark - selectedIndex changed
- (void)reloadViewsWithSelectedIndexChanged:(BOOL)isChanged
{
    if (!_menuViewList.count) return;
    
    if (!self.isSelectedBgViewFollowByScrolling) {
        [_menuViewList enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *label = [view viewWithTag:kDYMenuListViewModelLabelTag];
            if (self.isSelectedBgViewFollowByScrolling) {
                label.textColor = (self.selectedIndex == idx) ? self.followByScrollingTextColor : [self.followByScrollingTextColor colorWithAlphaComponent:_followByScrollingTextMinAlpha];
            }
            else {
                label.textColor = (self.selectedIndex == idx) ? self.selectedTextColor : self.unselectTextColor;
            }
            label.font = (self.selectedIndex == idx) ? (self.selectedTextFont ?: self.defaultTextFont) : (self.unselectTextFont ?: self.defaultTextFont);
            
            DYMenuModel *model = self.list[idx];
            if (self.customTitleBlock) {
                self.customTitleBlock(label, model, self.selectedIndex == idx);
            }
            else {
                label.text = model.text;
            }
        }];
        
        //可能有变化比较大的text
        if (self.customTitleBlock) {
            [self refreshViews];
        }
    }
    
    //if (!isChanged) return;
    
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectIndex:selectedTag:isAnimated:)])
    {
        DYMenuModel *model = self.list[self.selectedIndex];
        [self.delegate menuView:self
                 didSelectIndex:_selectedIndex
                    selectedTag:model.tag
                     isAnimated:isChanged];
    }
    
    [self handleIndexChangedWithAnimated:isChanged];
}

- (void)handleIndexChangedWithAnimated:(BOOL)animated
{
    if (_isInfinityMode) {
        if (!animated) {
            [self handleInfinitySelectedIndexChangedWithAnimated:animated];
        }
        else if (_disableAnimated) {
            [self handleInfinitySelectedIndexChangedWithAnimated:NO];
        }
        else if (!_isSelectedBgViewFollowByScrolling &&
                 kDYMenuListViewModelTypeUnderLine == _type &&
                 _isTensileElasticityForUnderLineType) {
            [self handleInfinitySelectedIndexChangedWithAnimated:YES];
            return;
        }
        else {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 [self handleInfinitySelectedIndexChangedWithAnimated:YES];
                             }];
        }
        return;
    }
    
    if (_disableAnimated) {
        [self handleSelectedIndexChanged];
    }
    else if (kDYMenuListViewModelTypeUnderLine == _type && _isTensileElasticityForUnderLineType) {
        [self handleSelectedIndexChanged];
        return;
    }
    else {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self handleSelectedIndexChanged];
                         }];
    }
}

- (void)handleInfinitySelectedIndexChangedWithAnimated:(BOOL)animated
{
    if (self.selectedIndex < 0) return;
    
    UIView *view = _menuViewList[_selectedIndex];
    
    //无限模式，而且占满，需要居中逻辑
    if (_infinityScrollView.isScrollEnabled) {
        //居中逻辑
        CGFloat deltaX = view.center.x - self.frame.size.width * 0.5f;
        //左边界
        if (deltaX < 0) deltaX = 0;
        
        CGFloat maxDeltaX = _infinityScrollView.contentSize.width - self.frame.size.width;
        //右边界
        if (deltaX > maxDeltaX) deltaX = maxDeltaX;
        
        [_infinityScrollView setContentOffset:CGPointMake(deltaX, 0) animated:animated && !_disableAnimated];
    }
    
    //selectedBgView的位置动画
    if (kDYMenuListViewModelTypeDefault == _type ||
        kDYMenuListViewModelTypeBackgroundImage == _type)
    {
        CGRect frame = self.selectedBgView.frame;
        frame.origin.x = view.frame.origin.x;
        frame.size.width = view.frame.size.width;
        if (!animated) {
            self.selectedBgView.frame = frame;
        }
        else if (_customAnimationBlock) {
            _customAnimationBlock(view, self.selectedBgView, frame);
        }
        else {
            self.selectedBgView.frame = frame;
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeUnderLine == _type)
    {
        CGFloat fixedX = 0.f;
        CGFloat fixedWidth = view.frame.size.width;
        if (_underLineSelectedBackgroundWidth > 0 &&
            _underLineSelectedBackgroundWidth < view.frame.size.width) {
            fixedX = (view.frame.size.width - _underLineSelectedBackgroundWidth) * 0.5f;
            fixedWidth = _underLineSelectedBackgroundWidth;
        }
        
        CGRect frame = self.selectedBgView.frame;
        frame.origin.x = view.frame.origin.x + fixedX;
        frame.size.width = fixedWidth;
        if (!animated) {
            self.selectedBgView.frame = frame;
        }
        else if (_customAnimationBlock) {
            _customAnimationBlock(view, self.selectedBgView, frame);
        }
        else if (_isSelectedBgViewFollowByScrolling) {
            
        }
        else if (_isTensileElasticityForUnderLineType) {
            [self animationTensileElasticityForUnderLineTypeWithTargetOriginX:view.frame.origin.x + fixedX
                                                                  targetWidth:fixedWidth];
        }
        else {
            self.selectedBgView.frame = frame;
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeHighlight == _type)
    {
        self.selectedBgView.hidden = YES;
        if (!animated) {
            
        }
        else if (_customAnimationBlock) {
            _customAnimationBlock(view, nil, CGRectZero);
        }
    }
}

- (void)handleSelectedIndexChanged
{
    if (self.selectedIndex < 0) return;
    
    UIView *view = self.menuViewList[self.selectedIndex];
    UILabel *label = [view viewWithTag:kDYMenuListViewModelLabelTag];
    if (self.isSelectedBgViewFollowByScrolling) {
        label.textColor = self.followByScrollingTextColor;
    }
    else {
        label.textColor = self.selectedTextColor;
    }
    label.font = _selectedTextFont ?: self.defaultTextFont;
    
    CGFloat width = self.frame.size.width;
    //CGFloat height = self.frame.size.height;
    CGRect frame = self.selectedBgView.frame;
    if (kDYMenuListViewModelTypeDefault == _type)
    {
        //CGFloat pWidth = (_totalWidth - menuViewMargin) / _list.count - menuViewMargin;
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            CGFloat pHeight = (height - _menuViewMargin) / _list.count - _menuViewMargin;
//            frame.origin.y = (_menuViewMargin + pHeight) * _selectedIndex + _menuViewMargin;
//        }
//        else
        {
            CGFloat pWidth = (width - _menuViewMargin) / _list.count - _menuViewMargin;
            frame.origin.x = (_menuViewMargin + pWidth) * _selectedIndex + _menuViewMargin;
        }
        
        if (_customAnimationBlock) {
            _customAnimationBlock(label, self.selectedBgView, frame);
        }
        else {
            self.selectedBgView.frame = frame;
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeUnderLine == _type)
    {
        CGRect viewFrame = view.frame;
        //NSLog(@"%@", VTS(frame));
        
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            CGFloat pHeight = (height - _menuViewMargin) / _list.count - _menuViewMargin;
//            frame.origin.y = (_menuViewMargin + pHeight) * (_selectedIndex + 1) - CGRectGetMaxY(viewFrame) + _menuViewMargin + 3.f;
////            frame.origin.x = viewFrame.origin.x;
////            frame.size.width = viewFrame.size.width;
//            CGFloat fixedX = 0.f;
//            CGFloat fixedWidth = viewFrame.size.width;
//            if (_underLineSelectedBackgroundWidth > 0 &&
//                viewFrame.size.width > _underLineSelectedBackgroundWidth)
//            {
//                fixedX = (viewFrame.size.width - _underLineSelectedBackgroundWidth) * 0.5f;
//                fixedWidth = _underLineSelectedBackgroundWidth;
//            }
//            frame.origin.x = viewFrame.origin.x + fixedX;
//            frame.size.width = fixedWidth;
//
//            self.selectedBgView.frame = frame;
//        }
//        else
        {
            //CGFloat pWidth = (_totalWidth - menuViewMargin) / _list.count - menuViewMargin;
            CGFloat pWidth = (width - _menuViewMargin) / _list.count - _menuViewMargin;
            frame.origin.x = (_menuViewMargin + pWidth) * _selectedIndex + _menuViewMargin;
            frame.size.width = viewFrame.size.width + _menuViewMargin * 2;
            if (_underLineSelectedBackgroundWidth > 0 &&
                viewFrame.size.width > _underLineSelectedBackgroundWidth) {
                frame.origin.x += (viewFrame.size.width - _underLineSelectedBackgroundWidth) * 0.5f;
                frame.size.width = _underLineSelectedBackgroundWidth;
            }
            
            if (_customAnimationBlock) {
                _customAnimationBlock(label, self.selectedBgView, frame);
            }
            else if (_isTensileElasticityForUnderLineType) {
                [self animationTensileElasticityForUnderLineTypeWithTargetOriginX:frame.origin.x
                                                                      targetWidth:frame.size.width];
            }
            else {
                self.selectedBgView.frame = frame;
            }
            
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeBackgroundImage == _type)
    {
//        if (kDYMenuListViewModelOrientationTypeLandscape == _orientationType)
//        {
//            CGFloat pHeight = (height - _menuViewMargin) / _list.count - _menuViewMargin;
//            frame.origin.y = (_menuViewMargin + pHeight) * _selectedIndex + _menuViewMargin;
//        }
//        else
        {
            //CGFloat pWidth = (_totalWidth - menuViewMargin) / _list.count - menuViewMargin;
            CGFloat pWidth = (width - _menuViewMargin) / _list.count - _menuViewMargin;
            frame.origin.x = (_menuViewMargin + pWidth) * _selectedIndex + _menuViewMargin;
        }
        if (_customAnimationBlock) {
            _customAnimationBlock(label, self.selectedBgView, frame);
        }
        else {
            self.selectedBgView.frame = frame;
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeHighlight == _type)
    {
        self.selectedBgView.hidden = YES;
        if (_customAnimationBlock) {
            _customAnimationBlock(label, nil, CGRectZero);
        }
    }
}

- (void)refreshViews
{
    if (!_list.count) return;
    
    [_menuViewList enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _menuViewList = [NSMutableArray array];
    
    if (_isInfinityMode) {
        [self setupInfinityViews];
        return;
    }
    
    NSUInteger count = _list.count;
    CGFloat pWidth = (self.frame.size.width - _menuViewMargin) / count - _menuViewMargin;
    CGFloat pHeight = self.frame.size.height;
    
    [_list enumerateObjectsUsingBlock:^(DYMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat originX = (self.menuViewMargin + pWidth) * idx + self.menuViewMargin;
        UIView *view = UIView.new;
        view.frame = (CGRect){originX, 0.f, pWidth, pHeight};
        
        UILabel *label = UILabel.new;
        label.frame = (CGRect){0.f, 0.f, pWidth, pHeight};
        label.tag = kDYMenuListViewModelLabelTag;
        label.backgroundColor = [UIColor clearColor];
        //label.backgroundColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentCenter;
        if (self.isSelectedBgViewFollowByScrolling) {
            label.textColor = (self.selectedIndex == idx) ? self.followByScrollingTextColor : [self.followByScrollingTextColor colorWithAlphaComponent:_followByScrollingTextMinAlpha];
        }
        else {
            label.textColor = self.selectedIndex == idx ? self.selectedTextColor : self.unselectTextColor;
        }
        label.font = self.selectedIndex == idx ? self.selectedTextFont : self.unselectTextFont;
        if (self.customTitleBlock) {
            self.customTitleBlock(label, obj, self.selectedIndex == idx);
        }
        else {
            label.text = obj.text;
        }
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(view);
        }];
        
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(pWidth);
            make.height.mas_offset(pHeight);
            make.left.mas_offset(originX);
            make.top.mas_offset(0.f);
        }];
        
        @weakify(self);
        [view bk_whenTapped:^{
            @strongify(self)
            self.selectedIndex = idx;
        }];
        
        [self.menuViewList addObject:view];
    }];
    
}

- (void)setupInfinityScrollView
{
    [_infinityScrollView removeFromSuperview];
    _infinityScrollView.delegate = nil;
    _infinityScrollView = nil;
    
    if (!_isInfinityMode) return;
    
    _infinityScrollView = [[UIScrollView alloc] init];
    _infinityScrollView.showsHorizontalScrollIndicator = NO;
    _infinityScrollView.bounces = NO;
    [self addSubview:_infinityScrollView];
    [_infinityScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(self);
    }];
}

- (void)setupInfinityViews
{
    if (!_list.count) return;
    
    if (@available(iOS 11.0, *)) {
        self.infinityScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    __block CGFloat preOriginX = 0.f;
    __block CGFloat pWidth = 0.f;
    CGFloat pHeight = self.frame.size.height;
    
    [_list enumerateObjectsUsingBlock:^(DYMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        preOriginX += self.menuViewMargin;
        UIView *view = UIView.new;
        //view.frame = (CGRect){originX, 0.f, pWidth, pHeight};
        
        UILabel *label = UILabel.new;
        //label.frame = (CGRect){0.f, 0.f, pWidth, pHeight};
        label.tag = kDYMenuListViewModelLabelTag;
        label.backgroundColor = [UIColor clearColor];
        //label.backgroundColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentCenter;
        if (self.isSelectedBgViewFollowByScrolling) {
            label.textColor = (self.selectedIndex == idx) ? self.followByScrollingTextColor : [self.followByScrollingTextColor colorWithAlphaComponent:_followByScrollingTextMinAlpha];
        }
        else {
            label.textColor = self.selectedIndex == idx ? self.selectedTextColor : self.unselectTextColor;
        }
        label.font = self.selectedIndex == idx ? self.selectedTextFont : self.unselectTextFont;
        if (self.customTitleBlock) {
            self.customTitleBlock(label, obj, self.selectedIndex == idx);
        }
        else {
            label.text = obj.text;
        }
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(view);
        }];
        
        UIFont *maxFont = nil;
        if (self.selectedTextFont) {
            maxFont = self.selectedTextFont;
        }
        if (self.unselectTextFont.pointSize > maxFont.pointSize) {
            maxFont = self.unselectTextFont;
        }
        if (!maxFont) {
            maxFont = [self defaultTextFont];
        }
        
        CGSize size;
        if (self.customTitleBlock && label.attributedText) {
            size = [label.attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, pHeight}
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil].size;
        }
        else {
            size = [label.text safeSizeWithFont:maxFont
                              constrainedToSize:(CGSize){CGFLOAT_MAX, pHeight}
                                  lineBreakMode:NSLineBreakByTruncatingTail];
        }
        pWidth = size.width + self.menuViewMargin * 2;
        view.frame = (CGRect){preOriginX, 0.f, pWidth, pHeight};
        preOriginX += pWidth;
        
        [self.infinityScrollView addSubview:view];
        
        @weakify(self);
        [view bk_whenTapped:^{
            @strongify(self)
            //self.selectedIndex = idx;
            [self setSelectedIndexByTap:idx];
        }];
        
        [self.menuViewList addObject:view];
    }];
    
    CGFloat totalWidth = preOriginX;
    self.infinityScrollView.contentSize = CGSizeMake(totalWidth, pHeight);
    
    if (totalWidth < self.frame.size.width) {
        CGRect frame = self.infinityScrollView.frame;
        //frame.size.width = totalWidth;
        self.infinityScrollView.scrollEnabled = NO;
        
        CGFloat left = 0.f;
        if (kDYMenuListViewModelAlignmentLeft == _viewAlignment) {
            left = 0.f;
        }
        else if (kDYMenuListViewModelAlignmentCenter == _viewAlignment) {
            left = (self.frame.size.width - totalWidth) * 0.5f;
        }
        else if (kDYMenuListViewModelAlignmentRight == _viewAlignment) {
            left = self.frame.size.width - totalWidth;
        }
        
        [_infinityScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(left);
            make.width.mas_offset(totalWidth);
            make.height.mas_offset(pHeight);
        }];
    }
    else {
        [_infinityScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(self);
        }];
    }
}

#pragma mark - others
- (void)animationTensileElasticityForUnderLineTypeWithTargetOriginX:(CGFloat)targetOriginX targetWidth:(CGFloat)targetWidth
{
    if (!_isTensileElasticityForUnderLineType) return;
    
    [self.selectedBgView pop_removeAllAnimations];
    
    CGRect selectedBgViewFrame = self.selectedBgView.frame;
    CGFloat startOriginX = selectedBgViewFrame.origin.x;
    CGFloat diff = (targetOriginX - selectedBgViewFrame.origin.x);
    __weak typeof(self) weakSelf = self;
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"pageChange" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGFloat value = values[0];
            @autoreleasepool {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
//                CGFloat originX = startOriginX + value * diff;
//                CGFloat distance = fabs(round(value) - value);
//                CGFloat mult = 1 + distance * 2;
//
//                CGRect newFrame = strongSelf.selectedBgView.frame;
//                newFrame.origin.x = originX;
//                newFrame.size.width = targetWidth * mult;
//                strongSelf.selectedBgView.frame = newFrame;
                
                [strongSelf tensileElasticityForUnderLineTypeWithBeginPositionX:startOriginX
                                                                   endPositionX:targetOriginX
                                                               currentPositionX:value
                                                                    targetWidth:targetWidth];
                
            }
        };
        //力学阀值,值越大writeBlock的调用次数越少
        prop.threshold = 1;
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];
    anBasic.repeatForever = NO;
    anBasic.property = prop;
    anBasic.fromValue = @(0.f);
    anBasic.toValue = @(1.f);
    anBasic.duration = 0.25f;
    [self.selectedBgView pop_addAnimation:anBasic forKey:@"pageChange"];
}

- (void)tensileElasticityForUnderLineTypeWithBeginPositionX:(CGFloat)beginPositionX
                                               endPositionX:(CGFloat)endPositionX
                                           currentPositionX:(CGFloat)currentPositionX
                                                targetWidth:(CGFloat)targetWidth
{
    CGRect selectedBgViewFrame = self.selectedBgView.frame;
    CGFloat startPositionX = beginPositionX;
    CGFloat diff = (endPositionX - startPositionX);
    
    CGFloat originX = startPositionX + currentPositionX * diff;
    CGFloat distance = fabs(round(currentPositionX) - currentPositionX);
    CGFloat mult = 1 + distance * 2;
    
    CGRect newFrame = self.selectedBgView.frame;
    newFrame.origin.x = originX;
    newFrame.size.width = targetWidth * mult;
    self.selectedBgView.frame = newFrame;
}

#pragma mark - settings
- (void)resetWithSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex < 0 || selectedIndex >= self.list.count) return;
    _preSelectedIndex = -1;
    _selectedIndex = selectedIndex;
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    
    self.backgroundColor = bgColor;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex
        allowReselectIndex:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
      allowReselectIndex:(BOOL)allowReselectIndex
{
    if (selectedIndex < 0 || selectedIndex >= self.list.count) return;
    BOOL isSelectedIndexChanged = (_selectedIndex != selectedIndex);
    if (!isSelectedIndexChanged && !allowReselectIndex) return;
    
    _preSelectedIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    [self reloadViewsWithSelectedIndexChanged:isSelectedIndexChanged];
}

//点击切换当前选中项
- (void)setSelectedIndexByTap:(NSInteger)selectedIndex
{
    self.selectedIndexChangedType = kDYMenuViewSelectedIndexChangedTypeByTap;
    if (_allowReselectIndex) {
        [self setSelectedIndex:selectedIndex allowReselectIndex:YES];
    }
    else {
        self.selectedIndex = selectedIndex;
    }
    self.selectedIndexChangedType = kDYMenuViewSelectedIndexChangedTypeDefault;
}

//滑动切换当前选中项
- (void)setSelectedIndexByScrolling:(NSInteger)selectedIndex
{
    self.selectedIndexChangedType = kDYMenuViewSelectedIndexChangedTypeByScrolling;
    self.selectedIndex = selectedIndex;
    self.selectedIndexChangedType = kDYMenuViewSelectedIndexChangedTypeDefault;
}

- (UIFont *)defaultTextFont
{
    return [UIFont systemFontOfSize:16.f];
}

- (void)setUnselectTextColor:(UIColor *)color
{
    if (DYCheckInvalidAndKindOfClass(color, UIColor))
    {
        return;
    }
    _unselectTextColor = color;
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)setSelectedTextColor:(UIColor *)color
{
    if (DYCheckInvalidAndKindOfClass(color, UIColor))
    {
        return;
    }
    _selectedTextColor = color;
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)setSelectedBackgroundColor:(UIColor *)color
{
    if (DYCheckInvalidAndKindOfClass(color, UIColor))
    {
        return;
    }
    _selectedBackgroundColor = color;
    self.selectedBgView.backgroundColor = _selectedBackgroundColor;
    self.selectedBgView.image = nil;
}

- (void)setSelectedBackgroundImage:(UIImage *)image
{
    if ([image isKindOfClass:UIImage.class]) {
        return;
    }
    _selectedBackgroundImage = image;
    self.selectedBgView.backgroundColor = [UIColor clearColor];
    self.selectedBgView.image = image;
}

- (void)setUnderLineSelectedBackgroundWidth:(CGFloat)underLineSelectedBackgroundWidth
{
    if (underLineSelectedBackgroundWidth <= 0.f) underLineSelectedBackgroundWidth = 5.f;
    
    _underLineSelectedBackgroundWidth = underLineSelectedBackgroundWidth;
}

- (void)setUnselectTextFont:(UIFont *)font
{
    if (DYCheckInvalidAndKindOfClass(font, UIFont))
    {
        return;
    }
    _unselectTextFont = font;
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)setSelectedTextFont:(UIFont *)font
{
    if (DYCheckInvalidAndKindOfClass(font, UIFont))
    {
        return;
    }
    _selectedTextFont = font;
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)setMenuViewMargin:(CGFloat)menuViewMargin
{
    if (menuViewMargin <= 0 ||
        !_list.count)
    {
        return;
    }
    _menuViewMargin = menuViewMargin;
    
    [self reloadViewsWithSelectedIndexChanged:YES];
}

- (void)setDisableAnimated:(BOOL)disableAnimated
{
    _disableAnimated = disableAnimated;
}

- (void)setIsTensileElasticityForUnderLineType:(BOOL)isTensileElasticityForUnderLineType
{
    _isTensileElasticityForUnderLineType = isTensileElasticityForUnderLineType;
}

- (void)setIsSelectedBgViewFollowByScrolling:(BOOL)isSelectedBgViewFollowByScrolling
{
    _isSelectedBgViewFollowByScrolling = isSelectedBgViewFollowByScrolling;
}

- (void)setFollowByScrollingTextColor:(UIColor *)followByScrollingTextColor
{
    _followByScrollingTextColor = followByScrollingTextColor;
}

- (void)setFollowByScrollingTextMinAlpha:(CGFloat)followByScrollingTextMinAlpha
{
    _followByScrollingTextMinAlpha = followByScrollingTextMinAlpha;
}

- (void)setIsInfinityMode:(BOOL)isInfinityMode
{
    if (isInfinityMode == _isInfinityMode) return;
    _isInfinityMode = isInfinityMode;
    
    [self setupInfinityScrollView];
    
    [self refreshViews];
    
    [self reloadViewsWithSelectedIndexChanged:NO];
}

- (void)changingIndexWithBeginIndex:(NSUInteger)beginIndex
                           endIndex:(NSUInteger)endIndex
                           progress:(CGFloat)progress
{
    if (beginIndex >= _menuViewList.count ||
        endIndex >= _menuViewList.count ||
        _selectedTextFont.pointSize <= 0 ||
        _unselectTextFont.pointSize <= 0) {
        return;
    }
    
    UIView *beginView = _menuViewList[beginIndex];
    UIView *endView = _menuViewList[endIndex];
    if (self.isSelectedBgViewFollowByScrolling) {
        UILabel *beginLabel = [beginView viewWithTag:kDYMenuListViewModelLabelTag];
        UILabel *endLabel = [endView viewWithTag:kDYMenuListViewModelLabelTag];
        CGFloat minAlpha = self.followByScrollingTextMinAlpha;
        beginLabel.textColor = [self.followByScrollingTextColor colorWithAlphaComponent:minAlpha + (1 - minAlpha) * (1 - progress)];
        beginLabel.font = _unselectTextFont;
        CGFloat scale = 1 + (_selectedTextFont.pointSize / _unselectTextFont.pointSize - 1) * (1 - progress);
        beginLabel.transform = CGAffineTransformMakeScale(scale, scale);
        
        endLabel.textColor = [self.followByScrollingTextColor colorWithAlphaComponent:minAlpha + (1 - minAlpha) * progress];
        endLabel.font = _unselectTextFont;
        scale = 1 + (_selectedTextFont.pointSize / _unselectTextFont.pointSize - 1) * progress;
        endLabel.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    //selectedBgView的位置动画
    if (kDYMenuListViewModelTypeDefault == _type ||
        kDYMenuListViewModelTypeBackgroundImage == _type)
    {
        CGRect frame = self.selectedBgView.frame;
        frame.origin.x = beginView.frame.origin.x;
        frame.size.width = beginView.frame.size.width;
        self.selectedBgView.frame = frame;
        return;
    }
    
    if (kDYMenuListViewModelTypeUnderLine == _type)
    {
        CGFloat fixedX = 0.f;
        CGFloat fixedWidth = beginView.frame.size.width;
        if (_underLineSelectedBackgroundWidth > 0 &&
            _underLineSelectedBackgroundWidth < beginView.frame.size.width) {
            fixedX = (beginView.frame.size.width - _underLineSelectedBackgroundWidth) * 0.5f;
            fixedWidth = _underLineSelectedBackgroundWidth;
        }
        
        if (_isTensileElasticityForUnderLineType) {
            CGFloat startOriginX = beginView.frame.origin.x + fixedX;
            CGFloat targetOriginX = endView.frame.origin.x + (endView.frame.size.width - _underLineSelectedBackgroundWidth) * 0.5f;
            DYLogInfo(@"beginIndex:%ld endIndex:%ld", beginIndex, endIndex);
            DYLogInfo(@"startOriginX:%lf targetOriginX:%lf progress:%lf", startOriginX, targetOriginX, progress);
            [self tensileElasticityForUnderLineTypeWithBeginPositionX:startOriginX
                                                         endPositionX:targetOriginX
                                                     currentPositionX:progress
                                                          targetWidth:fixedWidth];
        }
        else {
            CGRect frame = self.selectedBgView.frame;
            frame.origin.x = beginView.frame.origin.x + fixedX;
            frame.size.width = fixedWidth;
            
            self.selectedBgView.frame = frame;
        }
        return;
    }
    
    if (kDYMenuListViewModelTypeHighlight == _type)
    {
        self.selectedBgView.hidden = YES;
    }
}

- (void)menuFollowByScrollingAnimationWithScrollView:(UIScrollView *)scrollView
{
    CGFloat fractionalPage = scrollView.contentOffset.x / kScreenWidth;
    NSInteger page = lround(fractionalPage);
    
    if (self.isSelectedBgViewFollowByScrolling) {
        if (self.selectedIndex != page &&
            scrollView.isDragging) {
            self.selectedIndex = page;
        }
        
        if (scrollView.contentOffset.x >= 0 &&
            scrollView.contentOffset.x <= self.menuViewList.count * kScreenWidth) {
            
            if (scrollView.isDragging)
            {
                _preSelectedIndex = self.selectedIndex;
                
                NSInteger targetPage = _selectedIndex;
                CGFloat diff = scrollView.contentOffset.x - kScreenWidth * _selectedIndex;
                if (diff > 0) {
                    targetPage += 1;
                }
                else {
                    targetPage -= 1;
                }
                
                CGFloat progress = fabs(diff) / kScreenWidth;
                [self changingIndexWithBeginIndex:_selectedIndex endIndex:targetPage progress:progress];
            }
            else {
                NSInteger targetPage = _preSelectedIndex;
                
                CGFloat diff = scrollView.contentOffset.x - kScreenWidth * _selectedIndex;
                NSInteger tabDiff = abs(targetPage - _selectedIndex);
                if (tabDiff < 1) {
                    tabDiff = 1;
                    if (diff > 0) targetPage += 1;
                    else targetPage -= 1;
                }
                CGFloat progress = fabs(diff) / (kScreenWidth * tabDiff);
                [self changingIndexWithBeginIndex:_selectedIndex endIndex:targetPage progress:progress];
            }
        }
        return;
    }
    
    if (!scrollView.isDragging) {
        return;
    }
    
    //NSLog(@"page:%ld", page);
    if (_selectedIndex != page) {
        self.selectedIndex = page;
    }
    
}

@end
