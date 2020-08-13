//
//  DYInterlockInnerViewDelegate.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/12.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DYInterlockInnerViewDelegate <NSObject>
@optional
- (void)innerScrollViewDidScroll:(UIView *)view scrollView:(UIScrollView *)scrollView;

- (void)innerScrollViewDidScrollWithViewController:(__kindof UIViewController *)viewController scrollView:(UIScrollView *)scrollView;

- (void)innerScrollDidEndDeceleratingWithViewController:(__kindof UIViewController *)viewController scrollView:(UIScrollView *)scrollView;

- (void)innerReloadDataAll;

- (void)reloadListDataOnly;

@end
