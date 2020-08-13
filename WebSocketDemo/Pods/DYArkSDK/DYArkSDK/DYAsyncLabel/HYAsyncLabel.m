////  HYAsyncLabel.m
//  kiwi
//
//  Created by Haisheng Ding on 2018/6/22.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#import "HYAsyncLabel.h"
#import "HYAsyncLabelLayout.h"
#import "HYWeakProxy.h"
#import "HYAsyncLabelRunDelegate.h"

#import <libkern/OSAtomic.h>
#import <CoreText/CoreText.h>

#define kLongPressMinimumDuration 0.5 // Time in seconds the fingers must be held down for long press gesture.

typedef NS_ENUM(NSInteger, HYAsyncLabelLayerState) {
    HYAsyncLabelLayerStateDrawed,
    HYAsyncLabelLayerStateDrawing,
    HYAsyncLabelLayerStateNeedRedraw,
};



dispatch_queue_t HYAsyncLabelLayerGetDisplayQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.huya.label.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.huya.label.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

@implementation HYTextAttachment

@end

@implementation HYAsyncLabelAction

@end

@interface HYAsyncLabel() <CALayerDelegate>

@property (atomic) HYAsyncLabelLayerState layerState;
@property (nonatomic, strong) HYAsyncLabelLayout *layout;
@property (nonatomic, strong) NSMutableArray<HYAsyncLabelAction*> *tapActions;
@property (nonatomic, strong) NSMutableArray<HYAsyncLabelAction*> *longPressActions;

@property (nonatomic, strong) HYAsyncLabelAction *currentTapAction;
@property (nonatomic, strong) HYAsyncLabelAction *currentLongPressAction;

@property (nonatomic, assign) NSInteger debugState;

@end

@implementation HYAsyncLabel
{
    volatile int32_t _drawSerialNumber;
    NSMutableAttributedString *_innerAttributedText;
    NSMutableArray<HYAsyncLabelAction*> *_tapActions;
    NSMutableArray<HYAsyncLabelAction*> *_longPressActions;
    NSTimer *_longPressTimer;
    CGRect _frameRect;
    NSInteger _debugState;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.delegate = self;
    }
    return self;
}

