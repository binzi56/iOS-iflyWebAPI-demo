////  NSObject+HYFEventTracker.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/7.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "NSObject+HYFEventTracker.h"

#import <objc/runtime.h>

@implementation NSObject (HYFEventTracker)

+ (BOOL)ET_swizzleMethod:(SEL)originalSel newSel:(SEL)newSel {
    Method originMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    
    if (originMethod && newMethod) {
        if (class_addMethod(self, originalSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, newSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, newMethod);
        }
        return YES;
    }
    return NO;
}

+ (BOOL)ET_methodHasSwizzed:(SEL)sel {
    NSNumber *num = objc_getAssociatedObject(self, NSSelectorFromString([self ET_stringFromSelector:sel]));
    return [num boolValue];
}

+ (void)ET_setMethodHasSwizzed:(SEL)sel {
    objc_setAssociatedObject(self, NSSelectorFromString([self ET_stringFromSelector:sel]), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (SEL)ET_newSelFormOriginalSel:(SEL)sel {
    return NSSelectorFromString([self ET_stringFromSelector:sel]);
}

+ (NSString*)ET_stringFromSelector:(SEL)sel {
    return [NSString stringWithFormat:@"ET_%@", NSStringFromSelector(sel)];
}

@end
