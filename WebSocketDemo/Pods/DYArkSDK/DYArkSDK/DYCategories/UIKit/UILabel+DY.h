//
//  UILabel+DY.h
//  ArkDemo
//
//  Created by EasyinWan on 2019/5/15.
//  Copyright © 2019 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DY)

//设置行高
- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize;

- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize text:(NSString *)text;

- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize attributedText:(NSAttributedString *)attributedText;

@end
