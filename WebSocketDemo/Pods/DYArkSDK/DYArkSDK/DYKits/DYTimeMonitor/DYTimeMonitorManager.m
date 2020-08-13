//
//  DYTimeMonitorManager.m
//  DYTimeMonitor
//
//  Created by shuaibin on 2019/6/14.
//  Copyright © 2019 shuaibin. All rights reserved.
//

#import "DYTimeMonitorManager.h"
#import "pthread.h"
#import <UIKit/UIKit.h>

@interface DYTimeMonitorManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray<DYTimeMonitorModel *> *> *data;
@property (nonatomic) pthread_mutex_t lock;

@end
@implementation DYTimeMonitorManager

+ (instancetype)sharedInstance {
    static DYTimeMonitorManager* timeMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeMonitor = [[DYTimeMonitorManager alloc] init];
    });
    return timeMonitor;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = [NSMutableDictionary dictionary];
        pthread_mutex_init(&_lock, NULL);
    }
    
    return self;
}

//打点起始方法
- (void)startWithType:(NSUInteger)type
{
    NSMutableArray *startArr = [NSMutableArray arrayWithObject:[DYTimeMonitorModel timeMonitorWithTime:CFAbsoluteTimeGetCurrent() description:@"start note"]];
    pthread_mutex_lock(&_lock);
    [_data setValue:startArr forKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
}

//打点方法
- (double)recordWithDescription:(NSString *)description type:(NSUInteger)type
{
    return [self recordWithDescription:description type:type recordType:DYTimeMonitorRecordTypeMedian isRecordFirst:YES];
}

- (double)recordWithDescription:(NSString *)description type:(NSUInteger)type recordType:(DYTimeMonitorRecordType)recordType isRecordFirst:(BOOL)isRecordFirst
{
    if (description.length == 0) {
        NSAssert(NO, @"打点方法未传入描述");
        return DYTimeMonitorErrorNoInputDescription;
    }
    
    NSMutableArray *startArr = [NSMutableArray array];
    pthread_mutex_lock(&_lock);
    startArr = [_data valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
    
    if (!startArr || startArr.count == 0) {
        //打点方法未设置开始打点时间
        return DYTimeMonitorErrorNoStart;
    }else{
        DYTimeMonitorModel *data;
        if (DYTimeMonitorRecordTypeMedian == recordType) {
            data = [startArr lastObject];
        }else if(DYTimeMonitorRecordTypeContinuous == recordType){
            data = startArr.firstObject;
        }
        
        //添加数据
        CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        
        __block NSInteger sameObjIndex = -1;
        [startArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.des isEqualToString:description]) {
                sameObjIndex = idx;
            }
        }];
        
        if (sameObjIndex == -1) {
            //新的description
            [startArr addObject:[DYTimeMonitorModel timeMonitorWithTime:currentTime description:description]];
        }else{
            //已有description
            if (!isRecordFirst) {
                DYTimeMonitorModel *updataData = [DYTimeMonitorModel timeMonitorWithTime:currentTime description:description];
                [startArr replaceObjectAtIndex:sameObjIndex withObject:updataData];
            }
        }
        
        pthread_mutex_lock(&_lock);
        [_data setValue:startArr forKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
        pthread_mutex_unlock(&_lock);
        
        return currentTime - data.time;
    }
}

//获取某个业务的打点记录
- (NSMutableArray<NSNumber *> *)getRecordWithType:(NSUInteger)type recordType:(DYTimeMonitorRecordType)recordType
{
    
    NSMutableArray<DYTimeMonitorModel *> *dataArr = [NSMutableArray array];
    pthread_mutex_lock(&_lock);
    dataArr = [_data valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
    
    if (!dataArr) {
        //展示打点记录方法找不到该业务数据
        return nil;
    }
    
    __block double duringData;
    __block NSMutableArray *resultArr = [NSMutableArray array];
    if (DYTimeMonitorRecordTypeMedian == recordType) {
        //记录中间值
        __block double beforeData;
        [dataArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                duringData = 0.f;
            }else{
                duringData = obj.time - beforeData;
            }
            
            beforeData = obj.time;
            
            [resultArr addObject:[NSNumber numberWithDouble:duringData]];
        }];
    }else if(DYTimeMonitorRecordTypeContinuous == recordType){
        //记录连续值
        DYTimeMonitorModel *firstModel = dataArr.firstObject;
        [dataArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                duringData = 0.f;
            }else{
                duringData = obj.time - firstModel.time;
            }
            [resultArr addObject:[NSNumber numberWithDouble:duringData]];
        }];
    }
    
    return [resultArr mutableCopy];
}

//获取某个业务的某条打点记录
- (DYTimeMonitorModel *)getRecordWithType:(NSUInteger)type description:(NSString *)description
{
    NSMutableArray<DYTimeMonitorModel *> *dataArr = [NSMutableArray array];
    pthread_mutex_lock(&_lock);
    dataArr = [_data valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
    
    __block DYTimeMonitorModel *model;
    [dataArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.des isEqualToString: description]) {
            model = obj;
            *stop = YES;
        }
    }];
    
    return model;
}

//重置所有业务
- (void)resetAll
{
    _data = nil;
}


//重置某个业务
- (void)resetWithType:(NSUInteger)type
{
    NSMutableArray<DYTimeMonitorModel *> *dataArr = [NSMutableArray array];
    pthread_mutex_lock(&_lock);
    [_data setValue:dataArr forKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
}

//展示某个业务(测试展示数据使用)
- (void)showRecordWithType:(NSUInteger)type recordType:(DYTimeMonitorRecordType)recordType
{
    NSMutableString *output = [[NSMutableString alloc] init];
    NSMutableArray *dataArr = [NSMutableArray array];
    pthread_mutex_lock(&_lock);
    dataArr = [_data valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)type]];
    pthread_mutex_unlock(&_lock);
    
    if (!dataArr) {
        NSAssert(NO, @"展示打点记录方法找不到该业务数据");
        return;
    }
    
    double allTime = 0;
    if (dataArr.count < 2) {
        NSAssert(NO, @"没有设置开始打点方法");
        return;
    }else{
        DYTimeMonitorModel *firstModel = dataArr.firstObject;
        DYTimeMonitorModel *lastModel = dataArr.lastObject;
        allTime = lastModel.time - firstModel.time;
    }
    
    __block double duringData, beforeData;
    if (DYTimeMonitorRecordTypeMedian == recordType) {
        //记录中间值
        [dataArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != 0) {
                duringData = obj.time - beforeData;
                [output appendFormat:@"#%lu %@ | %.3fs | %.2f%%\n", (unsigned long)idx, obj.des, duringData,  (double)(duringData / allTime) * 100.0];
            }
            
            beforeData = obj.time;
        }];
    }else if(DYTimeMonitorRecordTypeContinuous == recordType){
        //记录连续值
        DYTimeMonitorModel *firstModel = dataArr.firstObject;
        [dataArr enumerateObjectsUsingBlock:^(DYTimeMonitorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != 0) {
                duringData = obj.time - beforeData;
                [output appendFormat:@"#%lu %@ | %.3fs | %.2f%%\n", (unsigned long)idx, obj.des, (obj.time - firstModel.time),  (double)(duringData / allTime) * 100.0];
            }
            
            beforeData = obj.time;
        }];
    }
    
    [output appendFormat:@"\n业务%lu总耗时%.3fs", (unsigned long)type, allTime];
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"业务%lu结果", (unsigned long)type]
                                message:output
                               delegate:nil
                      cancelButtonTitle:@"确定"
                      otherButtonTitles:nil] show];
}

@end
