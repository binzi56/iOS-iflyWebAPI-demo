//
//  DYMutilDelegates.h
//
//  Created by flyhuang on 15/8/17.
//  Copyright (c) 2018年 dianyun. All rights reserved.
//

@interface DYMutilDelegates<__covariant ObjectType> : NSObject

//非线程安全
- (void)addDelegate:(ObjectType)delegate;

//非线程安全
- (void)removeDelegate:(ObjectType)delegate;

@end
