// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

/** * created on : 2012-11-28 * author : yerungui, caoshaokun
 */
#include "stn_callback.h"

#import <mars/comm/autobuffer.h>
#import <mars/xlog/xlogger.h>
#import <mars/stn/stn.h>

#import "MarsCallbackAdapter.h"

namespace mars {
    namespace stn {
        
StnCallBack* StnCallBack::instance_ = NULL;
        
StnCallBack* StnCallBack::Instance() {
    if(instance_ == NULL) {
        instance_ = new StnCallBack;
    }
    
    return instance_;
}
        
void StnCallBack::Release() {
    delete instance_;
    instance_ = NULL;
}
        
bool StnCallBack::MakesureAuthed() {
    return [[MarsStnCallback sharedInstance] makesureAuthed];
}


void StnCallBack::TrafficData(ssize_t _send, ssize_t _recv) {
    [[MarsStnCallback sharedInstance] trafficData:_send recv:_recv];
}
        
std::vector<std::string> StnCallBack::OnNewDns(const std::string& _host) {
    std::vector<std::string> vector;
    NSString* host = [NSString stringWithFormat:@"%s",_host.c_str()];
    NSArray* dnsArr = [[MarsStnCallback sharedInstance] newsDns:host];
    for (NSString* ip in dnsArr) {
        vector.push_back([ip UTF8String]);
    }
    return vector;
}

void StnCallBack::OnPush(uint64_t _channel_id, uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend) {
    if (_body.Length() > 0) {
        NSData* recvData = [NSData dataWithBytes:(const void *) _body.Ptr() length:_body.Length()];
        [[MarsStnCallback sharedInstance] didReceivePush:_cmdid msgPayLoad:recvData];
    }
    
}

bool StnCallBack::Req2Buf(uint32_t _taskid, void* const _user_context, AutoBuffer& outbuffer, AutoBuffer& extend, int& error_code, const int channel_select) {
    NSData* requestData =  [[MarsStnCallback sharedInstance] request2BufferWithTaskId:_taskid userContext:_user_context];
    if (requestData == nil) {
        requestData = [[NSData alloc] init];
    }
    outbuffer.AllocWrite(requestData.length);
    outbuffer.Write(requestData.bytes,requestData.length);
    return true;
}

int StnCallBack::Buf2Resp(uint32_t _taskid, void* const _user_context, const AutoBuffer& _inbuffer, const AutoBuffer& _extend, int& _error_code, const int _channel_select) {

    int handle_type = mars::stn::kTaskFailHandleNormal;
    NSData* responseData = [NSData dataWithBytes:(const void *) _inbuffer.Ptr() length:_inbuffer.Length()];
    NSInteger errorCode = [[MarsStnCallback sharedInstance] buffer2ResponseWithTaskId:_taskid
                                                                         responseData:responseData
                                                                          userContext:_user_context
                                                                        channelSelect:_channel_select];
    
    if (errorCode != 0) {
        handle_type = mars::stn::kTaskFailHandleDefault;
    }
    
    return handle_type;
}

int StnCallBack::OnTaskEnd(uint32_t _taskid, void* const _user_context, int _error_type, int _error_code) {
    
    return (int)[[MarsStnCallback sharedInstance] onTaskEndWithTaskID:_taskid
                                                          userContext:_user_context
                                                              errType:_error_type
                                                              errCode:_error_code];

}

void StnCallBack::ReportConnectStatus(int _status, int longlink_status) {
    
    [[MarsStnCallback sharedInstance] reportConnectStatus:_status longlinkStatus:longlink_status];
}
        
void StnCallBack::ReportLongLinkError(ErrCmdType _err_type, int _err_code, const std::string& _ip, uint16_t _port , uint64_t last_noop_rtt ,uint64_t recv_elapsetime) {
    
    NSString *ip = [NSString stringWithCString:_ip.c_str()
                                      encoding:NSUTF8StringEncoding];
    
    [[MarsStnCallback sharedInstance] reportLongLinkError:_err_type code:_err_code ip:ip port:_port lastNoopRtt:last_noop_rtt recvElapsetime:recv_elapsetime];
}
        
void StnCallBack::ReportLongLinkNoopRtt(uint64_t rtt) {
    
    [[MarsStnCallback sharedInstance] reportLongLinkNoopRtt:rtt];
}
        
void StnCallBack::ReportLongLinkNoopMiss(bool miss) {
    
    [[MarsStnCallback sharedInstance] reportLongLinkNoopMiss:miss? YES: NO];
}

int  StnCallBack::GetLonglinkIdentifyCheckBuffer(AutoBuffer& _identify_buffer, AutoBuffer& _buffer_hash, int32_t& _cmdid) {
    
    return IdentifyMode::kCheckNever;
}

bool StnCallBack::OnLonglinkIdentifyResponse(const AutoBuffer& _response_buffer, const AutoBuffer& _identify_buffer_hash) {
    
    return true;
}
        
void StnCallBack::RequestSync() {
    [[MarsStnCallback sharedInstance] requestSync];
}
        
    }
}






