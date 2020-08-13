// Created by 吴佳 on 2016.6.23

#import "ZipResourceLoader.h"

#import <SSZipArchive/SSZipArchive.h>
#import "HashUtils.h"
#import "AppFileUtils.h"

#import "HYFHTTPManager.h"
#import "KiwiSDKMacro.h"


@interface ZipResourceLoader ()
@property(nonatomic) ZipResourceLoaderStatus status;
@end

@implementation ZipResourceLoader

- (instancetype)init
{
    if (self = [super init]) {
        self.status = ZipResourceLoaderStatusReady;
    }
    return self;
}

- (void)load:(NSString *)urlString toDirectory:(NSString *)directory file:(NSString *)file md5:(NSString *)md5 completion:(void (^)(BOOL))completion
{
    if (urlString.length == 0) {
        completion(NO);
        return;
    }
    
    urlString = [self replaceHttpWithHttps:urlString];
    
    if (self.status == ZipResourceLoaderStatusLoading) {
        completion(NO);
        return;
    }
    
    if (self.status == ZipResourceLoaderStatusLoaded) {
        completion(NO);
        return;
    }
    
    //1 下载
    self.status = ZipResourceLoaderStatusLoading;
    
    if (![AppFileUtils isPathExist:directory]) {
        [AppFileUtils createPath:directory];
    }

    NSString *zipFilePath = [directory stringByAppendingPathComponent:file];
    
    __block void(^unzip)(BOOL loadSuccess) = nil;
    
    [HYFHTTPManager downloadWithRequest:urlString
                          localFilePath:zipFilePath
                                success:^(NSURLSessionDownloadTask *task, NSURL *filePath) {
                                    unzip(YES);
                                    KWSLogInfo(@"downloadWithRequest, success!");
                                }
                                failure:^(NSURLSessionDownloadTask *task, NSError *error) {
                                    unzip(NO);
                                    KWSLogInfo(@"downloadWithRequest, failure!, %@", error);
                                }];
    
    //2 解压
    BlockWeakSelf(weakSelf, self);
    unzip = ^(BOOL loadSuccess) {
        
        KWSLogInfo(@"download %@, %@", loadSuccess ? @"success" : @"fail", urlString);
        
        if (loadSuccess) {
            hy_dispatch_async_model(^{
                BOOL handleResult = YES;
                
                if ([ZipResourceLoader isFileMD5InPath:zipFilePath equalToMD5:md5]) {
                    [SSZipArchive unzipFileAtPath:zipFilePath toDestination:directory];
                    [weakSelf cleanUpZipWithFilePath:zipFilePath];
                } else {
                    handleResult = NO;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(handleResult);
                    }
                    weakSelf.status = ZipResourceLoaderStatusLoaded;
                    
                });
            });
        } else {
            
            if (completion) {
                completion(NO);
            }
            weakSelf.status = ZipResourceLoaderStatusFailed;
        }
    };
}

- (void)cleanUpZipWithFilePath:(NSString *)filePath
{
    if ([filePath containsString:@".zip"] && [AppFileUtils isPathExist:filePath]) {
        [AppFileUtils removeFile:filePath];
    }
}

- (void)reset
{
    if (self.status == ZipResourceLoaderStatusFailed
     || self.status == ZipResourceLoaderStatusLoaded)
    {
        self.status = ZipResourceLoaderStatusReady;
    }
}

+ (BOOL)isFileMD5InPath:(NSString *)filePath equalToMD5:(NSString *)md5
{
    if ([md5 length]) {
        NSString *fileMD5 = [HashUtils fileMd5HexString:filePath];
        if ([fileMD5 isEqualToString:md5]) {
            return YES;
        } else {
            KWSLogInfo(@"fileMD5 %@, md5 %@, NOT Match", fileMD5, md5);
            return NO;
        }
    } else {
        //没有MD5，返回YES
        return YES;
    }
}

- (NSString *)replaceHttpWithHttps:(NSString *)urlString
{
    if ([urlString hasPrefix:@"http://"]) {
        urlString = [urlString stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@"https://"];
    }
    return urlString;
}

@end

