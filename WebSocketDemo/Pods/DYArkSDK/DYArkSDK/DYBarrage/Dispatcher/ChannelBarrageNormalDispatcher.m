//
//  ChannelBarrageNormalDispatcher.m
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import "ChannelBarrageNormalDispatcher.h"
#import "ChannelBarrageItem.h"

#import "CircularQueue.h"
#import "NSTimer+YYAdd.h"
#import "ChannelBarrageHelper.h"
#import "NSArray+DY.h"
#import "HYLogMacros.h"
#import "NSMutableArray+YYAdd.h"
#import "KiwiSDKMacro.h"
#import "UiUtils.h"
#import "UIView+YYAdd.h"

#define kBottomViewTag  10086
#define kTopViewTag     4399

//TODO:调整speed
//TODO:重构：抽象多个Datasource

static const CGFloat kCanvasVerTopMargin          = 10.0;
static const CGFloat kCanvasTopMargin             = 23.0;
static const CGFloat kCanvasBottomMargin          = 8.0;
static const CGFloat kActiveItemVSpacing          = 1.0;
static const CGFloat kMinActiveItemsVSpacing      = 20.0;
static const CGFloat kMinActiveItemsHSpacing      = 10.0;

static const NSUInteger kSimpleModeLabelLineCount = 5;
static const NSUInteger kVerSimpleModeLabelLineCount = 3;

static const NSUInteger kMaxWaitingItemCount                    = 400;    //最多存400条
static const NSUInteger kMinWaitingItemCount                    = 40;     //最少存40条
static const NSUInteger kWaitingItemCountPerLine                = 20;     //每个通道存20条
static const NSUInteger kMaxWaitingItemCountForLowPerformance   = 40;     //低配最多存40条

static const NSUInteger kTotalAccelerateItemCount = 1;      //缓存超过则整体加速
static const NSUInteger kAccelerateItemCount      = 35;     //超过就启动加速
static const NSUInteger kRemovedWaitingItemCount  = 20;

static const NSUInteger kDoubleWhenItemCountGreatThan = 71; //缓存大于71时开启双行
static const NSUInteger kSingleWhenItemCountLessThan = 13;  //缓存小于13时恢复单行

static const NSUInteger kMaxBarrageCount          = 100;    //缓存100条弹幕

static const CGFloat kGroupGiftBarrageHeight = 24;

static const NSInteger kBaseItemLineCount = 22;     //以22为基数判断要丢弃多少
static const NSInteger kStartDropWaitingItemCount = 10; //缓存大于10的时候开始丢弃

@interface CBActiveItemLine : NSObject

@property (nonatomic, strong) NSMutableArray *activeItems;  //TODO:优化结构
@property (nonatomic, weak) ChannelBarrageItem *lastActiveItem;
@property (nonatomic, assign) BOOL isEmpty;

@end

@implementation CBActiveItemLine

- (BOOL)isEmpty
{
    return self.activeItems.count == 0;
}

@end

@interface ChannelBarrageNormalDispatcher ()

@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) UIView *bottomCanvasView;
@property (nonatomic, strong) UIView *topCanvasView;
@property (nonatomic, assign) CGFloat labelFontSize;
@property (nonatomic, assign) CGFloat activeItemHeight;
@property (nonatomic, strong) NSMutableArray *activeItemLines;
@property (nonatomic, strong) CircularQueue *waitingItems;

@property (nonatomic, assign) int lostBarrageCnt;
@property (nonatomic, strong) CircularQueue *queue; //缓存最近100条弹幕
@property (nonatomic, assign) BOOL isSingle;        //是不是开启单行
@property (nonatomic, assign) int dropCnt;          //每次丢弃个数

@end

@implementation ChannelBarrageNormalDispatcher

@synthesize fontSize = _fontSize;
@synthesize portrait = _portrait;
@synthesize delegate = _delegate;

#pragma mark - LifeCycle

- (void)dealloc
{
    [self clearItems];
    [self reportLostBarrageIfNeed];
    KWSLogInfo(@"dealloc");
}

