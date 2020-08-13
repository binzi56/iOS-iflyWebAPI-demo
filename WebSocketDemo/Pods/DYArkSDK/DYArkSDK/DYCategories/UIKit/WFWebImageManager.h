//
//  WFWebImageManager.h
//  kiwi
//
//  Created by Gideon on 2016/11/2.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFWebImageManager : NSObject

@property (nonatomic, assign) uint64_t cacheCostLimit;
@property (nonatomic, assign, readonly) uint64_t diskTotalCost;

+ (instancetype)sharedObject;

- (void)requestImageWithURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSURL *url, NSError *error))completion;

- (void)removeAllWebImageCacheObject;

/**
 *  @brief 获取缓存图片，
 *  @param key
 *  @param readMemeryOnly YES时只从内存查找，不去磁盘查找，磁盘IO操作较耗时
 *  @return image or nil
 */
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key readMemeryOnly:(BOOL)readMemeryOnly;

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

@end
