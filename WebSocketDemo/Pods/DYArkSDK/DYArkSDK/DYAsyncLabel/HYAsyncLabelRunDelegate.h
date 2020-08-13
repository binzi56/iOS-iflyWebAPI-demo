////  HYAsyncLabelRunDelegate.h
//  AsyncDemo
//
//  Created by Haisheng Ding on 2018/6/26.
//  Copyright © 2018年 dhs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface HYAsyncLabelRunDelegate : NSObject
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, assign)CGRect bounds;
@property (nonatomic, assign) UIEdgeInsets contentsInsets;

+ (CTRunDelegateRef)createRunDelegateForAttachment:(NSTextAttachment*)attachment;

@end
