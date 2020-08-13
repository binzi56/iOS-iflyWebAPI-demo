//
//  MarsCallbackAdapter.h
//  Wolf
//
//  Created by pengfeihuang on 17/3/8.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KiwiSDKMacro.h"

@protocol MarsStnCallbackDelegate <NSObject>

@required

- (void)trafficData:(ssize_t)send recv:(ssize_t)recv;

- (NSArray*)newsDns:(NSString*)host;

- (void)didReceivePush:(int32_t)cmdid msgPayLoad:(NSData*)data;

- (NSData*)request2BufferWithTaskId:(uint32_t)tid
                        userContext:(const void *)context;

- (NSInteger)buffer2ResponseWithTaskId:(uint32_t)tid
                          responseData:(NSData *)data
                           userContext:(const void *)context
                         channelSelect:(int32_t)channelSelect;

- (NSInteger)onTaskEndWithTaskID:(uint32_t)tid
                     userContext:(const void *)context
                         errType:(uint32_t)errtype
                         errCode:(uint32_t)errcode;

- (bool)makesureAuthed;

- (void)requestSync;

- (void)reportConnectStatus:(int)status longlinkStatus:(int)longlink_status;

- (void)reportLongLinkError:(int)errtype code:(int)errcode ip:(NSString*)ip port:(uint16_t)port lastNoopRtt:(uint64_t)lastNoopRtt recvElapsetime:(uint64_t)recvElapsetime;

- (void)reportLongLinkNoopRtt:(uint64_t)rtt;

- (void)reportLongLinkNoopMiss:(BOOL)miss;

- (bool)ispushDataWithCmdid:(uint32_t)cmdid taskId:(uint32_t)taskId;

- (uint32_t)longlink_noop_inteval;

- (void)longlink_noop_resp;

@end

@interface MarsStnCallback : NSObject<MarsStnCallbackDelegate>

WF_AS_SINGLETION(MarsStnCallback);

@property(nonatomic,weak) id<MarsStnCallbackDelegate> delegate;

@end

@interface MarsDeviceInfo : NSObject;

@property(nonatomic,strong) NSString* deviceName;
@property(nonatomic,strong) NSString* deviceType;

@end

@interface MarsAccountInfo : NSObject;

@property(nonatomic,assign) int64_t uid;
@property(nonatomic,strong) NSString* name;

@end

@protocol MarsAppCallbackDelegate <NSObject>

@required

- (NSString*)configFilePath;

- (MarsDeviceInfo *)deviceInfo;

- (MarsAccountInfo *)accountInfo;

- (int)clientVersion;

@end

@interface MarsAppCallback : NSObject<MarsAppCallbackDelegate>

WF_AS_SINGLETION(MarsAppCallback);

@property(nonatomic,weak) id<MarsAppCallbackDelegate> delegate;

@end