- (instancetype)initWithCanvasView:(UIView *)canvasView mode:(ChannelBarrageMode)mode fontSize:(ChannelBarrageFontSize)fontSize portrait:(BOOL)isPortrait
{
    self = [super init];
    if (self) {
        _canvasView = canvasView;
        _mode = mode;
        _portrait = isPortrait;
        _isSingle = YES;
        [self updateFontSize:fontSize];
        
        //TODO:必要时延时加载
        const NSUInteger lineCount = [self availableLineCount];
        _activeItemLines = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < lineCount; ++i) {
            CBActiveItemLine *line = [CBActiveItemLine new];
            line.activeItems = [[NSMutableArray alloc] init];
            [_activeItemLines addObject:line];
        }
        
        _waitingItems = [[CircularQueue alloc] initWithLength:kMaxWaitingItemCount + 1 removeObjectWhenFull:NO];
        
        _queue = [[CircularQueue alloc] initWithLength:kMaxBarrageCount removeObjectWhenFull:NO];
        
        [self updateDropCnt];
        [self setupCanvasView];
        
        KWSLogInfo(@"init");
    }
    return self;
}

#pragma mark - Public

- (void)reportLostBarrageIfNeed
{
    if (self.lostBarrageCnt > 0) {
        if ([self.delegate respondsToSelector:@selector(reportLostBarrageWithCount:)]) {
            [self.delegate reportLostBarrageWithCount:self.lostBarrageCnt];
        }
        self.lostBarrageCnt = 0;
    }
}

- (NSArray *)getReportBarrageListWithPoint:(CGPoint)point
{
    static CGFloat touchRadius = 50.0;
    CGRect touchRect = CGRectMake(point.x - touchRadius, point.y - touchRadius, touchRadius * 2, touchRadius * 2);
    NSMutableArray *intersectsArray = [NSMutableArray array];
    for (int i = 0; i < [self.activeItemLines count]; i ++) {
        CBActiveItemLine *line = [self.activeItemLines safeObjectAtIndex:i];
        for (int j = 0; j < [line.activeItems count]; j++) {
            ChannelBarrageItem *item = [line.activeItems safeObjectAtIndex:j];
            if (![item needReport]) {
                continue;
            }
            CGRect itemFrame = [item itemFrame];
            if (CGRectIntersectsRect(touchRect, itemFrame)) {
                [intersectsArray safeAddObject:item.info];
            }
        }
    }
    return intersectsArray;
}

- (NSArray *)getReportBarrageListByRecently
{
    NSMutableArray *reportArray = [NSMutableArray array];
    const CFTimeInterval currentTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < self.queue.count; i++) {
        ChannelBarrageItem *item = [self.queue objectAtIndex:i];
        if (![item needReport]) {
            continue;
        }
        CFTimeInterval duration = item.appearance.duration.floatValue;
        if (currentTime - (duration + item.timestamp) < 15.0) { //获取前15秒内的弹幕
            [reportArray safeAddObject:item.info];
        }
    }
    return reportArray;
}

#pragma mark - Property

- (void)setMode:(ChannelBarrageMode)mode
{
    if (_mode != mode) {
        _mode = mode;
        [self changeLineCount:[self availableLineCount]];
    }
}

- (void)setFontSize:(ChannelBarrageFontSize)fontSize
{
    [self updateFontSize:fontSize];
    
    //[NOTE] 字号变化后的可用行数可能会发生变化
    [self changeLineCount:[self availableLineCount]];
}

- (void)setPortrait:(BOOL)portrait
{
    _portrait = portrait;
    [self updateCanvasTop];
//    [self updateItemTop];
//    [self updateBarrageDuration];
}

- (void)updateBarrageDuration
{
    for (int i = 0; i < [self.waitingItems count]; i++) {
        ChannelBarrageItem *item = [self.waitingItems objectAtIndex:i];
        item.appearance.duration = @([self itemDuration]);
    }
}

- (NSTimeInterval)itemDuration
{
    NSTimeInterval duration = [self adjustItemDuration];
    return duration;
}

