////  HYFEventBase.m
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import "HYFEventBase.h"

#import <libkern/OSAtomic.h>

@implementation ETTraceObject

- (instancetype)initWithObject:(NSObject*)object {
    if (self = [super init]) {
        if (object) {
            self.objectClass = object.class;
            self.objectAddress = (__bridge void*)object;
        } else {
            self.objectClass = Nil;
            self.objectAddress = (void*)0;
        }
    }
    return self;
}

- (void)setupWithObject:(NSObject*)object {
    if (object) {
        self.objectClass = object.class;
        self.objectAddress = (__bridge void*)object;
    }
}

- (NSString*)objectDescription {
    return [NSString stringWithFormat:@"%@(%p)", NSStringFromClass(self.objectClass), self.objectAddress];
}

@end

@implementation HYFEventBase
{
    NSDate *_data;
}

+ (NSDateFormatter*)dataFormatter {
    static NSDateFormatter *s_ETDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_ETDateFormatter = [NSDateFormatter new];
        [s_ETDateFormatter setDateFormat:@"MM-dd HH:mm:ss.SSS"];
    });
    return s_ETDateFormatter;
}

- (instancetype)init {
    if (self = [super init]) {
        _leftBorder = @"<";
        _rightBorder = @">";
        _data = [NSDate date];
    }
    
    return self;
}

- (ETTraceObject*)tracedObj {
    if (!_tracedObj) {
        _tracedObj = [ETTraceObject new];
    }
    return _tracedObj;
    
}

- (NSString*)formatDate {
    return [[HYFEventBase dataFormatter] stringFromDate:_data];
}

- (NSString*)eventDescription {
    return nil;
}

- (NSMutableString*)baseDescription {
    return [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"seq:%-6ld %@ event:", (long)self.sequence, [self formatDate]]];
}

@end
