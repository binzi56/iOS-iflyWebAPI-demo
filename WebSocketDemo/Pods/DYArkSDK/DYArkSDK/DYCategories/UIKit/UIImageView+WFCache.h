//
//  UIImageView+WFCache.h
//  kiwi
//
//  Created by liyipeng on 16/2/18.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (WFCache)

- (void)wf_setImageWithURL:(NSString *)urlStr;

- (void)wf_setImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder;

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed;

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
             refreshCached:(BOOL)refreshCached
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed;

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
             refreshCached:(BOOL)refreshCached
                  progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize))progress
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed;

- (void)wf_setBlurImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder;

- (void)wf_setCircleImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder;

- (void)wf_cancelCurrentRequest;

@end

@interface UIButton (WFCache)

- (void)wf_setImageWithURL:(NSString *)urlStr forState:(UIControlState)state placeholder:(UIImage *)placeholder;

- (void)wf_setBackgroundImageWithURL:(NSString *)urlStr forState:(UIControlState)state placeholder:(UIImage *)placeholder;

@end

@interface UIImage (Cache)

+ (void)wf_cacheImageWithUrl:(NSString *)url completed:(void (^)(UIImage *image, NSError *error))completed;

+ (void)wf_cacheImageWithUrl:(NSString *)url qualityOfService:(NSQualityOfService)qualityOfService completed:(void (^)(UIImage *image, NSError *error))completed;

+ (UIImage *)wf_cacheImageForUrl:(NSString *)url;

@end
