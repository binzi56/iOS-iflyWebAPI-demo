//
//  MASConstraint+DY.h
//  XHX
//
//  Created by EasyinWan on 2019/1/23.
//  Copyright © 2019 XYWL. All rights reserved.
//

#import "MASConstraint.h"

#define dy_scaleOffset(OFFSET) offset([UIUtils screenWidth375Scale] * (OFFSET))

#define dy_scaleSizeEqualTo(SIZE) equalTo(CGSizeMake([UIUtils screenWidth375Scale] * (SIZE).width, [UIUtils screenWidth375Scale] * (SIZE).height))

#define dy_scaleLengthEqualTo(LENGTH) equalTo([UIUtils screenWidth375Scale] * (LENGTH))

@interface MASConstraint (DY)

- (MASConstraint * (^)(CGFloat offset))dy_scaleOffset;

- (MASConstraint * (^)(CGSize size))dy_scaleSizeEqualTo;

- (MASConstraint * (^)(CGFloat length))dy_scaleLengthEqualTo;

@end