- (void)dealloc {
    if (_longPressTimer) {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
}

#pragma mark - getter & setter
- (void)setText:(NSString *)text {
    @synchronized(self) {
        if ((_text == text || [_text isEqualToString:text]) && self.layer.contents != nil) {
            return;
        }
        _text = [text copy];
        _innerAttributedText = [[NSMutableAttributedString alloc] initWithString:_text ? _text : @""];
        NSDictionary* textAttributes = [self textAttributes];
        if (textAttributes.count) {
            [_innerAttributedText addAttributes:textAttributes range:NSMakeRange(0, _innerAttributedText.length)];
        }
        [_innerAttributedText addAttributes:[self commonAttributes] range:NSMakeRange(0, _innerAttributedText.length)];
        [self setNeedRedraw];
    }
}

- (void)setTextWithoutRedraw:(NSString *)text {
    if (_text == text || [_text isEqualToString:text]) {
        return;
    }
    _text = [text copy];
    _innerAttributedText = [[NSMutableAttributedString alloc] initWithString:_text ? _text : @""];
    NSDictionary* textAttributes = [self textAttributes];
    if (textAttributes.count) {
        [_innerAttributedText addAttributes:textAttributes range:NSMakeRange(0, _innerAttributedText.length)];
    }
    [_innerAttributedText addAttributes:[self commonAttributes] range:NSMakeRange(0, _innerAttributedText.length)];
    _tapActions = nil;
    _longPressActions = nil;
    [_longPressTimer invalidate];
    _longPressTimer = nil;
    self.layout = nil;
}

- (void)setFrame:(CGRect)frame {
    _frameRect = frame;
    [super setFrame:frame];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    @synchronized(self) {
        if ((_attributedText == attributedText || [_attributedText isEqualToAttributedString:attributedText])  && self.layer.contents != nil) {
            return;
        }
        if (attributedText.length) {
            _innerAttributedText = [attributedText mutableCopy];
        } else {
            _innerAttributedText = [NSMutableAttributedString new];
        }
        _attributedText = [attributedText copy];
        [self handleAttachmentFotText:_innerAttributedText];
        [_innerAttributedText addAttributes:[self commonAttributes] range:NSMakeRange(0, _innerAttributedText.length)];
        [self setNeedRedraw];
    }
}

- (void)setAttributedTextWithoutRedraw:(NSAttributedString*)attributedText {
    if (_attributedText == attributedText || [_attributedText isEqualToAttributedString:attributedText]) {
        return;
    }
    if (attributedText.length) {
        _innerAttributedText = [attributedText mutableCopy];
    } else {
        _innerAttributedText = [NSMutableAttributedString new];
    }
    _attributedText = [attributedText copy];
    [self handleAttachmentFotText:_innerAttributedText];
    [_innerAttributedText addAttributes:[self commonAttributes] range:NSMakeRange(0, _innerAttributedText.length)];
    _tapActions = nil;
    _longPressActions = nil;
    [_longPressTimer invalidate];
    _longPressTimer = nil;
    self.layout = nil;
}

- (HYAsyncLabelLayout*)layout {
    @synchronized(self) {
        if (!_layout) {
            _layout = [HYAsyncLabelLayout layoutWithSize:_frameRect.size
                                           numberOfLines:self.numberOfLines
                                        attributedString:_innerAttributedText
                                             autoFitSize:_autoFitSize
                                       contentEdgeInsets:self.contentEdgeInsets];
            if (self.autoFitSize) {
                if ([[NSThread currentThread] isMainThread]) {
                    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _layout.fitSize.width, _layout.fitSize.height);
                } else {
                    __weak typeof(self)weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.layout.fitSize.width, weakSelf.layout.fitSize.height);
                    });
                }
            }
        }
        return _layout;
    }
}

- (NSInteger)fitNumberOfLines {
    return self.layout.fitNumberOfLines;
}

- (CGSize)fitSize {
    return self.layout.fitSize;
}

- (NSMutableArray<HYAsyncLabelAction*>*)tapActions {
    if (!_tapActions) {
        _tapActions = [NSMutableArray new];
    }
    return _tapActions;
}

- (NSMutableArray<HYAsyncLabelAction*>*)longPressActions {
    if (!_longPressActions) {
        _longPressActions = [NSMutableArray new];
    }
    return _longPressActions;
}

#pragma mark - Private
- (void)setNeedRedraw {
    _tapActions = nil;
    _longPressActions = nil;
    [_longPressTimer invalidate];
    _longPressTimer = nil;
    self.layout = nil;
    [self increaseDrawSerialNumber];
    self.layerState = HYAsyncLabelLayerStateNeedRedraw;
    if ([[NSThread currentThread] isMainThread]) {
        [self.layer setNeedsDisplay];
    } else {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.layer setNeedsDisplay];
        });
    }
}

- (NSDictionary*)textAttributes {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.font) {
        [dict setObject:self.font forKey:NSFontAttributeName];
    }
    if (self.textColor) {
        [dict setObject:self.textColor forKey:NSForegroundColorAttributeName];
    }

    return dict;
}

- (NSDictionary*)commonAttributes {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    if (self.textAlignment != style.alignment) {
        style.alignment = self.textAlignment;
    }
    if (self.lineBreakMode != style.lineBreakMode) {
        style.lineBreakMode = self.lineBreakMode;
    }
    if (self.lineSpacing != style.lineSpacing) {
        style.lineSpacing = self.lineSpacing;
    }
    if (self.minimumLineHeight != 0) {
        style.minimumLineHeight = self.minimumLineHeight;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    return dict;
}

- (void)handleAttachmentFotText:(NSMutableAttributedString*)attributedString {
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (!value || ![value isKindOfClass:[NSTextAttachment class]]) {
            return ;
        }
        NSTextAttachment *attachment = (NSTextAttachment*)value;
        CTRunDelegateRef delegate = [HYAsyncLabelRunDelegate createRunDelegateForAttachment:attachment];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attributedString, CFRangeMake(range.location, range.length), kCTRunDelegateAttributeName, delegate);
        CFRelease(delegate);
    }];
}

