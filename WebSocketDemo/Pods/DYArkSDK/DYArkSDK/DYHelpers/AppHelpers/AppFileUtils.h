//
//  AppFileUtils.h
//  kiwi
//
//  Created by lslin on 16/9/28.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNotificationAppFileCacheCleaned;

@interface AppFileUtils : NSObject

#pragma mark - File manager methods

+ (NSFileManager *)fileManager;
+ (BOOL)isPathExist:(NSString *)path;
+ (BOOL)isFileExist:(NSString *)path;
+ (BOOL)isDirectoryExist:(NSString *)path;
+ (BOOL)removeFile:(NSString *)path;
+ (BOOL)createPath:(NSString *)path;
+ (NSUInteger)fileCountInPath:(NSString *)path;
+ (unsigned long long)folderSizeAtPath:(NSString *)path;

+ (NSArray*)directoryFilesAtPath:(NSString *)path;

#pragma mark - User directory methods

+ (NSString *)appDocumentPath;
+ (NSString *)appSupportPathForHuya;
+ (NSString *)appResourcePath;
+ (NSString *)appCachePath;
+ (NSString *)appStorageCachePath;

/**
 旧的db缓存目录，因为放在了cache下，在系统磁盘空间不足时会被清掉，所以该目录不再使用，
 迁移到ApplicationSupportDirectory
 */
+ (void)migrateStorages;

+ (NSString *)appResourceCachePath;
+ (NSString *)appZipCachePath;
+ (NSString *)appDropListCatImgsPath;
+ (BOOL)createAppStorageCachePath;
+ (BOOL)createAppSplashCachePath;
+ (BOOL)createAppZipCachePath;
+ (BOOL)createAppResourceCachePath;

/**
 * 本地录制音频文件路径
 */
+ (NSString *)appRecordAudioPath;

/**
 服务器下载缓存路径
 */
+ (NSString *)appDownloadSplashPath;

/**
 * 缓存大小，Cache目录下的 logs、hiidologs、com.hackemist.SDWebImageCache.default 的目录大小，单位为Byte
 */
+ (unsigned long long)appCacheSize;

/**
 * Temp缓存路径，在更改头像时需要用到
 */
+ (NSString *)appCacheTempPath;

/**
 * Log存放路径，在更改头像时需要用到
 */
+ (NSString *)appCacheLogPath;

/**
 * 清除缓存，Cache目录下的 logs、hiidologs、com.hackemist.SDWebImageCache.default、Gifts 子目录的文件
 * 删除完成的Block，参数为被删的文件个数
 */
+ (void)clearAppCacheWithCompleteBlock:(void (^)(NSUInteger removedFiles))completion;

/**
 * 清除缓存，Cache目录下的 temp 子目录的文件
 */
+ (void)clearAppCacheTempDir;

@end
