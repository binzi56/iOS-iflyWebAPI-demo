//
//  GPSUtils.h
//  Wolf
//
//  Created by mewe on 2017/11/20.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, GPSOpenAppMode) {
    GPSOpenAppModeGPS, //调用地图，显示目标点
    GPSOpenAppModeNavigation, //调用地图，直接导航
};

@interface GPSUtils : NSObject

///是否开了定位权限，YES为打开
+ (BOOL)enableLoaction;

///选择打开多种地图
+ (UIAlertController *)actionSheetWithOpenMap:(GPSOpenAppMode)mode
                              destinationName:(NSString *)name
                                     latitude:(double)lat
                                   longtitude:(double)lon;


///是否安装了高德地图
+ (BOOL)isInstallAMap;

///是否安装了百度地图
+ (BOOL)isInstallBaiduMap;

///是否安装谷歌地图
+ (BOOL)isInstallGoogleMap;

///是否安装腾讯地图
+ (BOOL)isInstallQQMap;

/**
 *  原生地图(WGS1984)获取坐标转化为火星(GCJ-02)坐标
 *
 *  @param latLng 原生坐标点
 *
 *  @return 真实坐标点
 */
+ (CLLocationCoordinate2D)transformMarsFromEarth:(CLLocationCoordinate2D)latLng;

/**
 *  火星坐标转换为百度坐标
 *
 *  @param latLng 火星坐标点
 *
 *  @return 百度坐标点
 */
+ (CLLocationCoordinate2D)transformBaiduFromMars:(CLLocationCoordinate2D)latLng;

/**
 调用 iPhone 系统地图导航
 */
+ (void)openSystemMap:(GPSOpenAppMode)mode
      destinationName:(NSString *)name
             latitude:(double)lat
           longtitude:(double)lon;

/**
 跳转 高德地图 导航
 */
+ (void)openAmap:(GPSOpenAppMode)mode
 destinationName:(NSString *)name
        latitude:(double)lat
      longtitude:(double)lon;

/**
 跳转 百度地图 导航,使用火星坐标
 */
+ (void)openBaidumap:(GPSOpenAppMode)mode
     destinationName:(NSString *)name
            latitude:(double)lat
          longtitude:(double)lon;

/**
 跳转 谷歌地图 导航
 */
+ (void)openGoogleMap:(double)latitude longtitude:(double)lon;

/**
 跳转 腾讯地图 导航
 */
+ (void)openQQMap:(NSString *)destinationName
         latitude:(double)lat
       longtitude:(double)lon;
@end
