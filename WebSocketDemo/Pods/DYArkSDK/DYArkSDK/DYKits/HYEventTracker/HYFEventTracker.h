////  HYFEventTracker.h
//  AppEventTracker
//
//  Created by Haisheng Ding on 2018/9/6.
//  Copyright © 2018年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 自动记录App事件，目前支持以下事件:
 * 1.UIViewController viewDidLoad,viewWillAppear,viewDidAppear,viewWillDisappear,viewDidDisappear,dismissViewControllerAnimated,setTitle
 * 2.UITableView tableView:didSelectRowAtIndexPath:
 * 3.UICollectionView collectionView:didSelectItemAtIndexPath:
 * 4.UINavigationController pushViewController,popViewControllerAnimated,popToViewController,popToRootViewControllerAnimated,setViewControllers
 * 5.UIControl sendAction:to:forEvent:\n
 * 监听以下通知:
 * UIApplicationDidEnterBackgroundNotification, UIApplicationWillEnterForegroundNotification,  UIApplicationDidFinishLaunchingNotification, UIApplicationDidBecomeActiveNotification,  UIApplicationWillResignActiveNotification, UIApplicationDidReceiveMemoryWarningNotification,  UIApplicationWillTerminateNotification, UIApplicationSignificantTimeChangeNotification,  UIApplicationWillChangeStatusBarOrientationNotification,  UIApplicationDidChangeStatusBarOrientationNotification, UIApplicationWillChangeStatusBarFrameNotification, UIApplicationDidChangeStatusBarFrameNotification,  UIApplicationBackgroundRefreshStatusDidChangeNotification, UIApplicationUserDidTakeScreenshotNotification,  UIApplicationProtectedDataWillBecomeUnavailable, UIApplicationProtectedDataDidBecomeAvailable
 *
 * 支持手动添加事件
 *
 * 支持手动添加key-value记录
 *
 * @note 事件记录总数受限，超出后按FIFO方式丢弃事件；key-value记录总数不受限制
 */
@interface HYFEventTracker : NSObject

/**
 * 启动记录，异步接口
 * @note 如果需要设置事件记录最大条数，请在该接口之前调用setMaxEventCount:
 */
+ (void)startTrace;

/**
 * 设置事件最大条数，默认300条
 * @note 需要在startTrace之前调用该接口
 * @param maxEventCount 事件最大条数
 */
+ (void)setMaxEventCount:(NSInteger)maxEventCount;

/**
 * 手动添加事件，异步接口
 * @param name 事件名
 * @param event 事件内容
 */
+ (void)addEventWithName:(NSString*)name event:(NSString*)event;

/**
 * 手动添加key-value记录，如果key已经存在，直接覆盖，异步接口
 * @param text 记录内容
 * @param key 记录key
 */
+ (void)recordText:(NSString*)text key:(NSString*)key;

/**
 * 获取所有记录，包括事件和key-value记录，同步接口
 * @return 事件和key-value记录
 */
+ (NSString*)fullTraces;

/**
 * 获取所有事件，同步接口
 * @return 事件
 */
+ (NSString*)eventTraces;

/**
 * 获取所有key-value记录，同步接口
 * @return key-value记录
 */
+ (NSString*)recordTraces;

@end
