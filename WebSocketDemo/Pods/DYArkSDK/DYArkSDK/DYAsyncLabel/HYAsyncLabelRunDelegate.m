////  HYAsyncLabelRunDelegate.m
//  AsyncDemo
//
//  Created by Haisheng Ding on 2018/6/26.
//  Copyright © 2018年 dhs. All rights reserved.
//

#import "HYAsyncLabelRunDelegate.h"
#import "HYAsyncLabel.h"

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

static CGFloat HYAsyncLabelRunDelegateGetAscentCallback(void *refCon) {
    HYAsyncLabelRunDelegate * hyAsyncLabelRunDelegate = (__bridge HYAsyncLabelRunDelegate*)refCon;
    return hyAsyncLabelRunDelegate.bounds.size.height;
}
static CGFloat HYAsyncLabelRunDelegateGetDescentCallback(void *refCon) {
    return 0;
}
static CGFloat HYAsyncLabelRunDelegateGetWidthCallback(void *refCon) {
    HYAsyncLabelRunDelegate * hyAsyncLabelRunDelegate = (__bridge HYAsyncLabelRunDelegate*)refCon;
    return hyAsyncLabelRunDelegate.bounds.size.width;
}
static void HYAsyncLabelRunDelegateDeallocateCallback(void *refCon) {
    HYAsyncLabelRunDelegate * hyAsyncLabelRunDelegate = (__bridge_transfer HYAsyncLabelRunDelegate*)refCon;
    hyAsyncLabelRunDelegate = nil;
}


@implementation HYAsyncLabelRunDelegate

+ (CTRunDelegateRef)createRunDelegateForAttachment:(NSTextAttachment *)attachment {
    HYAsyncLabelRunDelegate * hyAsyncLabelRunDelegate= [HYAsyncLabelRunDelegate new];
    if ([attachment isKindOfClass:[HYTextAttachment class]]) {
        HYTextAttachment *hyTextAttachment = (HYTextAttachment*)attachment;
        hyAsyncLabelRunDelegate.contentsInsets = hyTextAttachment.contentsInsets;
    }
    hyAsyncLabelRunDelegate.image = attachment.image;
    hyAsyncLabelRunDelegate.bounds = attachment.bounds;
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.getAscent = HYAsyncLabelRunDelegateGetAscentCallback;
    callbacks.getDescent = HYAsyncLabelRunDelegateGetDescentCallback;
    callbacks.getWidth = HYAsyncLabelRunDelegateGetWidthCallback;
    callbacks.dealloc = HYAsyncLabelRunDelegateDeallocateCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void*)hyAsyncLabelRunDelegate);
    return delegate;
}

@end
