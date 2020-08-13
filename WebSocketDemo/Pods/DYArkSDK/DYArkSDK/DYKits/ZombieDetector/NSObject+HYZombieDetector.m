////  NSObject+HYZombieDetector.m
//  HYZombieDetector
//
//  Created by Haisheng Ding on 2018/5/24.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import "NSObject+HYZombieDetector.h"
#import "HYZombieDetector+Private.h"
#import "HYZombieDetector.h"

@implementation NSObject (HYZombieDetector)

-(void)hy_originalDealloc {
    //placeholder for original dealloc
}

-(void)hy_newDealloc {
    [[HYZombieDetector sharedInstance] newDealloc:self];
}

@end
