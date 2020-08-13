//
//  ImageUtils.h
//  YY2
//
//  Created by dev on 12/27/12.
//  Copyright (c) 2012 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IMAGE_BEGIN_TAG @"[dyimg]"
#define IMAGE_END_TAG @"[/dyimg]"

@interface ImageUtils : NSObject
+ (CGSize) sizeForImageRestrictSize:(CGSize)imageSize maxSize:(CGSize)maxSize;

+ (UIImage *)resizeImage:(UIImage *)image maxWidth:(int)maxWidth maxHeight:(int)maxHeight;
+ (UIImage *)resizeImage:(UIImage *)image interpolationQuality:(CGInterpolationQuality)quality maxWidth:(int)maxWidth maxHeight:(int)maxHeight;
+ (NSData *)getJPEGRepresentation:(UIImage *)image;
+ (NSString *)formatImageTag:(NSString*)filepath;
+ (UIImage*)grayImage:(UIImage*)source;
+ (void)setupStretchBackImageForButton:(UIButton*)button width:(int)width height:(int)height;
+ (CGSize)getImageSize:(NSData *)imageData maxAllowedSize:(int)maxAllowedSize;
+ (CGSize)getImageSizeFromFile:(NSString *)imagePath maxAllowedSize:(int)maxAllowedSize;
+ (CGSize)pixelDimensionsForImageAtPath:(NSString *)filePath;

+ (UIImage *)getScreenshotImage;
+ (UIImage *)imageFromView:(UIView *)view;
+ (UIImage *)createQRCodeWithNSString:(NSString *)str size:(CGFloat)size;

@end
