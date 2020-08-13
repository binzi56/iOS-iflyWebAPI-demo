#import <UIKit/UIKit.h>

@interface UIImage (KWSResize)

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;

@end

@interface UIImage (KWSResizable)

+ (UIImage *)resizableImageNamed:(NSString *)imageName;
- (UIImage *)resizableImage;

@end

@interface UIImage (KWGIF)

+ (UIImage *)kw_animatedGIFNamed:(NSString *)name;

+ (UIImage *)kw_animatedGIFWithData:(NSData *)data;

@end

@interface UIImage (KWColor)

+ (UIImage *)kw_imageWithColor:(UIColor *)color;

@end

