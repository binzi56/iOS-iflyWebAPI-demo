// Created by 吴佳 on 2016.6.23

#import "ResourceFilePicker.h"
#import "KiwiSDKMacro.h"
#import "AppFileUtils.h"

#pragma mark - 资源类型

@interface ResourceFileType ()

@property(nonatomic) NSString *workDirectory;
@property(nonatomic,strong) id<IHYCache> cache;

/**< loading状态下不应该读图片，否则有可能出现下载解压线程解压图片时主线程去读图片
 ，导致崩溃
 Crash reason:  EXC_BAD_ACCESS / KERN_MEMORY_ERROR
 Crash address: 0xca84000
 Process uptime: 22 seconds
 
 Thread 0 (crashed)
 0  ImageIO!AppleJPEGReadPlugin::IdentifyProc(unsigned char const*, unsigned long, __CFString const*) + 0x0
 1  ImageIO!IIOImageSource::doBindToPlugin() + 0x284
 2  ImageIO!IIOImageSource::bindToPlugin() + 0x44
 3  ImageIO!IIOImageSource::updatedCount() + 0x2c
 4  ImageIO!CGImageSourceGetCount + 0x6c
 5  UIKit!ImageRefAtPath + 0x13c
 6  UIKit!_UIImageRefAtPath + 0x118
 7  UIKit!-[UIImage(UIImagePrivate) initWithContentsOfFile:cache:] + 0x70
 8  UIKit!+[UIImage imageWithContentsOfFile:] + 0x44
 9  kiwi!-[ResourceFileSerialImagesType images] + 0x1a4
 
 Thread 14
 0  libsystem_kernel.dylib!__open_nocancel + 0x8
 1  libsystem_kernel.dylib!open$NOCANCEL + 0xc
 2  libsystem_c.dylib!fopen + 0x50
 3  kiwi!-[ZipArchive UnzipFileTo:overWrite:] [ZipArchive.m : 363 + 0x8]
 4  kiwi!__58-[ZipResourceLoader load:toDirectory:file:md5:completion:]_block_invoke_2 + 0x84
 */
@property(nonatomic,assign, getter=isLoading) BOOL loading;

@end

@implementation ResourceFileType

- (UIImage *)imageWithIndex:(int)index { return nil; }

@end


#pragma mark - 单张图片

@interface ResourceFileImageType ()

@property(nonatomic) NSString *resourceFileName;
@property(nonatomic) NSString *backupResourceName;

@end

@implementation ResourceFileImageType

+ (instancetype)named:(NSString *)name backup:(NSString *)backup
{
#ifdef DEBUG
    NSAssert([name hasSuffix:@".png"], @"must end with png");
#endif
    
    ResourceFileImageType *object = [[ResourceFileImageType alloc] init];
    object.resourceFileName = name;
    object.backupResourceName = backup;
    
    return object;
}

- (NSArray *)fileNames
{
    return @[self.resourceFileName];
}

- (UIImage *)image
{
    NSString *path = [self.workDirectory stringByAppendingPathComponent:self.resourceFileName];
    UIImage* image = [self.cache objectForKey:path];
    if (!image && !self.isLoading) {
        image = [UIImage imageWithContentsOfFile:path];
        [self.cache setObject:image forKey:path];
    }
    return image ?: [UIImage imageNamed:self.backupResourceName];
}

@end


#pragma mark - 多帧图片序列

@interface ResourceFileSerialImagesType ()
@property(nonatomic) NSString *backupResourceFile;
@property(nonatomic) NSString *resourceFileFormat;
@property(nonatomic) int firstIndex;
@property(nonatomic) int lastIndex;
@end

@implementation ResourceFileSerialImagesType

