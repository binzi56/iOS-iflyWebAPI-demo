////  HYAsyncLabelLayout.m
//  kiwi
//
//  Created by Haisheng Ding on 2018/6/22.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import "HYAsyncLabelLayout.h"
#import "HYAsyncLabelRunDelegate.h"
#import "HYLogMacros.h"

#import <CoreText/CoreText.h>

@implementation HYAsyncLabelLayout
{
    CTFramesetterRef _framesetter;
    CTFrameRef _frame;
    CGRect _rect;
    UIEdgeInsets _contentEdgeInsets;
    NSInteger _numberOfLine;
    NSAttributedString *_attributedString;
    CFArrayRef _lines;
    BOOL _needTruncatedLastLine;
    BOOL _autoFitSize;
    CGFloat _originY;
    NSMutableParagraphStyle *_paragraphStyle;
}

+ (instancetype)layoutWithSize:(CGSize)size
                 numberOfLines:(NSInteger)numberOfLines
              attributedString:(NSAttributedString*)attributedString
                   autoFitSize:(BOOL)autoFitSize
             contentEdgeInsets:(UIEdgeInsets) contentEdgeInsets {
    return [[HYAsyncLabelLayout alloc] initWithSize:size
                                      numberOfLines:numberOfLines
                                   attributedString:attributedString
                                        autoFitSize:autoFitSize
                                  contentEdgeInsets:contentEdgeInsets];
}

+ (CTRunDelegateRef)createRunDelegateForAttachment:(NSTextAttachment *)attachment {
    return NULL;
}

- (instancetype)initWithSize:(CGSize)size
               numberOfLines:(NSInteger)numberOfLines
            attributedString:(NSAttributedString*)attributedString
                 autoFitSize:(BOOL)autoFitSize
           contentEdgeInsets:(UIEdgeInsets) contentEdgeInsets {
    if (self = [super init]) {
        if (size.width == 0) {
            size.width = CGFLOAT_MAX;
        }
        if (size.height == 0) {
            size.height = CGFLOAT_MAX;
        }
        _rect = CGRectMake(0, 0, size.width, size.height);
        _numberOfLine = numberOfLines;
        _attributedString = attributedString;
        _autoFitSize = autoFitSize;
        _contentEdgeInsets = contentEdgeInsets;
        [self layout];
    }
    return self;
}

- (void)dealloc {
    if (_framesetter) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    if (_frame) {
        CFRelease(_frame);
        _frame = NULL;
    }
}


- (void)layout {
    _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedString);
    if (!_framesetter) {
        KWSLogInfo(@"create framesetter failed str:%@", _attributedString);
        return;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _rect);
    _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    if (!_frame) {
        KWSLogInfo(@"create frame failed str:%@", _attributedString);
        return;
    }
    
    CFRange fitRange = {0};
    _lines = CTFrameGetLines(_frame);
    if (!_lines) {
        KWSLogInfo(@"CTFrameGetLines str:%@", _attributedString);
        return;
    }
    CFIndex count = CFArrayGetCount(_lines);
    if (count == 0) {
        KWSLogInfo(@"number of lines is 0 str:%@", _attributedString);
        return;
    }
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, _rect.size, &fitRange);
    if (fitRange.length != _attributedString.length) {
        _needTruncatedLastLine = YES;
    }
    if (_numberOfLine > 0 && _numberOfLine < count) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(_lines, _numberOfLine-1);
        CFRange range = CTLineGetStringRange(line);
        CFRange fixedRange = {0};
        CGSize fixedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, range.location+range.length), NULL, _rect.size, &fixedRange);
        _fitSize = fixedSize;
        _fitNumberOfLines = _numberOfLine;
        _needTruncatedLastLine = YES;
    } else {
        _fitSize = fitSize;
        _fitNumberOfLines = count;
    }
    
    if (_fitNumberOfLines) {
        _fitLineHeight = _fitSize.height / _fitNumberOfLines;
    }
    
    if (!_autoFitSize) {
        _originY = (_rect.size.height - _fitSize.height) / 2;
    } else {
        _fitSize.width += _contentEdgeInsets.left + _contentEdgeInsets.right;
        _fitSize.height += _contentEdgeInsets.top + _contentEdgeInsets.bottom;
        _rect = CGRectMake(_rect.origin.x, _rect.origin.y, _fitSize.width, _fitSize.height);
        CFRelease(_frame);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, _rect);
        _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, NULL);
        CFRelease(path);
        if (!_frame) {
            KWSLogInfo(@"create auto resize frame failed str:%@", _attributedString);
            return;
        }
        _lines = CTFrameGetLines(_frame);
        _fitNumberOfLines = CFArrayGetCount(_lines);
        _originY = _contentEdgeInsets.bottom;
    }
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect {
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0.0f, _rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    if (!_lines || _fitNumberOfLines == 0) {
        return;
    }
    
    CGPoint *linesOrigins = (CGPoint*)malloc(sizeof(CGPoint) * CFArrayGetCount(_lines));
    if (!linesOrigins) {
        return;
    }
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), linesOrigins);
    CGFloat originY = _originY;
    for (NSInteger i = 0; i < _fitNumberOfLines; ++i) {
        CGFloat lineAscent = 0;
        CGFloat lineDescent = 0;
        CGFloat lineLeading = 0;
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(_lines, i);
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        BOOL needTruncated = i == _fitNumberOfLines-1 && _needTruncatedLastLine;
        CTLineRef truncatedLine = NULL;
        if (needTruncated) {
            do {
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                CFIndex count = CFArrayGetCount(runs);
                if (count <= 0) {
                    break;
                }
                CTRunRef lastRun = CFArrayGetValueAtIndex(runs, count-1);
                NSMutableAttributedString *truncatinTokenStr = [[NSMutableAttributedString alloc] initWithString:@"..."];
                CFDictionaryRef attributesRef = CTRunGetAttributes(lastRun);
                NSDictionary * attributes = nil;
                if (!attributesRef) {
                    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
                } else {
                    attributes = (__bridge NSDictionary*)attributesRef;
                }
                [truncatinTokenStr addAttributes:attributes range:NSMakeRange(0, 0)];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)truncatinTokenStr);
                CGRect truncationRect = CTLineGetImageBounds(truncationToken, context);
                CGFloat width = 5;
                if (!CGRectEqualToRect(truncationRect, CGRectNull)) {
                    width = truncationRect.size.width;
                }
                truncatedLine = CTLineCreateTruncatedLine(line, _rect.size.width - width - 5, kCTLineTruncationEnd, truncationToken);
                CFRelease(truncationToken);
            }while (0);
        }
        CGPoint lineOrigin = linesOrigins[i];
        //originY = originY - globalLineLeading - lineAscent;
        lineOrigin.y = lineOrigin.y - originY;
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        if (truncatedLine) {
            [self drawLine:truncatedLine context:context origin:lineOrigin];
            //CTLineDraw(truncatedLine, context);
            CFRelease(truncatedLine);
        } else {
            [self drawLine:line context:context origin:lineOrigin];
            //CTLineDraw(line, context);
        }
    }
    free(linesOrigins);
}

