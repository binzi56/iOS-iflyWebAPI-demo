//
//  MarsCallbackAdapter.m
//  Wolf
//
//  Created by pengfeihuang on 17/3/8.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "MarsCallbackAdapter.h"

@implementation MarsStnCallback

WF_DEF_SINGLETION(MarsStnCallback);

- (void)trafficData:(ssize_t)send recv:(ssize_t)recv
{
    [self.delegate trafficData:send recv:recv];
}

- (NSArray*)newsDns:(NSString*)host
{
    return [self.delegate newsDns:host];
}

- (void)didReceivePush:(int32_t)cmdid msgPayLoad:(NSData*)data
{
    [self.delegate didReceivePush:cmdid msgPayLoad:data];
}

- (NSData*)request2BufferWithTaskId:(uint32_t)tid
                        userContext:(const void *)context
{
    return [self.delegate request2BufferWithTaskId:tid userContext:context];
}

- (NSInteger)buffer2ResponseWithTaskId:(uint32_t)tid
                          responseData:(NSData *)data
                           userContext:(const void *)context
                         channelSelect:(int32_t)channelSelect
{
    return [self.delegate buffer2ResponseWithTaskId:tid
                                       responseData:data
                                        userContext:context
                                      channelSelect:channelSelect];
}

- (NSInteger)onTaskEndWithTaskID:(uint32_t)tid
                     userContext:(const void *)context
                         errType:(uint32_t)errtype
                         errCode:(uint32_t)errcode
{
    return [self.delegate onTaskEndWithTaskID:tid
                                  userContext:context
                                      errType:errtype errCode:errcode];
}

- (bool)makesureAuthed
{
    return [self.delegate makesureAuthed];
}

- (void)requestSync
{
    [self.delegate requestSync];
}

- (void)reportConnectStatus:(int)status longlinkStatus:(int)longlink_status
{
    [self.delegate reportConnectStatus:status longlinkStatus:longlink_status];
}

- (void)reportLongLinkError:(int)errtype code:(int)errcode ip:(NSString*)ip port:(uint16_t)port lastNoopRtt:(uint64_t)lastNoopRtt recvElapsetime:(uint64_t)recvElapsetime
{
    [self.delegate reportLongLinkError:errtype code:errcode ip:ip port:port lastNoopRtt:lastNoopRtt recvElapsetime:recvElapsetime];
}

- (void)reportLongLinkNoopRtt:(uint64_t)rtt
{
    [self.delegate reportLongLinkNoopRtt:rtt];
}

- (void)reportLongLinkNoopMiss:(BOOL)miss
{
    [self.delegate reportLongLinkNoopMiss:miss];
}

- (bool)ispushDataWithCmdid:(uint32_t)cmdid taskId:(uint32_t)taskId
{
    return [self.delegate ispushDataWithCmdid:cmdid taskId:taskId];
}

- (uint32_t)longlink_noop_inteval
{
    return [self.delegate longlink_noop_inteval];
}

- (void)longlink_noop_resp
{
    [self.delegate longlink_noop_resp];
}

@end

@implementation MarsDeviceInfo

@end

@implementation MarsAccountInfo


@end

@implementation MarsAppCallback

WF_DEF_SINGLETION(MarsAppCallback);

- (NSString*)configFilePath
{
    return [self.delegate configFilePath];
}

- (MarsDeviceInfo *)deviceInfo
{
    return [self.delegate deviceInfo];
}

- (MarsAccountInfo *)accountInfo
{
    return [self.delegate accountInfo];
}

- (int)clientVersion
{
    return [self.delegate clientVersion];
}

@end
