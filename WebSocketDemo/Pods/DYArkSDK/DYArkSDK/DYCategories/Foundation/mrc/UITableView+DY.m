//
//  UITableView+DY.m
//  AFNetworking
//
//  Created by 刘勇航 on 2020/5/29.
//

#import "UITableView+DY.h"
#import <objc/runtime.h>
#import "NSObject+YYAdd.h"

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file.
#endif

@implementation UITableView (DY)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [objc_getClass("UITableView") swizzleInstanceMethod:@selector(setEstimatedRowHeight:) with:@selector(min_setEstimatedRowHeight:)];
        [objc_getClass("UITableView") swizzleInstanceMethod:@selector(setEstimatedSectionHeaderHeight:)
                                                       with:@selector(min_setEstimatedSectionHeaderHeight:)];
        [objc_getClass("UITableView") swizzleInstanceMethod:@selector(setEstimatedSectionFooterHeight:)
                                                       with:@selector(min_setEstimatedSectionFooterHeight:)];
    });
}

#pragma mark -
- (void)min_setEstimatedRowHeight:(CGFloat)height
{
    if ([self checkEstimatedSectionHeight:height]) {
        height = 0;
    }
    [self min_setEstimatedRowHeight:height];
}

- (void)min_setEstimatedSectionHeaderHeight:(CGFloat)height
{
    if ([self checkEstimatedSectionHeight:height]) {
        height = 0;
    }
    [self min_setEstimatedSectionHeaderHeight:height];
}
- (void)min_setEstimatedSectionFooterHeight:(CGFloat)height
{
    if ([self checkEstimatedSectionHeight:height]) {
        height = 0;
    }
    [self min_setEstimatedSectionFooterHeight:height];
}

- (BOOL)checkEstimatedSectionHeight:(CGFloat)height
{
    if (@available(iOS 11.0, *)) {
        return NO;
    }
    else {
        if (height > 0 && height < 2) {
            NSAssert(NO, @"TableViewEstimatedHeight assert => %s:%d", __PRETTY_FUNCTION__, __LINE__);
            return YES;
        }
    }
    return NO;
}

@end
