//
//  MASConstraint+DY.h
//  XHX
//
//  Created by EasyinWan on 2019/1/23.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "MASConstraint.h"

#define dy_scaleOffset(OFFSET) offset([UIUtils screenWidth375Scale] * (OFFSET))

#define dy_scaleEqualTo(SIZE) equalTo(CGSizeMake([UIUtils screenWidth375Scale] * (SIZE).width, [UIUtils screenWidth375Scale] * (SIZE).height))

@interface MASConstraint (DY)

- (MASConstraint * (^)(CGFloat offset))dy_scaleOffset;

- (MASConstraint * (^)(CGSize size))dy_scaleEqualTo;

@end
