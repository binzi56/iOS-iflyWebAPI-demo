//
//  GPSUtils.m
//  Wolf
//
//  Created by mewe on 2017/11/20.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "GPSUtils.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "HYLogMacros.h"

/*
 必要参数的意思：sourceApplication：该app名字； poi name：目的地名称；lat/lon：目的地经纬度
 dev 参数进行解释：dev支持的值为"0"和"1"，即是否需要进行国测局坐标加密。 如果传入的坐标已经是国测局坐标则传入0，如果传入的是地球坐标，则该参数传入1
 */

//#define GaoDeNavUrl @"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%f&lon=%f&dev=0&style=2"
#define GaoDeNavUrl @"iosamap://path?sourceApplication=%@&backScheme=%@&sname=我的位置&dname=%@&dlat=%f&dlon=%f&dev=0&style=2"

#define GaoDeGPSUrl @"iosamap://viewMap?sourceApplication=%@&poiname=%@&lat=%@&lon=%@&dev=0"


/*
 百度地图的参数意思就比较简单了，对mode做一个解释，mode为调用地图之后的导航方式，除了walking(步行)还有driving(驾车)和transit(公交)
 coord_type允许的值为bd09ll、gcj02、wgs84 如果你APP的地图SDK用的是百度地图SDK 请填bd09ll 否则 就填gcj02 
 origin=latlng:0,0  这个参数虽然意思上是要给一个当前坐标，但是可以随意设置，这里设置两个0，不影响导航
 */
#define BaiDuNavUrl @"baidumap://map/direction?origin=latlng:0,0|name:我的位置&destination=latlng:%@,%@|name:%@&mode=walking&coord_type=gcj02"
#define BaiDuGPSUrl @"baidumap://map/marker?location=%@,%@&title=我的位置&content=%@"

/*
 x-source=%@&x-success=%@
 跟高德一样 这里分别代表APP的名称和URL Scheme
 saddr= 这里留空则表示从当前位置触发
 https://developers.google.com/maps/documentation/ios-sdk/urlscheme
 */
#define GoogleMapUrl @"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=walking"

/*
 http://lbs.qq.com/uri_v1/guide-route.html
 */
#define QQMapUrl @"qqmap://map/routeplan?type=walk&from=我的位置&to=%@&tocoord=%f,%f&policy=0&referer=%@"

#define APPScheme @"mewewolf"

@implementation GPSUtils

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double x_pi = M_PI * 3000.0 / 180.0;

#pragma mark - 定位权限
+ (BOOL)enableLoaction{
    BOOL disable =([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
                   [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted);
  return !disable;
}

#pragma mark - 坐标转换

+ (CLLocationCoordinate2D)transformMarsFromEarth:(CLLocationCoordinate2D) latLng
{
    
    double wgLat = latLng.latitude;
    double wgLon = latLng.longitude;
    double mgLat;
    double mgLon;
    
    if ([self outOfChina:wgLat :wgLon ])
    {
        return latLng;
    }
    double dLat = [self transformLat:wgLon-105.0 :wgLat - 35 ];
    double dLon = [self transformLon:wgLon-105.0 :wgLat - 35 ];
    
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    mgLat = wgLat + dLat;
    mgLon = wgLon + dLon;
    CLLocationCoordinate2D loc2D ;
    loc2D.latitude = mgLat;
    loc2D.longitude = mgLon;
    
    return loc2D;
}

+ (CLLocationCoordinate2D)transformBaiduFromMars:(CLLocationCoordinate2D) latLng
{
    
    double bd_lon = latLng.longitude;
    double bd_lat = latLng.latitude;
    
    double x = bd_lon - 0.0065;
    double y = bd_lat - 0.006;
    
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    
    CLLocationCoordinate2D loc2D ;
    loc2D.latitude =  z * sin(theta);
    loc2D.longitude = z * cos(theta);
    
    return loc2D;
}



#pragma mark - 安装判断

+ (BOOL)isInstallAMap{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        DYLogInfo(@"设备已安装高德地图");
        return YES;
    } else {
        DYLogInfo(@"设备未安装高德地图");
        return NO;
    }
}

+ (BOOL)isInstallBaiduMap{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        DYLogInfo(@"设备已安装百度地图");
        return YES;
    } else {
        DYLogInfo(@"设备未安装百度地图");
        return NO;
    }
}

+ (BOOL)isInstallGoogleMap{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        DYLogInfo(@"设备已安装谷歌地图");
        return YES;
    } else {
        DYLogInfo(@"设备未安装谷歌地图");
        return NO;
    }
}

