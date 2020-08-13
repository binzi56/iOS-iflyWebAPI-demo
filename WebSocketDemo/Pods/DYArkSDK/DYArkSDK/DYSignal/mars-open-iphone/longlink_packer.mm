// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.


/*
 * longlink_packer.cc
 *
 *  Created on: 2012-7-18
 *      Author: yerungui, caoshaokun
 */

#include "longlink_packer.h"

#ifdef __APPLE__
#include "mars/comm/autobuffer.h"
#include "mars/xlog/xlogger.h"
#else
#include "comm/autobuffer.h"
#include "comm/xlogger/xlogger.h"
#include "comm/socket/unix_socket.h"
#endif

#import "MarsCallbackAdapter.h"
#include "mars/stn/stn.h"

using namespace mars::stn;

static uint32_t sg_client_version = 0;
uint32_t kCmdid_heart_beat  = 0;
uint32_t kCmdid_signal      = 0;

#pragma pack(push, 1)
struct __STNetMsgXpHeader {
    uint32_t    head_length;
    uint32_t    client_version;
    uint32_t    cmdid;
    uint32_t    seq;
    uint32_t	body_length;
};
#pragma pack(pop)

namespace mars {
namespace stn {
    
    longlink_tracker* (*longlink_tracker::Create)()
    = []() {
        return new longlink_tracker;
    };
    
    void SetClientVersion(uint32_t _client_version)  {
        sg_client_version = _client_version;
    }
    
    static int __unpack_buffer(const void* _packed, size_t _packed_len, uint32_t& _cmdid, uint32_t& _seq, size_t& _package_len, size_t& _body_len) {
        __STNetMsgXpHeader st = {0};
        if (_packed_len < sizeof(__STNetMsgXpHeader)) {
            _package_len = 0;
            _body_len = 0;
            return LONGLINK_UNPACK_CONTINUE;
        }
        
        memcpy(&st, _packed, sizeof(__STNetMsgXpHeader));
        
        uint32_t head_len = ntohl(st.head_length);
        uint32_t client_version = ntohl(st.client_version);
        if (client_version != sg_client_version) {
            _package_len = 0;
            _body_len = 0;
            return LONGLINK_UNPACK_FALSE;
        }
        _cmdid = ntohl(st.cmdid);
        _seq = ntohl(st.seq);
        _body_len = ntohl(st.body_length);
        _package_len = head_len + _body_len;
        
        if (_package_len > 1024*1024) {
            return LONGLINK_UNPACK_FALSE;
        }
        if (_package_len > _packed_len) {
            return LONGLINK_UNPACK_CONTINUE;
        }
        return LONGLINK_UNPACK_OK;
    }
    
    void (*longlink_pack)(uint32_t _cmdid, uint32_t _seq, const AutoBuffer& _body, const AutoBuffer& _extension, AutoBuffer& _packed, longlink_tracker* _tracker)
    = [](uint32_t _cmdid, uint32_t _seq, const AutoBuffer& _body, const AutoBuffer& _extension, AutoBuffer& _packed, longlink_tracker* _tracker) {
        
        __STNetMsgXpHeader st = {0};
        st.head_length = htonl(sizeof(__STNetMsgXpHeader));
        st.client_version = htonl(sg_client_version);
        st.cmdid = htonl(_cmdid);
        st.seq = htonl(_seq);
        st.body_length = htonl(_body.Length());
        
        _packed.AllocWrite(sizeof(__STNetMsgXpHeader) + _body.Length());
        _packed.Write(&st, sizeof(st));
        
        if (NULL != _body.Ptr()) _packed.Write(_body.Ptr(), _body.Length());
        
        _packed.Seek(0, AutoBuffer::ESeekStart);
    };
    
    
    int (*longlink_unpack)(const AutoBuffer& _packed, uint32_t& _cmdid, uint32_t& _seq, size_t& _package_len, AutoBuffer& _body, AutoBuffer& _extension, longlink_tracker* _tracker)
    = [](const AutoBuffer& _packed, uint32_t& _cmdid, uint32_t& _seq, size_t& _package_len, AutoBuffer& _body, AutoBuffer& _extension, longlink_tracker* _tracker) {
        size_t body_len = 0;
        int ret = __unpack_buffer(_packed.Ptr(), _packed.Length(), _cmdid,  _seq, _package_len, body_len);
        
        if (LONGLINK_UNPACK_OK != ret) return ret;
        
        _body.Write(AutoBuffer::ESeekCur, _packed.Ptr(_package_len-body_len), body_len);
        
        return ret;
    };
    
    uint32_t (*longlink_noop_cmdid)()
    = []() -> uint32_t {
        return kCmdid_heart_beat;
    };
    
    uint32_t (*signal_keep_cmdid)()
    = []() -> uint32_t {
        return kCmdid_signal;
    };
    
    void (*longlink_noop_req_body)(AutoBuffer& _body, AutoBuffer& _extend)
    = [](AutoBuffer& _body, AutoBuffer& _extend) {
        
    };
    
    void (*longlink_noop_resp_body)(const AutoBuffer& _body, const AutoBuffer& _extend)
    = [](const AutoBuffer& _body, const AutoBuffer& _extend) {
        
    };
    
    uint32_t (*longlink_noop_interval)()
    = []() -> uint32_t {
        return [[MarsStnCallback sharedInstance] longlink_noop_inteval];
    };
    
    uint32_t (*longlink_noop_timeout)(uint64_t last_noop_actual_interval, uint64_t last_recv_interval)
    = [](uint64_t last_noop_actual_interval, uint64_t last_recv_interval) -> uint32_t {
        
        //如果三个心跳都发不出去才超时
//        if (last_recv_interval >= longlink_noop_interval() * 3) {
//            return 6 * 1000;
//        } else {
//            return [[MarsStnCallback sharedInstance] longlink_noop_inteval] * 2;
//        }
        return 10 * 1000;
    };
    
    bool (*longlink_complexconnect_need_verify)()
    = []() {
        return false;
    };
    
    bool (*longlink_ispush)(uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend)
    = [](uint32_t _cmdid, uint32_t _taskid, const AutoBuffer& _body, const AutoBuffer& _extend) {
        
        return [[MarsStnCallback sharedInstance] ispushDataWithCmdid:_cmdid taskId:_taskid];
    };
    
    bool (*longlink_identify_isresp)(uint32_t _sent_seq, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer& _body, const AutoBuffer& _extend)
    = [](uint32_t _sent_seq, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer& _body, const AutoBuffer& _extend) {
        return false;
    };
    
    bool  (*longlink_noop_isresp)(uint32_t _taskid, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer& _body, const AutoBuffer& _extend)
    = [](uint32_t _taskid, uint32_t _cmdid, uint32_t _recv_seq, const AutoBuffer& _body, const AutoBuffer& _extend) {
        
        return kCmdid_heart_beat == _cmdid && _taskid == Task::kNoopTaskID && (_recv_seq == Task::kNoopTaskID || _recv_seq <= 0);
    };
}
}