//弹幕互动优化
- (NSTimeInterval)adjustItemDuration
{
    //对于低配设备不加速不随机
    if ([self.delegate respondsToSelector:@selector(isLowPerformanceDevice)] && [self.delegate isLowPerformanceDevice]) {
        return kNormalBarrageDuration;
    }
    
    NSTimeInterval duration = self.portrait ? kNormalPortraitBarrageDuration : kNormalBarrageDuration;
    //先整体加速
    int diff = (int)[self.waitingItems count] - kTotalAccelerateItemCount;
    if (diff > 0) {
        diff = MIN(diff, 75);
        duration = duration * (1.0 - (0.35 * diff) / 75);
    }
    
    
    //这个算法是由梦佳跟安卓同学对的
    //如果等待的弹幕多于35开启加速
    if ([self.waitingItems count] < kAccelerateItemCount) {
        return duration;
    }
    int s = (arc4random() % 100) % 36 + 65;
    if (s > 77) {
        s = (100 + s) / 2;
    }
    duration = duration * s / 100;
    if (duration < 4.5) { //弹幕最短时间是4.5s
        duration = 4.5;
    }

    return duration;
}

#pragma mark - ChannelBarrageDispatcher

- (void)prependItem:(ChannelBarrageItem *)item
{
    [self clearWaitingItemsIfNeeded];
    [self.waitingItems addObjectInFront:item];
    [self changeSingleModeIfNeed];
}

- (void)appendItem:(ChannelBarrageItem *)item
{
    [self clearWaitingItemsIfNeeded];
    [self.waitingItems addObject:item];
    [self changeSingleModeIfNeed];
}

- (void)clearItems
{
    [self.activeItemLines enumerateObjectsUsingBlock:^(CBActiveItemLine *line, NSUInteger idx, BOOL *stop) {
        [line.activeItems enumerateObjectsUsingBlock:^(ChannelBarrageItem *item, NSUInteger idx, BOOL *stop) {
            [item deactive];
        }];
        [line.activeItems removeAllObjects];
    }];
    
    [self.waitingItems clear];
    [self.queue clear];
}

- (NSUInteger)getItemCountInSixthLine
{
    
    NSInteger flag = self.isSingle ? 10 : 5;
    if (self.activeItemLines.count <= flag) {
        return 0;
    }
    CBActiveItemLine *line = [self.activeItemLines objectAtIndex:flag];
    return line.activeItems.count;
    
}

- (void)clearBarrageItemsForClass:(Class)aClass {
    [self.activeItemLines enumerateObjectsUsingBlock:^(CBActiveItemLine *line, NSUInteger idx, BOOL *stop) {
        for (ChannelBarrageItem *item in line.activeItems.reverseObjectEnumerator) {
            
            if ([item isKindOfClass:aClass]) {
                [item deactive];
                [line.activeItems removeObject:item];;
            }
        }
    }];
    
    CircularQueue *tmpQueue = [[CircularQueue alloc] initWithLength:(int)[self.waitingItems count] removeObjectWhenFull:NO];
    
    for (int i = 0; i < [self.waitingItems count]; i++) {
        ChannelBarrageItem *item = [self.waitingItems objectAtIndex:i];
        if (![item isKindOfClass:aClass]) {
            [tmpQueue addObject:item];
        }
    }
    [self.waitingItems clear];
    [self.waitingItems addObjectsFromCircularQueue:tmpQueue];
}

