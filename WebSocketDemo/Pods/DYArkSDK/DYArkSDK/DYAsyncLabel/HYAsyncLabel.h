////  HYAsyncLabel.h
//  kiwi
//
//  Created by Haisheng Ding on 2018/6/22.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

dispatch_queue_t HYAsyncLabelLayerGetDisplayQueue();

@class HYAsyncLabel;


@interface HYTextAttachment: NSTextAttachment

@property (nonatomic, assign) UIEdgeInsets contentsInsets;

@end

@interface HYAsyncLabelAction: NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) void (^action)(HYAsyncLabel *label, NSUInteger location);
@property (nonatomic, assign) NSUInteger location;

@end

@interface HYAsyncLabel : UIView

@property(nonatomic,copy) NSString *text;
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic) NSLineBreakMode lineBreakMode;
@property(nonatomic) BOOL displaysAsynchronously;
@property(nonatomic) CGFloat lineSpacing;
@property(nonatomic) CGFloat minimumLineHeight;
@property(nonatomic) BOOL autoFitSize;
@property(nonatomic) UIEdgeInsets contentEdgeInsets;

@property(nonatomic,copy) NSAttributedString *attributedText;

@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic, readonly) NSInteger fitNumberOfLines;
@property(nonatomic, readonly) CGSize fitSize;

- (HYAsyncLabelAction *)addTapAction:(void (^)(HYAsyncLabel *label, NSUInteger location))action range:(NSRange)range;
- (HYAsyncLabelAction *)addLongPressAction:(void (^)(HYAsyncLabel *label, NSUInteger location))action range:(NSRange)range;
- (void)displayIfNeed:(void (^)(void))complete;

- (void)setAttributedTextWithoutRedraw:(NSAttributedString*)attributedText;
- (void)setTextWithoutRedraw:(NSString*)text;

@end
