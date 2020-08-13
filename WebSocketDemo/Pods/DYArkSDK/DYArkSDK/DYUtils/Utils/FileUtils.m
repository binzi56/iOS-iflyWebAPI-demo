//
//  FileUtils.m
//  YY2
//
//  Created by 王 金华 on 12-10-24.
//  Copyright (c) 2012年 com.mewe.party. All rights reserved.
//

#import "FileUtils.h"
#import "NSArray+DY.h"

@interface FileUtils()

+ (NSString *)getCacheDirectory;

@end

@implementation FileUtils

+ (NSString *)appPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)docPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)libPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/lib"];
}

+ (NSString *)tmpPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/tmp"];
}

+ (NSString *)getCacheDirectory
{
    static NSString *cacheDirectory;
    do {
        if (cacheDirectory)
            break;
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1)
            break;
        
        cacheDirectory = [directories safeObjectAtIndex:0];
        
        NSUInteger length = [cacheDirectory length];
        if (length < 1) {
            cacheDirectory = nil;
            break;
        }
        
        if ('/' == [cacheDirectory characterAtIndex:length - 1])
            break;
        
        cacheDirectory = [cacheDirectory stringByAppendingString:@"/"];
    } while (false);
    
    return cacheDirectory;
}

+ (BOOL)isPathExists:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)isFileExists:(NSString *)filePath
{
    BOOL isDirectory;
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory;
}

+ (NSString *)getLocalDirectoryWithName:(NSString *)directory
{
    NSString *cacheDirectory = [FileUtils getCacheDirectory];
    if (!cacheDirectory)
        return nil;
    
    return [cacheDirectory stringByAppendingString:directory];
}

+ (BOOL)moveFile:(NSString *)oldFileName to:(NSString *)newFileName
{
	NSError *error;
	if(![[NSFileManager defaultManager] moveItemAtPath:oldFileName toPath:newFileName error:&error]) {
//		WFLogError(@"Failed to move file %@ to %@, error:%@", oldFileName, newFileName, error);
		return NO;
	}
    return  YES;
}

+ (BOOL)removeFile:(NSString*)filepath
{
    if (!filepath)
        return NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filepath])
        return NO;
    NSError *error = nil;
    if (![manager removeItemAtPath:filepath error:&error]) {
//        WFLogError(@"failed to remove file:%@, error:%@", filepath, error);
        return NO;
    }
    return YES;
}

+ (BOOL)createDirectoryAtPath:(NSString*)path
{
    if (path.length) {
        NSError* error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        return error != nil ? NO : YES;
    }
    
    return NO;
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
                        if ([self isFileExists:[path stringByAppendingPathComponent:str]]) {
                            [files addObject:[path stringByAppendingPathComponent:str]];
                        }
                    }
                }
            }
        }
    }
    return files;
}

@end