- (void)updateWithTime:(CFTimeInterval)time interval:(CFTimeInterval)interval
{
    //[NOTE] 清除失效Label
    [self.activeItemLines enumerateObjectsUsingBlock:^(CBActiveItemLine *line, NSUInteger idx, BOOL *stop) {
        if ([line.activeItems count] == 0) {
            return;
        }
        
        NSMutableIndexSet *invalidItems = [[NSMutableIndexSet alloc] init];
        [line.activeItems enumerateObjectsUsingBlock:^(ChannelBarrageItem *item, NSUInteger idx, BOOL *stop) {
            if (!item.valid) {
                [item deactive];
                [invalidItems addIndex:idx];
            }
        }];
        if ([invalidItems count] > 0) {
            [line.activeItems removeObjectsAtIndexes:invalidItems];
        }
    }];
    
    //[NOTE] 从等待队列中取得Label激活
    if (interval >= 0.0) {
        NSArray *avalidLineList = [self avalidIdleLineIndexList];
        if ([avalidLineList count] > 0) {
            for (int i = 0; i < [avalidLineList count]; i++) {
                if ([self.waitingItems isEmpty]) {
                    break;
                }
                ChannelBarrageItem *item = [self.waitingItems objectAtIndex:0];
                NSInteger index = [[avalidLineList safeObjectAtIndex:i] integerValue];
                
                //弹幕弹道显示类型
                if ([item lineType] != ChannelBarrageLineTypeDefault && index % 2 != [item lineType]) {
                    break;
                }
                
                if ([self.waitingItems count] > kStartDropWaitingItemCount && self.dropCnt > 0) {
                    [self.waitingItems removeFrontObjectWithCount:self.dropCnt];
                }
                item.appearance.duration = @([self itemDuration]);
                
                CBActiveItemLine *line = self.activeItemLines[index];
                [line.activeItems addObject:item];
                if ([self.waitingItems count] < kAccelerateItemCount && line.lastActiveItem) {
                    item.appearance.lastItemWidth = CGRectGetWidth([line.lastActiveItem itemFrame]);
                } else {
                    item.appearance.lastItemWidth = 0;
                }
                line.lastActiveItem = item;
    
                NSNumber *timestamp = @(time);
                CGPoint point = [self originForLineIndex:index];
                NSValue *origin = [NSValue valueWithCGPoint:point];
                NSValue *bounds = [NSValue valueWithCGRect:self.canvasView.bounds];
                NSDictionary *context = @{kCBContextTimestamp : timestamp,
                                          kCBContextLabelFontSize : @(self.labelFontSize),
                                          kCBContextLabelOrigin : origin,
                                          kCBContextCanvasBounds : bounds};
                UIView *canvasView = [self canvasViewForItem:item];
                [item activeWithCanvasView:canvasView context:context];
                
                [self.queue addObject:[self.waitingItems objectAtIndex:0]];
                [self.waitingItems removeFirstObject];
            }
        }
    }
}

#pragma mark - Private

- (UIView*)canvasViewForItem:(ChannelBarrageItem*)item {
    if ([item viewLevel] == ChannelBarrageViewLevelTop) {
        return self.topCanvasView;
    } else {
        return self.bottomCanvasView;
    }
}

- (NSUInteger)maxWaitingItemCount
{
    if ([self.delegate respondsToSelector:@selector(isLowPerformanceDevice)] && [self.delegate isLowPerformanceDevice]) {
        return kMaxWaitingItemCountForLowPerformance;
    }
    
    return LimitValueAtRange(kMinWaitingItemCount, kWaitingItemCountPerLine * [self.activeItemLines count], kMaxWaitingItemCount);
}

- (void)clearWaitingItemsIfNeeded
{
    if ([self.waitingItems count] > [self maxWaitingItemCount]) {
        [self.waitingItems removeFrontObjectWithCount:kRemovedWaitingItemCount];
        ++self.lostBarrageCnt;
        KWSLogInfo(@"[ChannelText: OutRange]clearWaitingItemsIfNeeded, %lu", (unsigned long)kRemovedWaitingItemCount);
    }
}

- (void)updateFontSize:(ChannelBarrageFontSize)fontSize
{
    _fontSize = fontSize;
    switch (_fontSize) {
        case ChannelBarrageFontSizeSmall:
            if (_portrait) {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barragePortraitLabelSmallDimension)] ? [self.delegate respondsToSelector:@selector(barragePortraitLabelSmallDimension)] : kCBLabelPortraitSmallDimension;
            } else {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barrageLabelSmallDimension)] ? [self.delegate respondsToSelector:@selector(barrageLabelSmallDimension)] : kCBLabelSmallDimension;
            }
            break;
        case ChannelBarrageFontSizeLarge:
            if (_portrait) {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barragePortraitLabelLargeDimension)] ? [self.delegate respondsToSelector:@selector(barragePortraitLabelLargeDimension)] : kCBLabelPortraitLargeDimension;
            } else {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barrageLabelLargeDimension)] ? [self.delegate respondsToSelector:@selector(barrageLabelLargeDimension)] : kCBLabelLargeDimension;
            }
            break;
        case ChannelBarrageFontSizeNormal:
        default:
            if (_portrait) {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barragePortraitLabelNormalDimension)] ? [self.delegate respondsToSelector:@selector(barragePortraitLabelNormalDimension)] : kCBLabelNormalDimension;
            } else {
                self.activeItemHeight = [self.delegate respondsToSelector:@selector(barrageLabelNormalDimension)] ? [self.delegate respondsToSelector:@selector(barrageLabelNormalDimension)] : kCBLabelNormalDimension;
            }
           
            break;
    }

    CGFloat actualFontSize = [ChannelBarrageHelper actualBarrageFontSizeWithFont:fontSize videoVertical:_portrait];
    self.labelFontSize = actualFontSize;
}

