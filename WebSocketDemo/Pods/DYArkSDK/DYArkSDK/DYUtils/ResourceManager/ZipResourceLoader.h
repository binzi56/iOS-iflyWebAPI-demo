// Created by 吴佳 on 2016.6.23


typedef NS_ENUM(NSInteger, ZipResourceLoaderStatus) {
    
    ZipResourceLoaderStatusReady,   //未下载
    ZipResourceLoaderStatusLoading, //正在下载
    ZipResourceLoaderStatusLoaded,  //下载完成
    ZipResourceLoaderStatusFailed,  //下载失败
};


@interface ZipResourceLoader : NSObject

@property(nonatomic, readonly) ZipResourceLoaderStatus status;

/** 将<em>urlString</em>的zip文件下载到<em>directory</em>/<em>file</em>, 并解压到<em>directory</em>目录下
 *
 * @param completion 如果回调时BOOL参数为NO, 则表示失败
 *
 * @remark 只有self.status为Ready或Failed时才会下载
 */
- (void)load:(NSString *)urlString toDirectory:(NSString *)directory file:(NSString *)file md5:(NSString *)md5 completion:(void (^)(BOOL))completion;

/** 如果可以, 将状态复位为Ready */
- (void)reset;

@end