+ (BOOL)isInstallQQMap{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        DYLogInfo(@"设备已安装腾讯地图");
        return YES;
    } else {
        DYLogInfo(@"设备未安装腾讯地图");
        return NO;
    }
}
#pragma mark - 打开地图
+ (void)openSystemMap:(GPSOpenAppMode)mode destinationName:(NSString *)name latitude:(double)lat longtitude:(double)lon{
    
    //注意 MKMap 使用的是 火星坐标，和 CL取的GPS坐标不一样
    
    MKMapItem *currentLocation        = [MKMapItem mapItemForCurrentLocation];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placeMark]; //目的地坐标
    toLocation.name = name; //目的地名字
    if (mode == GPSOpenAppModeGPS) { //地点标注
        [toLocation openInMapsWithLaunchOptions:nil];
    }else{//线路导航
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:NO]}];
        
        
    }
}

+ (void)openAmap:(GPSOpenAppMode)mode destinationName:(NSString *)name latitude:(double)lat longtitude:(double)lon{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
    //backScheme=myapp 这个参数也可以随便设置，如果用高德SDK的话，则需要按照api文档进行配置
    NSString *urlString;
    if (mode == GPSOpenAppModeGPS) {
        urlString = [NSString stringWithFormat:GaoDeGPSUrl, appName, name, @(lat), @(lon)];
    } else {
        
        urlString = [NSString stringWithFormat:GaoDeNavUrl, appName, APPScheme, name, @(lat).doubleValue, @(lon).doubleValue];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
 
}

+ (void)openBaidumap:(GPSOpenAppMode)mode destinationName:(NSString *)name latitude:(double)lat longtitude:(double)lon{
    
    NSString *urlString;
    if (mode == GPSOpenAppModeGPS) {
        urlString = [NSString stringWithFormat:BaiDuGPSUrl, @(lat), @(lon),name];
    } else {
        urlString = [NSString stringWithFormat:BaiDuNavUrl,  @(lat), @(lon),name];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
    
}

+ (void)openGoogleMap:(double)latitude longtitude:(double)lon{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
    
    NSString *urlString = [[NSString stringWithFormat:GoogleMapUrl,appName,APPScheme,latitude, lon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)openQQMap:(NSString *)destinationName latitude:(double)lat longtitude:(double)lon{

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *urlString = [[NSString stringWithFormat:QQMapUrl,destinationName,lat,lon,appName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

+ (UIAlertController *)actionSheetWithOpenMap:(GPSOpenAppMode)mode
                              destinationName:(NSString *)name
                                     latitude:(double)lat
                                   longtitude:(double)lon{
    
    UIAlertController *alertSheet = [UIAlertController  alertControllerWithTitle:@"选择地图"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertSheet addAction:cancelAction];
    
    UIAlertAction *systemAction = [UIAlertAction actionWithTitle:@"苹果地图"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                              
                                                             [GPSUtils openSystemMap:mode
                                                                     destinationName:name
                                                                            latitude:lat
                                                                          longtitude:lon];
                                                         }];
    
    [alertSheet addAction:systemAction ];
    
    
    if ([GPSUtils isInstallAMap]) {
        UIAlertAction *aMapAction = [UIAlertAction actionWithTitle:@"高德地图"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                     
                                                               [GPSUtils openAmap:mode
                                                                  destinationName:name
                                                                         latitude:lat
                                                                       longtitude:lon];
                                                           }];
        
        [alertSheet addAction:aMapAction];
    }
    
    
    if ([GPSUtils isInstallBaiduMap]) {
        UIAlertAction *baiduMapAction = [UIAlertAction actionWithTitle:@"百度地图"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                                   
                                                                   [GPSUtils openBaidumap:mode
                                                                          destinationName:name
                                                                                 latitude:lat
                                                                               longtitude:lon];
                                                               }];
        
        [alertSheet addAction:baiduMapAction];
    }
    
    if ([GPSUtils isInstallGoogleMap]) {
        UIAlertAction *googleMapAction = [UIAlertAction actionWithTitle:@"谷歌地图"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                         
                                                                    
                                                                    [GPSUtils openGoogleMap:lat longtitude:lon];
                                                                }];
        
        [alertSheet addAction:googleMapAction];
    }
    
    if ([GPSUtils isInstallQQMap]) {
        UIAlertAction *googleMapAction = [UIAlertAction actionWithTitle:@"腾讯地图"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                
                                                                    
                                                                    [GPSUtils openQQMap:name latitude:lat longtitude:lon];
                                                                }];
        
        [alertSheet addAction:googleMapAction];
    }
    
    return alertSheet;
}

#pragma mark private
+ (BOOL) outOfChina:(double) lat :(double) lon
{
    if (lon < 72.004 || lon > 137.8347) {
        return true;
    }
    if (lat < 0.8293 || lat > 55.8271) {
        return true;
    }
    return false;
}

+ (double) transformLat:(double)x  :(double) y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y +
    0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 *sin(2.0 * x *M_PI)) * 2.0 /
    3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 *sin(y / 3.0 *M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 *sin(y * M_PI / 30.0)) * 2.0 /
    3.0;
    return ret;
}

+ (double) transformLon:(double) x :(double) y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 /
    3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 *M_PI) + 300.0 *sin(x / 30.0 * M_PI)) * 2.0 /
    3.0;
    return ret;
}

@end