- (CGFloat)itemVSpacing
{
    CGFloat itemSpacing = kActiveItemVSpacing;
    if (IS_IPHONE_HEIGHT_OVER_736) {
        itemSpacing = 14;
    }else if (IS_IPHONE_HEIGHT_667) {
        itemSpacing = 10;
    }
    return itemSpacing;
}

- (NSUInteger)availableLineCount
{
    if (_mode == ChannelBarrageModeNormal) {
        const CGFloat availableHeight = CGRectGetHeight(self.canvasView.frame) - (self.portrait ? kCanvasVerTopMargin : kCanvasTopMargin) - kCanvasBottomMargin;
        if (availableHeight > 0.0) {
            return floor((availableHeight + kActiveItemVSpacing) / (self.activeItemHeight + kActiveItemVSpacing));
        } else {
            return 0;
        }
        
    } else if (_mode == ChannelBarrageModeSimple) {
        return self.portrait ? kVerSimpleModeLabelLineCount : kSimpleModeLabelLineCount;
    } else {
        return 0;
    }
}

//取出所有可追加的行
- (NSArray *)avalidIdleLineIndexList
{
    NSMutableArray *emptyLineList = [NSMutableArray array];
    NSMutableArray *canAppendList = [NSMutableArray array];
    
    //[NOTE] 空闲行：1、没有文本；2、此行最近添加的文本距离屏幕的右边距不小于最小边距；3、s1 - s2 = (v1 - v2) * t（TODO：避免追及）
    const CGFloat canvasWidth = CGRectGetWidth(self.canvasView.frame);
    
    CGFloat spacing = self.portrait ? kMinActiveItemsVSpacing : kMinActiveItemsHSpacing;
    for (int i = 0; i < [self.activeItemLines count]; i+= self.isSingle ? 2 : 1) {
        CBActiveItemLine *line = [self.activeItemLines safeObjectAtIndex:i];
    
        //产品要求前7行如果有空行则直接加到空行上面
        if ([line isEmpty] && i < 7 && (i % 2 == 0)) {
            [emptyLineList safeAddObject:@(i)];
        } else if (line.lastActiveItem == nil || canvasWidth - CGRectGetMaxX([line.lastActiveItem itemFrame]) >= spacing) {
            [canAppendList safeAddObject:@(i)];
        }
    }
    return [emptyLineList arrayByAddingObjectsFromArray:canAppendList];
}

