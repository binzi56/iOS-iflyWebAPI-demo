//
//  ChannelBarrageNormalDispatcher.h
//  kiwi
//
//  Created by maihx on 15/10/20.
//  Copyright © 2015年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelBarrageDispatcher.h"

@interface ChannelBarrageNormalDispatcher : NSObject<ChannelBarrageDispatcher>

@property (nonatomic, assign) ChannelBarrageMode mode;

- (void)reportLostBarrageIfNeed;
- (NSArray *)getReportBarrageListWithPoint:(CGPoint)point;
- (NSArray *)getReportBarrageListByRecently;

- (void)clearBarrageItemsForClass:(Class)aClass;
@end
