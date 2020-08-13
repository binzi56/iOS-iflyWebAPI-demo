//
//  UILabel+DY.m
//  ArkDemo
//
//  Created by EasyinWan on 2019/5/15.
//  Copyright © 2019 xinyu. All rights reserved.
//

#import "UILabel+DY.h"

@implementation UILabel (DY)

- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize
{
    [self setupWithLineHeight:lineHeight fontSize:fontSize text:self.text];
}

- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize text:(NSString *)text
{
    if (!text) {
        NSAssert(NO, @"text should not be nil");
        return;
    }
    NSDictionary *attributes = [self attributesWithLineHeight:lineHeight fontSize:fontSize];
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)setupWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize attributedText:(NSAttributedString *)attributedText
{
    if (!attributedText) {
        NSAssert(NO, @"attributedText should not be nil");
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [attributedString addAttributes:[self attributesWithLineHeight:lineHeight fontSize:fontSize] range:(NSRange){0, attributedString.length}];
    self.attributedText = attributedString;
}

#pragma mark - Private
- (NSMutableDictionary *)attributesWithLineHeight:(CGFloat)lineHeight fontSize:(CGFloat)fontSize
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    CGFloat baselineOffset = (lineHeight - font.lineHeight) / 4;
    [attributes setObject:@(baselineOffset) forKey:NSBaselineOffsetAttributeName];
    return attributes;
}

@end