- (int32_t )drawSerialNumber {
    return _drawSerialNumber;
}

- (int32_t )increaseDrawSerialNumber {
    return OSAtomicIncrement32(&_drawSerialNumber);
}

#pragma mark - public
- (void)displayIfNeed:(void (^)(void))complete {
    [self drawWithComplete:complete];
}

- (HYAsyncLabelAction *)addTapAction:(void (^)(HYAsyncLabel *, NSUInteger))action range:(NSRange)range {
    HYAsyncLabelAction *hyAsyncLabelAction = [HYAsyncLabelAction new];
    hyAsyncLabelAction.action = action;
    hyAsyncLabelAction.range = range;
    [self.tapActions addObject:hyAsyncLabelAction];
    return hyAsyncLabelAction;
}

- (HYAsyncLabelAction *)addLongPressAction:(void (^)(HYAsyncLabel *, NSUInteger))action range:(NSRange)range {
    HYAsyncLabelAction *hyAsyncLabelAction = [HYAsyncLabelAction new];
    hyAsyncLabelAction.action = action;
    hyAsyncLabelAction.range = range;
    [self.longPressActions addObject:hyAsyncLabelAction];
    return hyAsyncLabelAction;
}

#pragma mark -CALayerDelegate
- (void)displayLayer:(CALayer *)layer {
    [self drawWithComplete:nil];
}

#pragma mark - draw
- (void)drawWithComplete:(void (^)(void))complete {
    if (self.layerState == HYAsyncLabelLayerStateDrawed) {
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete();
            });
        }
        return;
    }
    
    if (self.layerState == HYAsyncLabelLayerStateDrawing) {
        return;
    }
    
    self.layerState = HYAsyncLabelLayerStateDrawing;
    int32_t currentSerialNumber = [self drawSerialNumber];
    __weak typeof(self) weekSelf = self;
    BOOL (^isCanceled)(void) = ^BOOL(void){
        __strong typeof(weekSelf) strongSelf = weekSelf;
        return  strongSelf == nil || currentSerialNumber != [strongSelf drawSerialNumber];
    };
    
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 1) {
        scale = 2;
    }
    BOOL opaque = self.opaque;
    CGRect bounds = self.bounds;
    CGColorRef backgroundColor = (self.backgroundColor.CGColor) ? self.backgroundColor.CGColor : [UIColor whiteColor].CGColor;
    if ([self.backgroundColor isEqual:[UIColor clearColor]]) {
        opaque = NO;
    }
    
    if (self.displaysAsynchronously) {
        dispatch_async(HYAsyncLabelLayerGetDisplayQueue(), ^{
            __strong typeof(weekSelf) strongSelf = weekSelf;
            if (isCanceled()) {
                if (complete) {
                    complete();
                }
                return ;
            }
            CGSize size = strongSelf.autoFitSize ? strongSelf.fitSize : bounds.size;
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (opaque) {
                CGContextSetFillColorWithColor(context, backgroundColor);
                CGContextFillRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
            }
            
            
            [strongSelf drawWithComplete:complete inContext:context rect:CGRectMake(0, 0, size.width, size.height)];
            if (isCanceled()) {
                UIGraphicsEndImageContext();
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCanceled()) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCanceled()) {
                    return;
                }
                weekSelf.layer.contents = (__bridge id)image.CGImage;
                if (complete) {
                    complete();
                }
            });
        });
    } else {
        CGSize size = self.autoFitSize ? self.fitSize : bounds.size;
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, backgroundColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
        [self drawWithComplete:complete inContext:context rect:self.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.layer.contents = (__bridge id)image.CGImage;
        if (complete) {
            complete();
        }
    }
    
}

