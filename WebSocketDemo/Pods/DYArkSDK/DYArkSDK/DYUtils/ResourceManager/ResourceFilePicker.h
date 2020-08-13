// Created by 吴佳 on 2016.6.23

#import "HYCacheManager.h"

@protocol ResourceFileTypeProtocol <NSObject>

@optional
- (NSArray *)fileNames;

@end

/** 资源类型 */
@interface ResourceFileType : NSObject <ResourceFileTypeProtocol>

/* 以下属性都是ResourceFileType子类属性, 出现在ResourceFileType中仅仅是避免调用时的类型转换 */
@property(nonatomic, readonly) NSArray<UIImage *> *images;
@property(nonatomic, readonly) UIImage *image;
- (UIImage *)imageWithIndex:(int)index;

@end

/** 单张图片 */
@interface ResourceFileImageType : ResourceFileType

+ (instancetype)named:(NSString *)name backup:(NSString *)backup;

@property(nonatomic, readonly) UIImage *image;

@end

/** 多帧图片序列 */
@interface ResourceFileSerialImagesType : ResourceFileType

/** @warning <em>format</em>中有且只能有一个"%d"作为格式符 */
+ (instancetype)format:(NSString *)format from:(int)first to:(int)last backup:(NSString *)backup;

@property(nonatomic, readonly) NSArray<UIImage *> *images;

@end


@interface ResourceFilePicker : NSObject

/** cache */
@property(nonatomic,strong) id<IHYCache> cache;

/** 工作文件夹 */
@property(nonatomic) NSString *workDirectory;

/** @remark 字典files{name,type}的name是用户设置的标志名, 不是文件名; 文件名描述在type中 */
@property(nonatomic) NSDictionary<NSString *, ResourceFileType *> *files;

/**
 * @param name 时files{name,type}的name
 */
- (__kindof ResourceFileType *)objectForKeyedSubscript:(NSString *)name;

//@property(nonatomic, readonly) BOOL allFilesExist;

- (BOOL)allFilesExist;

- (void)setLoading:(BOOL)isLoading;

@end

