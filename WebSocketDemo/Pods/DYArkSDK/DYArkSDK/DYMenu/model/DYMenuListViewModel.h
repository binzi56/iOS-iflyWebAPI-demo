//
//  DYMenuListViewModel.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/12.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYMenuModel.h"

typedef NS_ENUM(NSUInteger, kDYMenuListViewModelType)
{
    kDYMenuListViewModelTypeDefault = 0,
    kDYMenuListViewModelTypeUnderLine,
    kDYMenuListViewModelTypeBackgroundImage,
    kDYMenuListViewModelTypeHighlight,
};

typedef NS_ENUM(NSUInteger, kDYMenuListViewModelOrientationType)
{
    kDYMenuListViewModelOrientationTypeDefault = 0,
    kDYMenuListViewModelOrientationTypePortrait,
    kDYMenuListViewModelOrientationTypeLandscape,
};

typedef NS_ENUM(NSUInteger, kDYMenuListViewModelAlignment)
{
    kDYMenuListViewModelAlignmentDefault = 0,
    kDYMenuListViewModelAlignmentLeft,
    kDYMenuListViewModelAlignmentCenter,
    kDYMenuListViewModelAlignmentRight,
};


@interface DYMenuListViewModel : NSObject

@property (nonatomic, assign) BOOL isInfinityMode;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) UIColor *bgColor;

@property (nonatomic, strong) UIColor *unselectTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIFont *unselectTextFont;
@property (nonatomic, strong) UIFont *selectedTextFont;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, assign) CGFloat underLineSelectedBackgroundWidth;
@property (nonatomic, assign) CGFloat selectedBackgroundOffsetY;
@property (nonatomic, assign) CGFloat bgViewOffsetX;
@property (nonatomic, assign) kDYMenuListViewModelType type;
@property (nonatomic, assign) kDYMenuListViewModelAlignment viewAlignment;
//@property (nonatomic, assign) kDYMenuListViewModelOrientationType orientationType;
@property (nonatomic, assign) CGFloat menuViewMargin;
@property (nonatomic, assign) BOOL isDisableAnimated;
@property (nonatomic, assign) BOOL isTensileElasticityForUnderLineType;

@property (nonatomic, assign) BOOL isSelectedBgViewFollowByScrolling;           //是否跟随scroll动作做动画

@property (nonatomic, assign) BOOL allowReselectIndex;                          //点击同一个index也会触发indexChanged

@property (nonatomic, assign) UIColor *followByScrollingTextColor;              //跟随scroll时默认(未选中)的textColor
@property (nonatomic, assign) CGFloat followByScrollingTextMinAlpha;            //跟随scroll时变化的text最低alpha值(即未选中时)

@property (nonatomic, assign) CGSize menuSize;

@property (nonatomic, strong) NSMutableArray<DYMenuModel *> *list;

@property (nonatomic, copy) void (^customAnimationBlock)(UIView *selectedView, UIImageView *selectedBgView, CGRect selectedBgViewFinalFrame);

@property (nonatomic, copy) void (^customTitleBlock)(UILabel *titleLabel, DYMenuModel *model, BOOL isSelected);

@end
