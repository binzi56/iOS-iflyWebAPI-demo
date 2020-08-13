////  HYFCollectionViewEvent.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

typedef NS_ENUM(NSInteger, ETCollectionViewEventType) {
    ETCollectionViewEventTypeDidSelectRowAtIndexPath = 1,
};

@interface HYFCollectionViewEvent : HYFEventBase

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                         delegate:(id<UICollectionViewDelegate>)delegate
                        indexPath:(NSIndexPath*)indexPath
                             type:(ETCollectionViewEventType) type;

@end
