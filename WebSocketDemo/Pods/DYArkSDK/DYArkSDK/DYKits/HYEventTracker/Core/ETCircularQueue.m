////  ETCircularQueue.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/10.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "ETCircularQueue.h"

@implementation ETCircularQueue{
    NSMutableArray *_container;
    NSUInteger _capacity;
    NSInteger _begin;
    NSInteger _end;
}

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        _capacity = capacity;
        _container = [NSMutableArray arrayWithCapacity:_capacity];
        for (NSInteger i = 0; i < _capacity; ++i) {
            [_container addObject:[NSNull null]];
            _end = 0;
            _begin = 0;
        }
    }
    return self;
}

- (void)addObject:(id)object {
    _container[_end % _capacity] = object;
    _end += 1;
    if (_end - _begin > _capacity) {
        _begin += 1; //如果满了，则覆盖第一个object
    } else if (_end < 0) {
        _begin = 0;//溢出了简单归零处理，NSInteger几乎不可能溢出
        _end = 0;
    }
}

- (NSUInteger)count {
    return _end - _begin;
}

- (void)reverseEnumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    if (_end <= _begin) {
        return;
    }
    
    BOOL stop = NO;
    for (NSInteger i = _end - 1; i >= _begin; --i) {
        id obj = _container[i % _capacity];
        block(obj, i - _begin, &stop);
        if (stop) {
            break;
        }
    }
}
@end
