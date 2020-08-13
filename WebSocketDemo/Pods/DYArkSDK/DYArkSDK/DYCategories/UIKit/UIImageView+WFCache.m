//
//  UIImageView+WFCache.m
//  kiwi
//
//  Created by liyipeng on 16/2/18.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "UIImageView+WFCache.h"
#import "WFWebImageManager.h"
//#import <YYWebImage/UIImageView+YYWebImage.h>
//#import <YYWebImage/UIButton+YYWebImage.h>
#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "UIImage+ImageEffects.h"
#import "KiwiSDKMacro.h"
#import "UIImage+YYAdd.h"

@implementation UIImageView (WFCache)

- (void)wf_setImageWithURL:(NSString *)urlStr
{
    [self wf_setImageWithURL:urlStr placeholder:nil];
}

- (void)wf_setImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    [self wf_setImageWithURL:urlStr placeholder:placeholder completed:nil];
}

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed
{
    [self wf_setImageWithURL:urlStr placeholder:placeholder refreshCached:NO completed:completed];
}

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
             refreshCached:(BOOL)refreshCached
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed
{
    [self wf_setImageWithURL:urlStr placeholder:placeholder refreshCached:refreshCached progress:nil completed:completed];
}

- (void)wf_setImageWithURL:(NSString *)urlStr
               placeholder:(UIImage *)placeholder
             refreshCached:(BOOL)refreshCached
                  progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize))progress
                 completed:(void (^)(UIImage *image, NSError *error, NSURL *imageURL))completed
{
    urlStr     = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self yy_setImageWithURL:url
                 placeholder:placeholder
                     options:refreshCached ?: YYWebImageOptionSetImageWithFadeAnimation
                    progress:progress
                   transform:nil
                  completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from, YYWebImageStage stage,
                               NSError *_Nullable error) {
                      if (completed) {
                          completed(image, error, url);
                      }
                  }];
}

- (void)wf_setBlurImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    NSString *blurUrl = nil;
    
    if ([urlStr length]) {
        //[NOTE] &blur=1对服务器无影响，只是本地图片模糊版本和高清版本cacheKey的区分
        blurUrl = [urlStr stringByAppendingString:@"&blur=1"];
    }
    
    if (blurUrl && [[WFWebImageManager sharedObject] imageFromDiskCacheForKey:blurUrl readMemeryOnly:NO]) {
        //已经有模糊版本的缓存图片，直接显示
        DYLogInfo(@"{Cache} found cache image for url: %@", blurUrl);
        [self wf_setImageWithURL:blurUrl placeholder:placeholder];
    }
    else {
        
        BlockWeakSelf(weakSelf, self);
        DYLogInfo(@"{Cache} will cache image for url: %@", blurUrl);
        [self wf_setImageWithURL:urlStr
                     placeholder:placeholder
                       completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                           
                           if (image && !error) {
                               BlockStrongSelf(strongSelf, weakSelf);
                               
                               //生成模糊图片
                               UIImage *blurImage = [image applyBlurWithRadius:5.0 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
                               
                               if (blurImage) {
                                   strongSelf.image = blurImage;
                                   //保存模糊版本图片，key为blurUrl
                                   [[WFWebImageManager sharedObject] cacheImage:blurImage forKey:blurUrl];
                                   DYLogInfo(@"{Cache} did cache image for url: %@", blurUrl);
                               }
                           }
                       }];
    }
}

- (void)wf_setCircleImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    if (!self.image) self.image = placeholder;
    
    if (!urlStr.length) return;
    
    NSString *circleUrl = nil;
    
    if ([urlStr length]) {
        circleUrl = [urlStr stringByAppendingString:@"?&circle=1"];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *URL                 = [NSURL URLWithString:circleUrl];
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        NSString *key              = [manager cacheKeyForURL:URL];
        if ([manager.cache containsImageForKey:key]) {
            UIImage *image = [manager.cache getImageForKey:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
            return;
        }
        [[YYWebImageManager sharedManager] requestImageWithURL:URL
                                                       options:YYWebImageOptionRefreshImageCache
                                                      progress:nil
                                                     transform:nil
                                                    completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                        UIImage * clrcleImage;
                                                        if (image) {
                                                            clrcleImage = [image imageByRoundCornerRadius:image.size.width/2.f];
                                                            [manager.cache setImage:clrcleImage forKey:key];
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.image = clrcleImage?clrcleImage:placeholder;
                                                        });
                                                    }];
    });
}

- (void)wf_cancelCurrentRequest
{
    [self yy_cancelCurrentImageRequest];
}

@end

#pragma mark -

@implementation UIButton (WFCache)

- (void)wf_setImageWithURL:(NSString *)urlStr forState:(UIControlState)state placeholder:(UIImage *)placeholder
{
    NSURL *url = [NSURL URLWithString:urlStr];
    [self yy_setImageWithURL:url forState:state placeholder:placeholder];
}

- (void)wf_setBackgroundImageWithURL:(NSString *)urlStr forState:(UIControlState)state placeholder:(UIImage *)placeholder
{
    NSURL *url = [NSURL URLWithString:urlStr];
    [self yy_setBackgroundImageWithURL:url forState:state placeholder:placeholder];
}

@end

@implementation UIImage (Cache)

+ (void)wf_cacheImageWithUrl:(NSString *)url completed:(void (^)(UIImage *image, NSError *error))completed
{
    [self wf_cacheImageWithUrl:url qualityOfService:NSQualityOfServiceDefault completed:completed];
}

+ (void)wf_cacheImageWithUrl:(NSString *)url qualityOfService:(NSQualityOfService)qualityOfService completed:(void (^)(UIImage *image, NSError *error))completed
{
    if (!url.length) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *URL                 = [NSURL URLWithString:url];
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        NSString *key              = [manager cacheKeyForURL:URL];
        if ([manager.cache containsImageForKey:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    UIImage *image = [manager.cache getImageForKey:key];
                    completed(image, nil);
                }
            });
            return;
        }
        [[YYWebImageManager sharedManager] requestImageWithURL:URL
                                                       options:YYWebImageOptionIgnoreImageDecoding|YYWebImageOptionIgnoreDiskCache
                                                         scale:2.0f
                                              qualityOfService:qualityOfService
                                                      progress:nil
                                                     transform:nil
                                                    completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (completed) {
                                                                completed(image, error);
                                                            }
                                                        });
                                                    }];
    });
}

+ (UIImage *)wf_cacheImageForUrl:(NSString *)url
{
    if (!url.length) return nil;
    NSURL *URL                 = [NSURL URLWithString:url];
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:URL];
    return [manager.cache getImageForKey:key];
}

@end
