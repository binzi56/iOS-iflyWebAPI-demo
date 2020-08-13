//
//  ImageUtils.m
//  YY2
//
//  Created by dev on 12/27/12.
//  Copyright (c) 2012 YY Inc. All rights reserved.
//

#import "ImageUtils.h"
#import "UIImage+KWS.h"
#include <string>
#include <sstream>
#import <ImageIO/ImageIO.h>
#import "KiwiSDKMacro.h"

@implementation ImageUtils

+ (CGSize)sizeForImageRestrictSize:(CGSize)imageSize maxSize:(CGSize)maxSize;
{
    float origWidth = imageSize.width;
    float origHeight = imageSize.height;
    
    float widthScale = maxSize.width / origWidth;
    float heightScale = maxSize.height /origHeight;
    
    float scale = widthScale < heightScale ? widthScale : heightScale;
    if (scale > 1.0) {
        scale = 1.0;
    }
    
    CGSize newSize = CGSizeMake(scale * origWidth, scale * origHeight);
    return  newSize;
}

+ (UIImage *)resizeImage:(UIImage *)image maxWidth:(int)maxWidth maxHeight:(int)maxHeight
{
    return [self resizeImage:image interpolationQuality:kCGInterpolationHigh maxWidth:maxWidth maxHeight:maxHeight];
}

+ (UIImage *)resizeImage:(UIImage *)image interpolationQuality:(CGInterpolationQuality)quality maxWidth:(int)maxWidth maxHeight:(int)maxHeight
{
    float origWidth = image.size.width;
    float origHeight = image.size.height;
    
    float widthScale = maxWidth / origWidth;
    float heightScale = maxHeight /origHeight;
    
    float scale = widthScale < heightScale ? widthScale : heightScale;
    if (scale > 1.0) {
        scale = 1.0;
    }
    
    CGSize newSize = CGSizeMake(scale * origWidth, scale * origHeight);
    UIImage* resizedImage = [image resizedImage:newSize interpolationQuality:quality];
    return resizedImage;
}

+ (NSData *)getJPEGRepresentation:(UIImage *)image
{
    return UIImageJPEGRepresentation(image, 0.5);
}

+ (NSString *)formatImageTag:(NSString*)filepath
{
    return [NSString stringWithFormat:@"%@%@%@",IMAGE_BEGIN_TAG, filepath, IMAGE_END_TAG];
}

+ (void)setupStretchBackImageForButton:(UIButton*)button width:(int)width height:(int)height
{
    [button setBackgroundImage:[[button backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:width topCapHeight:height] forState:UIControlStateNormal];
    [button setBackgroundImage:[[button backgroundImageForState:UIControlStateHighlighted] stretchableImageWithLeftCapWidth:width topCapHeight:height] forState:UIControlStateHighlighted];
}

+(UIImage*)grayImage:(UIImage*)source
{
    UIImage *grayImage;
    
    int width = source.size.width;
    int height = source.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,  CGRectMake(0, 0, width, height), source.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    grayImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return grayImage;
}

+ (CGSize)getImageSize:(NSData *)imageData maxAllowedSize:(int)maxAllowedSize
{
    UIImage *image = [UIImage imageWithData:imageData];
    int width = image.size.width;
    int height = image.size.height;
    
    while (width > maxAllowedSize || height > maxAllowedSize ) {
        width >>= 1;
        height >>= 1;
    }
    return CGSizeMake(width, height);
}

+ (CGSize)getImageSizeFromFile:(NSString *)imagePath maxAllowedSize:(int)maxAllowedSize
{
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    return [self getImageSize:imageData maxAllowedSize:maxAllowedSize];
}

+ (CGSize)pixelDimensionsForImageAtPath:(NSString *)filePath
{
    NSURL *imageFileUrl = [NSURL fileURLWithPath:filePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)(imageFileUrl), NULL);
    if (imageSource == NULL)
    {
        return CGSizeMake(0, 0);
    }
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (imageProperties != NULL)
    {
        const CFNumberRef widthNum = (const CFNumberRef) CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        const CFNumberRef heightNum =(const CFNumberRef) CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        CFRelease(imageProperties);
    }
    
    CFRelease(imageSource);
    return CGSizeMake(width, height);
}

+ (UIImage *)getScreenshotImage {
    return [self screenshotImage];
}

+ (UIImage *)imageFromView:(UIView *)view {
    if (CGRectIsEmpty(view.bounds)) {
        return [[UIImage alloc] init];
    }
    if ((view.frame.size.width == 0 || view.frame.size.height == 0) && view.layer.cornerRadius != 0) {
        return [[UIImage alloc] init];
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)createQRCodeWithNSString:(NSString *)str size:(CGFloat)size {
    EAGLContext *glContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *outputImage = [filter outputImage];
    
    CGRect extent = CGRectIntegral(outputImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *qrCodeImage = [UIImage imageWithCGImage:scaledImage];
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGImageRelease(scaledImage);
    CGColorSpaceRelease(cs);
    [EAGLContext setCurrentContext:glContext];
    return qrCodeImage;
}

#pragma mark - Private

+ (void)drawWindow:(UIWindow *)window withContext:(CGContextRef)context imageSize:(CGSize)imageSize ignoreOrientation:(BOOL)ignoreOrientation {
    if (!window) {
        return;
    }
    if (window.hidden) {
        return;
    }
    if (CGRectIsEmpty(window.frame)) {
        return;
    }
    //过滤键盘
    // >= IOS9
    if ([NSStringFromClass([window class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
        return;
    }
    // < IOS9
    if ([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]) {
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, window.center.x, window.center.y);
    CGContextConcatCTM(context, window.transform);
    CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
    if(!ignoreOrientation)
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, (CGFloat)M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if(orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, (CGFloat)-M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        }
        else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            CGContextRotateCTM(context, (CGFloat)M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
    }
    
    if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
    } else {
        [window.layer renderInContext:context];
    }
    CGContextRestoreGState(context);
}

+ (UIImage *)screenshotImage {
    BOOL ignoreOrientation = !SystemVersionLessThan(@"8.0");
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize imageSize = CGSizeZero;
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        [self drawWindow:window withContext:context imageSize:imageSize ignoreOrientation:ignoreOrientation];
    }
    [self drawWindow:[[UIApplication sharedApplication] valueForKey:@"_statusBarWindow"] withContext:context imageSize:imageSize ignoreOrientation:ignoreOrientation];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end



@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", (unsigned long)contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark - Private helper methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                // modified by xudongyang at 2012-07-20
                                                CGImageGetBytesPerRow( self.CGImage )/*0*/,
                                                CGImageGetColorSpace(imageRef),
                                                // modified by xudongyang at 2012-07-20
                                                CGImageGetAlphaInfo( self.CGImage )/*kCGImageAlphaNoneSkipLast*/);//CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

-(UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
