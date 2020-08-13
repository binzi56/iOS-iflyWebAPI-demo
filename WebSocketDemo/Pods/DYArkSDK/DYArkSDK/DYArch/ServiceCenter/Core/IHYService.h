//
//  HYServiceProtocol.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IWFService <NSObject>

@optional

// 有了servicemanager之后呢按道理来说是由manager来实现单例的
// 这样做是为了过渡兼容老代码，同时这样做也避免了线程安全问题
+ (instancetype)sharedObject;

+ (instancetype)sharedInstance;

- (BOOL)singleton;

@end
