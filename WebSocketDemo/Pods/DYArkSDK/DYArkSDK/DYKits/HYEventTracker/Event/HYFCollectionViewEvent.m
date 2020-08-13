////  HYFCollectionViewEvent.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFCollectionViewEvent.h"

@implementation HYFCollectionViewEvent
{
    ETTraceObject* _delegate;
    NSIndexPath *_indexPath;
    ETCollectionViewEventType _type;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                              delegate:(id<UICollectionViewDelegate>)delegate
                             indexPath:(NSIndexPath*)indexPath
                                  type:(ETCollectionViewEventType) type {
    if (self = [super init]) {
        if (collectionView) {
            [self.tracedObj setupWithObject:collectionView];
        }
        
        if (delegate && [delegate conformsToProtocol:@protocol(UICollectionViewDelegate)] ) {
            _delegate = [[ETTraceObject alloc] initWithObject:delegate];
        }
        
        if (indexPath) {
            _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        }
        _type = type;
    }
    
    return self;
}

- (NSString*)eventDescription {
    NSMutableString * des = [super baseDescription];
    [des appendString:self.leftBorder];
    [des appendString:[NSString stringWithFormat:@"%@ delegate:%@ %@: %@", [self.tracedObj objectDescription], [_delegate objectDescription], [self stringFromEventType], _indexPath]];
    [des appendString:self.rightBorder];
    return des;
}

- (NSString*)stringFromEventType {
    NSString *str = nil;
    switch (_type) {
        case ETCollectionViewEventTypeDidSelectRowAtIndexPath:
            str = @"didSelectRowAtIndexPath";
            break;
            
        default:
            break;
    }
    return str;
}
@end