- (void)drawWithComplete:(void (^)(void))complete inContext:(CGContextRef)context rect:(CGRect)rect {
    [self.layout drawInContext:context rect:rect];
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    do {
        if (!CGRectContainsPoint(CGRectInset(self.bounds, -15.f, -15.f), point) || (!_tapActions.count && !_longPressActions.count)) {
            break;
        }
        
        CFIndex characterIndex = [self.layout characterIndexAtPoint:point];
        if (characterIndex == NSNotFound) {
            break;
        }
        self.currentTapAction = [self tapActionAtCharacterIndex:characterIndex];
        self.currentLongPressAction = [self longPressActionAtCharacterIndex:characterIndex];
        if (!self.currentTapAction && !self.currentLongPressAction) {
            break;
        }
        if (self.currentLongPressAction) {
            [self startLongPressTimer];
        }
        return;
    }while (0);
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    do {
        if (!self.currentTapAction && !self.currentLongPressAction) {
            break;
        }
        
        if (!CGRectContainsPoint(CGRectInset(self.bounds, -15.f, -15.f), point)) {
            break;
        }
        
        CFIndex characterIndex = [self.layout characterIndexAtPoint:point];
        if (characterIndex == NSNotFound) {
            break;
        }
        HYAsyncLabelAction* tapAction = [self tapActionAtCharacterIndex:characterIndex];
        HYAsyncLabelAction* longPressAction = [self longPressActionAtCharacterIndex:characterIndex];
        
        if (self.currentTapAction != tapAction) {
            self.currentTapAction = nil;
        }
        
        if (self.currentLongPressAction && self.currentLongPressAction != longPressAction) {
            [self endLongPressTimer];
            self.currentLongPressAction = nil;
        }
        return;
    }while (0);
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    do {
        if (!self.currentTapAction && !self.currentLongPressAction) {
            break;
        }
        self.currentTapAction = nil;
        if (self.currentLongPressAction) {
            [self endLongPressTimer];
            self.currentLongPressAction = nil;
        }
        return;
    }while (0);
    
    [super touchesCancelled:touches withEvent:event];
    return;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    do {
        if (!self.currentTapAction && !self.currentLongPressAction) {
            break;
        }
    
        if (self.currentLongPressAction) {
            [self endLongPressTimer];
            self.currentLongPressAction = nil;
        }
        
        if (self.currentTapAction) {
            if (self.currentTapAction.action) {
                self.currentTapAction.action(self, self.currentTapAction.location);
            }
            self.currentTapAction = nil;
        }
        return;
    }while (0);
    [super touchesEnded:touches withEvent:event];
}

- (HYAsyncLabelAction*)tapActionAtCharacterIndex:(CFIndex)index {
    HYAsyncLabelAction *action = nil;
    for(HYAsyncLabelAction * item in _tapActions) {
        if (NSLocationInRange(index, item.range)) {
            action = item;
            action.location = index;
            break;
        }
    }
    return action;
}

- (HYAsyncLabelAction*)longPressActionAtCharacterIndex:(CFIndex)index {
    HYAsyncLabelAction *action = nil;
    for(HYAsyncLabelAction * item in _longPressActions) {
        if (NSLocationInRange(index, item.range)) {
            action = item;
            action.location = index;
            break;
        }
    }
    return action;
}

- (void)startLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressMinimumDuration
                                              target:[HYWeakProxy proxyWithTarget:self]
                                            selector:@selector(trackDidLongPress)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)endLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = nil;
}

- (void)trackDidLongPress {
    HYAsyncLabelAction *longPressAction = self.currentLongPressAction;
    [self endLongPressTimer];
    if (longPressAction) {
        if (longPressAction.action) {
            longPressAction.action(self, longPressAction.location);
        }
    }
}

@end
