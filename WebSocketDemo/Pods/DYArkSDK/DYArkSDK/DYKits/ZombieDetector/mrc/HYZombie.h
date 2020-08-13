////  HYZombie.h
//  HYZombieDetector
//
//  Created by Haisheng Ding on 2018/5/23.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

class HYThreadStack;

@interface HYZombie : NSObject

@property (nonatomic, assign)Class realClass;
@property (nonatomic, assign)HYThreadStack *threadStack;

+ (Class)zombieIsa;
+ (NSInteger)zombieInstanceSize;

@end
