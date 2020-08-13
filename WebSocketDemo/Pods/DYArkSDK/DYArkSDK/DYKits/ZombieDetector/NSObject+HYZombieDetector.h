////  NSObject+HYZombieDetector.h
//  HYZombieDetector
//
//  Created by Haisheng Ding on 2018/5/24.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HYZombieDetector)

-(void)hy_originalDealloc;
-(void)hy_newDealloc;

@end
