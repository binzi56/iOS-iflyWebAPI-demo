//
//  DYMenuListViewModel.m
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/12.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import "DYMenuListViewModel.h"

@implementation DYMenuListViewModel

- (instancetype)init
{
    if (self = [super init]) {
        _selectedIndex = -1;
        _viewAlignment = kDYMenuListViewModelAlignmentLeft;
    }
    return self;
}

@end
