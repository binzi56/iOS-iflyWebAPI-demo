//
//  WFFileResourceManager.h
//  Wolf
//
//  Created by Tim-Macmini on 2017/10/23.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileResourceType) {
    FileResourceType_Unknow,
    FileResourceType_Svga,    // Svga,返回.svga路径,NSString
    FileResourceType_LOT,     // LOT,返回.json路径,NSString
    FileResourceType_Html,    // Html,返回.html路径,NSString
    FileResourceType_Image,   //图片,返回图片,UIImage
    FileResourceType_Images,  //帧动画图集,返回图片数组,NSArray<UIImage*>
};

@interface WFFileResourceManager : NSObject

/**
 下载文件

 @param sourceName 文件名
 @param sourceUrl 链接
 @param completeBlock
 */
+ (void)downloadFileResource:(NSString *)sourceName sourceUrl:(NSString *)sourceUrl completeBlock:(void (^)(BOOL succeed))completeBlock;

/**
 获取文件

 @param sourceName 文件名
 @param fileResourceType 文件类型
 @param completeBlock
 */
+ (void)fileResourceDataWithSourceName:(NSString *)sourceName
                      fileResourceType:(FileResourceType)fileResourceType
                         completeBlock:(void (^)(id fileResource))completeBlock;

/**
 获取文件路径

 @param sourceName 文件名
 */
+ (NSString *)fileResourcePathWithSourceName:(NSString *)sourceName;


/**
 文件是否已下载

 @param sourceUrl 链接
 */
+ (BOOL)downloadedContainsUrl:(NSString *)sourceUrl;

/**
 清除文件资源
 */
+ (void)clearFileResource;

@end