- (void)drawLine:(CTLineRef)line context:(CGContextRef)context origin:(CGPoint)origin{
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex count = CFArrayGetCount(runs);
    if (count <= 0) {
        return;
    }
    CGFloat lineBaseOriginY = (int)(origin.y / _fitLineHeight) * _fitLineHeight + _contentEdgeInsets.bottom;
    for (int i = 0; i < count;  ++i) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
        CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
        if (delegate == nil) {
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            CGFloat fixOriginY = (_fitLineHeight - ascent - descent - leading) / 2 + descent + leading + lineBaseOriginY;
            CGContextSetTextPosition(context, origin.x, fixOriginY);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        } else {
            void* refCon = CTRunDelegateGetRefCon(delegate);
            HYAsyncLabelRunDelegate *hyAsyncLabelRunDelegate = (__bridge HYAsyncLabelRunDelegate*)refCon;
            if (![hyAsyncLabelRunDelegate isKindOfClass:[HYAsyncLabelRunDelegate class]]) {
                return;
            }
            if (hyAsyncLabelRunDelegate.image) {
                CGRect runBounds;
                CGFloat ascent;
                CGFloat descent;
                
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                runBounds.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.x = origin.x + xOffset;
                runBounds.origin.y = origin.y;
                runBounds.origin.y -= descent;
                
                CGPathRef pathRef = CTFrameGetPath(_frame);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);

                delegateBounds.origin.x += hyAsyncLabelRunDelegate.bounds.origin.x;
                delegateBounds.origin.y += hyAsyncLabelRunDelegate.bounds.origin.y;
                CGContextDrawImage(context, delegateBounds, hyAsyncLabelRunDelegate.image.CGImage);
            }
        }
        
    }
}

- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    CFIndex idx = NSNotFound;
    if (!_lines) {
        return idx;
    }
    CGPoint *linesOrigins = (CGPoint*)malloc(sizeof(CGPoint) * CFArrayGetCount(_lines));
    if (!linesOrigins) {
        return idx;
    }
    
    p = CGPointMake(p.x - _rect.origin.x, p.y - _rect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, _rect.size.height - p.y);
    
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), linesOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < _fitNumberOfLines; lineIndex++) {
        CGPoint lineOrigin = linesOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(_lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
        
        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = 0.0;;
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, _rect.size.width);
        lineOrigin.x = penOffset;
        lineOrigin.y = lineOrigin.y - _originY;
        
        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    free(linesOrigins);
    return idx;
}

//- (CGFloat)flushFactorForTextAlignment:(NSTextAlignment)alignment {
//    return 0;
//}
//
//- (NSMutableParagraphStyle*)paragraphStyle {
//    if (!_paragraphStyle) {
//        NSDictionary<NSAttributedStringKey, id> * ruler = [_attributedString rulerAttributesInRange:NSMakeRange(0, 0)];
//    }
//}

@end
