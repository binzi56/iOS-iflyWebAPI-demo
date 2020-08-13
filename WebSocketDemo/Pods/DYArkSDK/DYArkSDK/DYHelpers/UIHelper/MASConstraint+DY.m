//
//  MASConstraint+DY.m
//  XHX
//
//  Created by EasyinWan on 2019/1/23.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "MASConstraint+DY.h"
#import "UiUtils.h"

@implementation MASConstraint (DY)

- (MASConstraint * (^)(CGFloat offset))dy_scaleOffset
{
    // Will never be called due to macro
    return nil;
}

- (MASConstraint * (^)(CGSize size))dy_scaleSizeEqualTo
{
    // Will never be called due to macro
    return nil;
}

- (MASConstraint * (^)(CGFloat length))dy_scaleLengthEqualTo
{
    // Will never be called due to macro
    return nil;
}

@end
