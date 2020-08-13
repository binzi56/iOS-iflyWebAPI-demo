//
//  FileUtils.h
//  YY2
//
//  Created by 王 金华 on 12-10-24.
//  Copyright (c) 2012年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ImTypes.h"

@interface FileUtils : NSObject

+ (NSString *)appPath;
+ (NSString *)docPath;
+ (NSString *)libPath;
+ (NSString *)tmpPath;

+ (BOOL)isPathExists:(NSString *)filePath;

+ (BOOL)isFileExists:(NSString *)filePath;

+ (NSString *)getLocalDirectoryWithName:(NSString *)directory;

+ (BOOL)removeFile:(NSString *)filepath;

+ (BOOL)moveFile:(NSString *)oldFileName to:(NSString *)newFileName;

+ (BOOL)createDirectoryAtPath:(NSString*)path;

+ (NSArray*)directoryFilesAtPath:(NSString *)path;

@end
