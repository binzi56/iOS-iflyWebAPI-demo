//
//  DYMenuView.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/9.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYMenuListViewModel.h"

typedef void (^kDYMenuViewCustomAnimationBlock)(UIView *selectedView, UIImageView *selectedBgView, CGRect selectedBgViewFinalFrame);
typedef void (^kDYMenuViewCustomTitleBlock)(UILabel *titleLabel, DYMenuModel *model, BOOL isSelected);

typedef NS_ENUM(int32_t, kDYMenuViewSelectedIndexChangedType)
{
    kDYMenuViewSelectedIndexChangedTypeDefault = 0,
    kDYMenuViewSelectedIndexChangedTypeByTap,        //点击切换selectedIndex
    kDYMenuViewSelectedIndexChangedTypeByScrolling,  //滑动切换selectedIndex
};

@class DYMenuView;
@protocol DYMenuViewDelegate <NSObject>
@optional
- (void)menuView:(DYMenuView *)menuView
  didSelectIndex:(NSInteger)index
     selectedTag:(NSUInteger)selectedTag
      isAnimated:(BOOL)isAnimated;

@end

@interface DYMenuView : UIView

@property (nonatomic, assign) BOOL isInfinityMode;

@property (nonatomic, weak) id<DYMenuViewDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, readonly, assign) kDYMenuViewSelectedIndexChangedType selectedIndexChangedType;
@property (nonatomic, readonly, assign) BOOL allowReselectIndex;
@property (nonatomic, assign) UIColor *bgColor;

@property (nonatomic, strong, readonly) UIColor *unselectTextColor;
@property (nonatomic, strong, readonly) UIColor *selectedTextColor;
@property (nonatomic, strong, readonly) UIColor *selectedBackgroundColor;
@property (nonatomic, strong, readonly) UIImage *selectedBackgroundImage;
@property (nonatomic, assign, readonly) CGFloat underLineSelectedBackgroundWidth;
@property (nonatomic, assign) CGFloat selectedBackgroundOffsetY;
@property (nonatomic, assign, readonly) kDYMenuListViewModelType type;         //default kGSSegmentControlViewTypeDefault
@property (nonatomic, assign, readonly) kDYMenuListViewModelAlignment viewAlignment;    //isInfinityMode为YES时才生效，因为非无限模式时，菜单占满整个DYMenuView
//@property (nonatomic, assign, readonly) kDYMenuListViewModelOrientationType orientationType;
@property (nonatomic, assign, readonly) BOOL isTensileElasticityForUnderLineType;
@property (nonatomic, copy) kDYMenuViewCustomAnimationBlock customAnimationBlock;
@property (nonatomic, copy) kDYMenuViewCustomTitleBlock customTitleBlock;

@property (nonatomic, strong, readonly) DYMenuListViewModel *viewModel;

+ (instancetype)menuViewWithListViewModel:(DYMenuListViewModel *)viewModel;

- (void)refreshViews;

- (void)resetWithSelectedIndex:(NSInteger)selectedIndex;
//点击切换当前选中项
- (void)setSelectedIndexByTap:(NSInteger)selectedIndex;
//滑动切换当前选中项
- (void)setSelectedIndexByScrolling:(NSInteger)selectedIndex;

- (void)setUnselectTextColor:(UIColor *)color;

- (void)setSelectedTextColor:(UIColor *)color;

- (void)setSelectedBackgroundColor:(UIColor *)color;

- (void)setSelectedBackgroundImage:(UIImage *)image;

- (void)setUnderLineSelectedBackgroundWidth:(CGFloat)underLineSelectedBackgroundWidth;

- (void)setUnselectTextFont:(UIFont *)font;

- (void)setSelectedTextFont:(UIFont *)font;

- (void)setMenuViewMargin:(CGFloat)menuViewMargin;

- (void)setDisableAnimated:(BOOL)disableAnimated;

//有弹性动画 for kDYMenuListViewModelTypeUnderLine only
- (void)setIsTensileElasticityForUnderLineType:(BOOL)isTensileElasticityForUnderLineType;

//当前选中的底栏标识跟随移动
- (void)setIsSelectedBgViewFollowByScrolling:(BOOL)isSelectedBgViewFollowByScrolling;

- (void)setFollowByScrollingTextColor:(UIColor *)followByScrollingTextColor;

- (void)setFollowByScrollingTextMinAlpha:(CGFloat)followByScrollingTextMinAlpha;

- (void)changingIndexWithBeginIndex:(NSUInteger)beginIndex
                           endIndex:(NSUInteger)endIndex
                           progress:(CGFloat)progress;

- (void)menuFollowByScrollingAnimationWithScrollView:(UIScrollView *)scrollView;

@end
