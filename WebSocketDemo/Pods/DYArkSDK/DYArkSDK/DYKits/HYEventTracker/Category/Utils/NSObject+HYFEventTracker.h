////  NSObject+HYFEventTracker.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/7.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HYFEventTracker)

+ (BOOL)ET_swizzleMethod:(SEL)originalSel newSel:(SEL)newSel;

+ (BOOL)ET_methodHasSwizzed:(SEL)sel;
+ (void)ET_setMethodHasSwizzed:(SEL)sel;
+ (SEL)ET_newSelFormOriginalSel:(SEL)sel;

@end
