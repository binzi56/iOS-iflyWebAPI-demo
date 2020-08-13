//
//  WFFileResourceManager.m
//  Wolf
//
//  Created by Tim-Macmini on 2017/10/23.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "WFFileResourceManager.h"
#import "AppFileUtils.h"
#import "SettingsData.h"
#import "HYFHTTPManager.h"
#import "KiwiSDKMacro.h"
#if __has_include(<SSZipArchive / SSZipArchive.h>)
#import <SSZipArchive/SSZipArchive.h>
#else
#import "SSZipArchive.h"
#endif

#define kWFFileResourceUrlCaches @"kWFFileResourceUrlCaches"

typedef NS_ENUM(NSInteger, FileURLType) {
    FileURLType_Unknow,
    FileURLType_File,
    FileURLType_Zip,
    FileURLType_Svga,
};

@interface WFFileResourceManager ()

///下载任务队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

///正下载文件链接列表
@property (nonatomic, strong) NSMutableDictionary *downloadingUrls;

///已下载文件链接列表
@property (nonatomic, strong) NSMutableArray *downloadedUrlCaches;

///内存缓存文件或文件路径
@property (nonatomic, strong) NSMutableDictionary *memoryCacheFiles;

@end

@implementation WFFileResourceManager

WF_DEF_SINGLETION(WFFileResourceManager);

- (id)init
{
    if (self                                           = [super init]) {
        self.downloadQueue                             = [NSOperationQueue new];
        self.downloadQueue.maxConcurrentOperationCount = 3;
        self.downloadQueue.qualityOfService            = NSQualityOfServiceBackground;
        self.downloadingUrls                           = [NSMutableDictionary new];
        self.memoryCacheFiles                          = [NSMutableDictionary new];
        self.downloadedUrlCaches                       = [[[SettingsData sharedObject] getValueForKey:kWFFileResourceUrlCaches] mutableCopy];
        if (!self.downloadedUrlCaches) {
            self.downloadedUrlCaches = [NSMutableArray new];
        }
    }
    return self;
}

+ (void)downloadFileResource:(NSString *)sourceName sourceUrl:(NSString *)sourceUrl completeBlock:(void (^)(BOOL succeed))completeBlock
{
    if (!sourceName.length || !sourceUrl.length) {
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }

    if ([self downloadedContainsUrl:sourceUrl]) {
        if (completeBlock) {
            completeBlock(YES);
        }
        return;
    }

    WFFileResourceManager *sharedManager = [self sharedInstance];
    if (sharedManager.downloadingUrls[sourceUrl]) {
        if (completeBlock) {
            completeBlock(NO);
        }
        return;
    }
    [sharedManager.downloadingUrls setObject:@(YES) forKey:sourceUrl];

    FileURLType type = [self p_fileResourceTypeWithUrl:sourceUrl];
    NSString *localFilePath;  //下载后文件的位置
    NSString *unzipPath;      // zip包解压的位置
    switch (type) {
        case FileURLType_Zip:
            localFilePath = [[self p_fileZipPath:sourceName] stringByAppendingPathComponent:[sourceUrl lastPathComponent]];
            unzipPath     = [self p_fileResourcePath:sourceName];
            DYLogInfo(@"willDownloadFileResource:%@ ====> zipPath:%@ ====> unZipPath:%@", sourceUrl, localFilePath, unzipPath);
            break;
        case FileURLType_Svga:
        case FileURLType_File:
            localFilePath = [[self p_fileResourcePath:sourceName] stringByAppendingPathComponent:[sourceUrl lastPathComponent]];
            DYLogInfo(@"willDownloadFileResource:%@ ====> %@ ", sourceUrl, localFilePath);
            break;
        default:
            break;
    }

    sourceUrl = [sourceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    void (^callbackBlock)(BOOL succeed, NSString *sourceUrl) = ^(BOOL succeed, NSString *sourceUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeed) {
                [sharedManager.downloadedUrlCaches addObject:sourceUrl];
                [[SettingsData sharedObject] setValue:sharedManager.downloadedUrlCaches forKey:kWFFileResourceUrlCaches];
            }
            [sharedManager.downloadingUrls removeObjectForKey:sourceUrl];
            if (completeBlock) {
                completeBlock(succeed);
            }
        });
    };

    [sharedManager.downloadQueue addOperationWithBlock:^{
        [HYFHTTPManager downloadWithRequest:sourceUrl
            localFilePath:localFilePath
            success:^(NSURLSessionDownloadTask *task, NSURL *filePath) {
                DYLogInfo(@"downloadFileResourceSucceed:%@", sourceUrl);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    BOOL isSucceed = YES;
                    if (type == FileURLType_Zip) {
                        NSError *errUnzip = nil;
                        [SSZipArchive unzipFileAtPath:localFilePath toDestination:unzipPath overwrite:YES password:nil error:&errUnzip];
                        if (errUnzip) {
                            isSucceed = NO;
                            NSString *errStr =
                                [NSString stringWithFormat:@"unZipFileResourceFailed:%@ \nreason:%@", sourceUrl, errUnzip.localizedDescription];
                            DYLogInfo(errStr);
                        }
                        else {
                            DYLogInfo(@"unZipFileResourceSucceed:%@", sourceUrl);
                        }
                        [AppFileUtils removeFile:localFilePath];
                    }
                    callbackBlock(isSucceed, sourceUrl);
                });

            }
            failure:^(NSURLSessionDownloadTask *task, NSError *error) {
                DYLogInfo(@"downloadFileResourceFailed:%@\nreason:%@", sourceUrl, error.localizedDescription);
                callbackBlock(NO, sourceUrl);
            }];
    }];
}