- (NSUInteger)idleLineIndex
{
    __block NSUInteger index = NSNotFound;
    
    if (self.mode == ChannelBarrageModeNormal) {
        //产品要求前5行如果有空行则直接加到空行上面
        //否则按照原来的逻辑
        for (int i = 0; i < 5; i++) {
            CBActiveItemLine *line = [self.activeItemLines safeObjectAtIndex:i];
            if (line.isEmpty) {
                index = i;
                break;
            }
        }
    }
    
    if (index == NSNotFound) {
        
        //TODO:优化：等待队列项数较少时不需要取出所有空闲的
        //[NOTE] 空闲行：1、没有文本；2、此行最近添加的文本距离屏幕的右边距不小于最小边距；3、s1 - s2 = (v1 - v2) * t（TODO：避免追及）
        const CGFloat canvasWidth = CGRectGetWidth(self.canvasView.frame);

        CGFloat spacing = self.portrait ? kMinActiveItemsVSpacing : kMinActiveItemsHSpacing;
        [self.activeItemLines enumerateObjectsUsingBlock:^(CBActiveItemLine *line, NSUInteger idx, BOOL *stop) {
            if (line.lastActiveItem == nil
                || canvasWidth - CGRectGetMaxX([line.lastActiveItem itemFrame]) >= spacing) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

- (CGPoint)originForLineIndex:(NSUInteger)index
{
    CGFloat itemSpacing = kActiveItemVSpacing;
    
    CGFloat topMargin = 0;// self.portrait ? kCanvasVerTopMargin : kCanvasTopMargin;
    
    return CGPointMake(CGRectGetWidth(self.canvasView.frame),
                       topMargin + (self.activeItemHeight + itemSpacing) * index + self.activeItemHeight / 2.0);
}

- (CGPoint)adjustGroupGiftOrigin:(CGPoint)origin
{
    CGPoint point = origin;
    CGFloat height = self.activeItemHeight + kActiveItemVSpacing;
    point.y -= (kGroupGiftBarrageHeight - height)/2;
    return point;
}

- (void)changeLineCount:(NSUInteger)newLineCount
{
    const NSUInteger currentLineCount = [self.activeItemLines count];
    if (newLineCount > currentLineCount) {
        NSUInteger addLineCount = newLineCount - currentLineCount;
        for (NSUInteger i = 0; i < addLineCount; ++i) {
            CBActiveItemLine *line = [CBActiveItemLine new];
            line.activeItems = [[NSMutableArray alloc] init];
            [self.activeItemLines addObject:line];
        }
    } else if (newLineCount < currentLineCount) {
        for (NSUInteger i = newLineCount; i < currentLineCount; ++i) {
            CBActiveItemLine *line = self.activeItemLines[i];
            [line.activeItems enumerateObjectsUsingBlock:^(ChannelBarrageItem *item, NSUInteger idx, BOOL *stop) {
                [item deactive];
            }];
            [line.activeItems removeAllObjects];
        }
        [self.activeItemLines removeObjectsInRange:NSMakeRange(newLineCount, currentLineCount - newLineCount)];
    }
    
    [self updateDropCnt];
}

- (void)changeSingleModeIfNeed
{
    if (self.isSingle) {
        if ([self.waitingItems count] >= kDoubleWhenItemCountGreatThan) {
            self.isSingle = NO;
        }
    } else {
        if ([self.waitingItems count] <= kSingleWhenItemCountLessThan) {
            self.isSingle = YES;
        }
    }
}

- (void)updateItemTop
{
    for (int i = 0; i < [self.activeItemLines count]; i ++) {
        CBActiveItemLine *line = [self.activeItemLines safeObjectAtIndex:i];
        for (int j = 0; j < [line.activeItems count]; j++) {
            ChannelBarrageItem *item = [line.activeItems safeObjectAtIndex:j];
            CGPoint point = [self originForLineIndex:i];
            [item updatePosY:point.y];

        }
    }
}

- (void)updateDropCnt
{
    int availabelLineCount = (int)[self availableLineCount];
    self.dropCnt = kBaseItemLineCount / (availabelLineCount > 0 ? availabelLineCount : kBaseItemLineCount) - 1;
}

- (void)setupCanvasView
{
    UIView *bottomView = [self.canvasView viewWithTag:kBottomViewTag];
    if (bottomView) {
        [bottomView removeFromSuperview];
    }
    bottomView = [[UIView alloc] initWithFrame:self.canvasView.bounds];
    [self.canvasView addSubview:bottomView];
    self.bottomCanvasView = bottomView;
    bottomView.backgroundColor = [UIColor clearColor];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *topView = [self.canvasView viewWithTag:kTopViewTag];
    if (topView) {
        [topView removeFromSuperview];
    }
    topView = [[UIView alloc] initWithFrame:self.canvasView.bounds];
    [self.canvasView addSubview:topView];
    self.topCanvasView = topView;
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self updateCanvasTop];
}

- (void)updateCanvasTop
{
    self.topCanvasView.top = _portrait ? kCanvasVerTopMargin : kCanvasTopMargin;
    self.bottomCanvasView.top = _portrait ? kCanvasVerTopMargin : kCanvasTopMargin;
    
}

@end
