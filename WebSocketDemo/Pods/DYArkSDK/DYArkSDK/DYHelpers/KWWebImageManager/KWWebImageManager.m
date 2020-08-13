//
//  KWWebImageManager.m
//  kiwi
//
//  Created by Gideon on 2016/11/2.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "KWWebImageManager.h"
//#import "YYWebImage/YYWebImage.h"
#import "YYWebImage.h"

@implementation KWWebImageManager

+ (instancetype)sharedObject
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)requestImageWithURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSURL *url, NSError *error))completion
{
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:urlString]
                                                   options:0
                                                  progress:nil
                                                 transform:nil
                                                completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                    if (completion){
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            completion(image, url, error);
                                                        });
                                                    }
                                                }];
}

- (void)removeAllWebImageCacheObject
{
    [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
}

- (uint64_t)diskTotalCost
{
    return [[YYWebImageManager sharedManager].cache.diskCache totalCost];
}

- (void) setCacheCostLimit:(uint64_t)cacheCostLimit
{
    [YYWebImageManager sharedManager].cache.diskCache.costLimit = (NSUInteger)cacheCostLimit;
}

- (uint64_t)cacheCostLimit
{
    return [[YYWebImageManager sharedManager].cache.diskCache costLimit];
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key readMemeryOnly:(BOOL)readMemeryOnly
{
    return [[YYWebImageManager sharedManager].cache getImageForKey:key withType:(readMemeryOnly ? YYImageCacheTypeMemory : YYImageCacheTypeAll)];
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key
{
    if (!image || ![key length]) {
        return;
    }
    
    [[YYWebImageManager sharedManager].cache setImage:image forKey:key];
}

@end
