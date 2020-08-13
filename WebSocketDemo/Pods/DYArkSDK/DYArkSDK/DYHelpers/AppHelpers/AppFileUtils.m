//
//  AppFileUtils.m
//  kiwi
//
//  Created by lslin on 16/9/28.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import "AppFileUtils.h"
#import "YYImageCache.h"
#import "YYDiskCache.h"
#import "HYCacheManager.h"
#import "NSObject+HYThread.h"
#import "KiwiSDKMacro.h"
#import "WFFileResourceManager.h"
#import "DYDownload.h"

NSString * const kNotificationAppFileCacheCleaned = @"kNotificationAppFileCacheCleaned";

@implementation AppFileUtils

#pragma mark File manager methods

+ (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

+ (BOOL)isPathExist:(NSString *)path
{
    BOOL isPathExist = [[self fileManager] fileExistsAtPath:path];
    if (!isPathExist) {
        KWSLogInfo(@"Path lost: %@", path);
    }
    return isPathExist;
}

+ (BOOL)isFileExist:(NSString *)path
{
    BOOL isDirectory;
    BOOL isFileExist = [[self fileManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
    if (!isFileExist) {
        KWSLogInfo(@"File lost: %@", path);
    }
    return isFileExist;
}

+ (BOOL)isDirectoryExist:(NSString *)path
{
    BOOL isDirectory;
    BOOL isDirectoryExist = [[self fileManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
    KWSLogInfo(@"isDirectoryExist:%@ path: %@",@(isDirectoryExist), path);
    return isDirectoryExist;
}

+ (BOOL)removeFile:(NSString *)path
{
    KWSLogInfo(@"path: %@", path);
    return [[self fileManager] removeItemAtPath:path error:nil];
}

+ (BOOL)createPath:(NSString *)path
{
    KWSLogInfo(@"path: %@", path);
    return [[self fileManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSUInteger)fileCountInPath:(NSString *)path
{
    KWSLogInfo(@"path: %@", path);
    NSUInteger count = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (__unused NSString *fileName in fileEnumerator) {
        count += 1;
    }
    return count;
}

+ (unsigned long long)folderSizeAtPath:(NSString *)path
{
    KWSLogInfo(@"path: %@", path);
    __block unsigned long long totalFileSize = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        totalFileSize += fileAttrs.fileSize;
    }
    return totalFileSize;
}

+ (NSArray*)directoryFilesAtPath:(NSString *)path
{
    NSMutableArray *files = [NSMutableArray array];
    BOOL isDir = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                isExist = [[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&issubDir];
                if (isExist) {
                    if (issubDir) {
                        files = [[files arrayByAddingObjectsFromArray:[self directoryFilesAtPath:subPath]] mutableCopy];
                    } else {
                        if ([self isFileExist:[path stringByAppendingPathComponent:str]]) {
                            [files addObject:[path stringByAppendingPathComponent:str]];
                        }
                    }
                }
            }
        }
    }
    return files;
}

#pragma mark User directory methods

+ (NSString *)appDocumentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)appSupportPathForHuya
{
    return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"com.huya.kiwi"];
}

+ (NSString *)appResourcePath
{
    return [[NSBundle mainBundle] resourcePath];
}

+ (NSString *)appCachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)appStorageCachePath
{
    return [[self appSupportPathForHuya] stringByAppendingPathComponent:@"Storages"];
}

/**
 4.12.1及之前的版本db缓存目录放在了cache/Storages下，在系统磁盘空间不足时会被清掉，导致数据丢失，4.13.0版本该目录不再使用，
 迁移到ApplicationSupportDirectory
 */
+ (void)migrateStorages
{
    NSString *oldStoragePath = [[self appCachePath] stringByAppendingPathComponent:@"Storages"];
    
    if ([AppFileUtils isDirectoryExist:oldStoragePath]) {
        
        NSString *storagePath = [AppFileUtils appStorageCachePath];
        
        if (![AppFileUtils isDirectoryExist:storagePath]) {
            
            [self createAppSupportPathForHuya];
            
            NSError *error = nil;
            
            if ([[AppFileUtils fileManager] copyItemAtPath:oldStoragePath toPath:storagePath error:&error]) {
                KWSLogInfo(@"sucess to copy oldStoragePath to storagePath");
                [AppFileUtils removeFile:oldStoragePath];
            } else {
                KWSLogInfo(@"fail to copy oldStoragePath to storagePath, error %@", error);
            }
        }
    }
}

+ (NSString *)appRecordAudioPath
{
    static NSString *recordPath = nil;
    
    if (!recordPath) {
        recordPath = [[self appCachePath] stringByAppendingPathComponent:@"RecordAudio"];
    }
    
    return recordPath;
}

+ (NSString *)appDownloadSplashPath
{
    static NSString *splashPath = nil;
    
    if (!splashPath) {
        splashPath = [[self appCachePath] stringByAppendingPathComponent:@"Splash"];
    }
    
    return splashPath;
}



+ (NSString *)appResourceCachePath
{
    return [[self appCachePath] stringByAppendingPathComponent:@"Resources"];
}

+ (NSString *)appZipCachePath
{
    return [[self appCachePath] stringByAppendingPathComponent:@"ResourcesZip"];
}

+ (NSString *)appDropListCatImgsPath
{
    return [[self appCachePath] stringByAppendingPathComponent:@"dropListCatsImgs"];
}

+ (NSString *)appCacheTempPath
{
    static NSString *tempPath = nil;
    
    if (tempPath == nil){
        tempPath = [[self appCachePath] stringByAppendingPathComponent:@"temporary/"];
    }
    
    return tempPath;
}

+ (NSString *)appCacheLogPath
{
    static NSString *logPath = nil;
    
    if (logPath == nil){
        logPath = [[self appCachePath] stringByAppendingPathComponent:@"logs/"];
    }
    return logPath;
}

+ (BOOL)createAppSupportPathForHuya
{
    NSString *dir = [self appSupportPathForHuya];
    if ( ![self isDirectoryExist:dir] ) {
        return [self createPath:dir];
    }
    return YES;
}

+ (BOOL)createAppStorageCachePath
{
    NSString *dir = [self appStorageCachePath];
    if ( ![self isDirectoryExist:dir] ) {
        return [self createPath:dir];
    }
    return YES;
}

+ (BOOL)createAppSplashCachePath
{
    NSString *dir = [self appDownloadSplashPath];
    if ( ![self isDirectoryExist:dir] ) {
        return [self createPath:dir];
    }
    return YES;
}


+ (BOOL)createAppResourceCachePath
{
    NSString *dir = [self appResourceCachePath];
    if ( ![self isDirectoryExist:dir] ) {
        return [self createPath:dir];
    }
    return YES;
}

+ (BOOL)createAppZipCachePath
{
    NSString *dir = [self appZipCachePath];
    if ( ![self isDirectoryExist:dir] ) {
        return [self createPath:dir];
    }
    return YES;
}

+ (unsigned long long)appCacheSize
{
    unsigned long long size = 0;
    
    NSArray *dirs = [self cacheDirsNeedToClear];
    NSString *appCachePath = [self appCachePath];
    for (NSString *dir in dirs) {
        size += [self folderSizeAtPath:[appCachePath stringByAppendingPathComponent:dir]];
    }
    
    size += [[YYImageCache sharedCache].diskCache totalCost];
    size += [[HYCacheManager sharedManager] diskTotalCost];
    return size;
}

+ (void)clearAppCacheWithCompleteBlock:(void (^)(NSUInteger removedFiles))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = 0;
        NSArray *dirs = [self cacheDirsNeedToClear];
        for (NSString *str in dirs) {
            NSString *path = [[self appCachePath] stringByAppendingPathComponent:str];
            count += [self fileCountInPath:path];
            
            [self removeFile:path];
            [self createPath:path];
        }
        
        count += [[YYImageCache sharedCache].diskCache totalCount];
        [[YYImageCache sharedCache].diskCache removeAllObjects];
        [[HYCacheManager sharedManager] removeAllObjects:nil];
        [WFFileResourceManager clearFileResource];
        [[DYDownloadManager sharedInstance] cleanDownloadInfosAndFiles];
        if (completion) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationInMainThreadWithName:kNotificationAppFileCacheCleaned];
                completion(count);
            });
        }
    });
}

+ (void)clearAppCacheTempDir
{
    [self removeFile:[self appCacheTempPath]];
}

+ (NSArray *)cacheDirsNeedToClear
{
    return @[@"Resources",@"ResourcesZip",@"com.dy.downloadmanager"];
    //    return @[@"logs", @"hiidologs", @"Splash", @"Gifts", @"MLiveGifts", @"GameLivePrivilegeUser",@"QMCaching", @"NewBanner",@"Resources",@"ResourcesZip"];
}

@end
