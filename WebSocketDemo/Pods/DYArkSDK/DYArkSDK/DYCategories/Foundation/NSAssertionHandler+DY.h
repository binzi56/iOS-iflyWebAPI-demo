//
//  NSAssertionHandler+DY.h
//  XHX
//
//  Created by EasyinWan on 2019/1/14.
//  Copyright © 2019 XYWL. All rights reserved.
//

#ifdef DEBUG

#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>

/**
 由于umeng截取了NSAssertionHandler的实现，这里需要补上关键的log
 */
@interface NSAssertionHandler (DY)

@end

#endif