+ (void)fileResourceDataWithSourceName:(NSString *)sourceName
                      fileResourceType:(FileResourceType)fileResourceType
                         completeBlock:(void (^)(id fileResource))completeBlock
{
    if (!sourceName.length) {
        return;
    }
    WFFileResourceManager *sharedManager = [self sharedInstance];
    id memoryCacheFile                   = sharedManager.memoryCacheFiles[sourceName];
    if (memoryCacheFile) {
        if (completeBlock) {
            completeBlock(memoryCacheFile);
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        id dataResource      = nil;
        NSString *sourcePath = [self p_fileResourcePath:sourceName];
        dataResource         = [self p_fileResourceImagesWithSourcePath:sourcePath fileResourceType:fileResourceType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dataResource && sourceName.length) {
                [sharedManager.memoryCacheFiles setObject:dataResource forKey:sourceName];
                if (completeBlock) {
                    completeBlock(dataResource);
                }
            }
        });
    });
}

+ (void)clearFileResource
{
    [[self sharedInstance].downloadQueue cancelAllOperations];
    
    [[self sharedInstance].downloadingUrls removeAllObjects];
    [[self sharedInstance].downloadedUrlCaches removeAllObjects];
    [[self sharedInstance].memoryCacheFiles removeAllObjects];
    
    [[SettingsData sharedObject] removeValueForKey:kWFFileResourceUrlCaches];
    
    [AppFileUtils removeFile:[AppFileUtils appResourceCachePath]];
    [AppFileUtils removeFile:[AppFileUtils appZipCachePath]];
}

+ (BOOL)downloadedContainsUrl:(NSString *)sourceUrl
{
    WFFileResourceManager *sharedManager = [self sharedInstance];
    return [sharedManager.downloadedUrlCaches containsObject:sourceUrl];
}

+ (NSString *)fileResourcePathWithSourceName:(NSString *)sourceName
{
    [AppFileUtils createAppResourceCachePath];
    NSString *sourcePath = [[AppFileUtils appResourceCachePath] stringByAppendingPathComponent:sourceName];
    return sourcePath;
}

#pragma mark - private

+ (NSString *)p_fileZipPath:(NSString *)sourceName
{
    [AppFileUtils createAppZipCachePath];
    NSString *cachePath  = [AppFileUtils appZipCachePath];
    NSString *sourcePath = [cachePath stringByAppendingPathComponent:sourceName];
    if (![AppFileUtils isPathExist:sourcePath]) {
        [AppFileUtils createPath:sourcePath];
    }
    return sourcePath;
}

+ (NSString *)p_fileResourcePath:(NSString *)sourceName
{
    [AppFileUtils createAppResourceCachePath];
    NSString *cachePath  = [AppFileUtils appResourceCachePath];
    NSString *sourcePath = [cachePath stringByAppendingPathComponent:sourceName];
    if (![AppFileUtils isPathExist:sourcePath]) {
        [AppFileUtils createPath:sourcePath];
    }
    return sourcePath;
}

+ (FileURLType)p_fileResourceTypeWithUrl:(NSString *)sourceUrl
{
    FileURLType type = FileURLType_Unknow;
    if (sourceUrl) {
        NSString *fileName = [sourceUrl lastPathComponent];
        if ([fileName containsString:@".zip"]) {
            type = FileURLType_Zip;
        }
        else if ([fileName containsString:@".svga"]) {
            type = FileURLType_Svga;
        }
        else {
            type = FileURLType_File;
        }
    }
    return type;
}

+ (NSArray<NSString *> *)p_fileCachePathsWithSourcePath:(NSString *)sourcePath
{
    if (sourcePath.length && [AppFileUtils isPathExist:sourcePath]) {
        NSArray *files = [AppFileUtils directoryFilesAtPath:sourcePath];
        files          = [files sortedArrayWithOptions:NSSortConcurrent
                              usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                                  return [obj1 compare:obj2 options:NSNumericSearch];
                              }];
        return files;
    }
    return nil;
}

+ (id)p_fileResourceImagesWithSourcePath:(NSString *)sourcePath fileResourceType:(FileResourceType)fileResourceType
{
    NSArray *files      = [self p_fileCachePathsWithSourcePath:sourcePath];
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSString *obj in files) {
        switch (fileResourceType) {
            case FileResourceType_Svga:
                if ([[obj lastPathComponent] containsString:@".svga"]) {
                    return obj;  // svga
                }
                break;
            case FileResourceType_LOT:
                if ([[obj lastPathComponent] containsString:@".json"]) {
                    return obj;  // Airbnb
                }
                break;
            case FileResourceType_Html:
                if ([[obj lastPathComponent] containsString:@".html"]) {
                    return obj;  // html动画
                }
                break;
            case FileResourceType_Image: {
                UIImage *image = [self p_imageDataWithPath:obj];
                if (image)
                    return image;
                break;
            }
            case FileResourceType_Images: {
                UIImage *image = [self p_imageDataWithPath:obj];
                if (image) {
                    [tmp addObject:image];
                }
                break;
            }
            default:
                break;
        }
    }
    if (fileResourceType == FileResourceType_Images || fileResourceType == FileResourceType_Image) {
        return tmp;  //帧动画
    } else {
        return nil;
    }
}

+ (UIImage *)p_imageDataWithPath:(NSString *)path
{
    NSURL *imageUrl = [NSURL fileURLWithPath:path];
    UIImage *image  = nil;
    if ([AppFileUtils isFileExist:path]) {
        NSDictionary *option    = @{(__bridge id) kCGImageSourceShouldCache : @(YES) };
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef) imageUrl, NULL);
        if (source) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, (__bridge CFDictionaryRef) option);
            image               = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
            CFRelease(source);
        }
    }
    return image;
}

@end
