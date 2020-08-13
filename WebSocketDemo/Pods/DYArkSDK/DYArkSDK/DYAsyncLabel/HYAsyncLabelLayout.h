////  HYAsyncLabelLayout.h
//  kiwi
//
//  Created by Haisheng Ding on 2018/6/22.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface HYAsyncLabelLayout : NSObject

@property(nonatomic) NSInteger fitNumberOfLines;
@property(nonatomic) CGSize fitSize;
@property(nonatomic) CGFloat fitLineHeight;

+ (instancetype)layoutWithSize:(CGSize)size
                 numberOfLines:(NSInteger)numberOfLines
              attributedString:(NSAttributedString*)attributedString
                   autoFitSize:(BOOL)autoFitSize
             contentEdgeInsets:(UIEdgeInsets) contentEdgeInsets;

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect;
- (CFIndex)characterIndexAtPoint:(CGPoint)p;

@end