+ (instancetype)format:(NSString *)format from:(int)first to:(int)last backup:(NSString *)backup
{
#ifdef DEBUG
    NSAssert([format hasSuffix:@".png"], @"must end with png");
#endif
    
    ResourceFileSerialImagesType *object = [[ResourceFileSerialImagesType alloc] init];
    object.backupResourceFile = backup;
    object.resourceFileFormat = format;
    object.firstIndex = first;
    object.lastIndex = last;
    
    return object;
}

- (NSArray *)fileNames
{
    NSMutableArray *fileNames = [[NSMutableArray alloc] init];
    for (int i = self.firstIndex; i <= self.lastIndex; ++i) {
        
        NSString *fileName = [NSString stringWithFormat:self.resourceFileFormat, i];
        [fileNames safeAddObject:fileName];
    }
    return [fileNames copy];
}

- (NSArray<UIImage *> *)images
{
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    
    for (int i = self.firstIndex; i <= self.lastIndex; ++i) {
        
        NSString *fileName = [NSString stringWithFormat:self.resourceFileFormat, i];
        NSString *path = [self.workDirectory stringByAppendingPathComponent:fileName];
        UIImage *image = [self.cache objectForKey:path];
        
        if (!image && !self.isLoading) {
            image = [UIImage imageWithContentsOfFile:path];
            [self.cache setObject:image forKey:path];
        }
        
        if (image) {
            [images addObject:image];
        } else {
            [images removeAllObjects];
            break;
        }
    }
    
    if (images.count == 0) {
        
        UIImage *image = [UIImage imageNamed:self.backupResourceFile];
        if (image) {
            [images addObject:image];
            return images;
        } else {
            return nil;
        }
        
    } else {
        
        return images;
    }
}

@end

#pragma mark - ResourceFilePicker

@interface ResourceFilePicker ()
@end

@implementation ResourceFilePicker

- (void)setLoading:(BOOL)isLoading
{
    NSArray *fileValues = [self.files allValues];
    for (ResourceFileType *file in fileValues) {
        file.loading = isLoading;
    }
    KWSLogInfo(@"%d", isLoading);
}

- (void)setWorkDirectory:(NSString *)workDirectory
{
    _workDirectory = workDirectory;
    
    for (NSString *name in self.files) {
        self.files[name].workDirectory = workDirectory;
        self.files[name].cache = self.cache;
    }
}

- (void)setFiles:(NSDictionary<NSString *,ResourceFileType *> *)files
{
    _files = files;
    
    for (NSString *name in self.files) {
        self.files[name].workDirectory = self.workDirectory;
        self.files[name].cache = self.cache;
    }
}

- (__kindof ResourceFileType *)objectForKeyedSubscript:(NSString *)name
{
    return self.files[name];
}

- (BOOL)allFilesExist
{
    static NSSet *fileNamesSet = nil;
    if (!fileNamesSet) {
        NSMutableArray *fileNames = [[NSMutableArray alloc] init];
        for (NSString *name in self.files) {
            [fileNames addObjectsFromArray:[self.files[name] fileNames]];
        }
        fileNamesSet = [NSSet setWithArray:fileNames];
    }
    
    NSError *error = nil;
    NSFileManager *fileManager = [AppFileUtils fileManager];
    NSArray *localFileNames = [fileManager contentsOfDirectoryAtPath:self.workDirectory error:&error];
    NSSet *localFileNamesSet = [NSSet setWithArray:localFileNames];
    
    BOOL allFilesExist = [fileNamesSet isSubsetOfSet:localFileNamesSet];
    
#ifdef DEBUG
//    if ([fileManager fileExistsAtPath:self.workDirectory isDirectory:NULL] && [fileNamesSet count] && [localFileNamesSet count]) {
//        //文件夹存在，但是图片资源不匹配，通常是资源包有问题，要在开发期间处理掉，否则上线后会每次启动都下载资源包
//        NSAssert(allFilesExist, @"folder exist, but fileNamesSet and localFileNamesSet not match");
//    }
#endif
    
    return allFilesExist;
}

@end

