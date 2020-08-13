// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

//
//  appcomm_callback.mm
//  MPApp
//
//  Created by yanguoyue on 16/3/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#include "app_callback.h"

#include <sstream>
#include <mars/comm/autobuffer.h>

#import "MarsCallbackAdapter.h"

namespace mars {
    namespace app {

AppCallBack* AppCallBack::instance_ = NULL;

AppCallBack* AppCallBack::Instance() {
    if(instance_ == NULL) {
        instance_ = new AppCallBack();
    }
    
    return instance_;
}

void AppCallBack::Release() {
    delete instance_;
    instance_ = NULL;
}

std::string AppCallBack::GetAppFilePath() {
    NSString* filePath = [[MarsAppCallback sharedInstance] configFilePath];
    return SAFE_UTF8STRING(filePath);
}
        
AccountInfo AppCallBack::GetAccountInfo() {
    
    MarsAccountInfo* account =[[MarsAppCallback sharedInstance] accountInfo];
    AccountInfo info;
    info.uin = account.uid;
    info.username = SAFE_UTF8STRING(account.name);
    return info;
}

unsigned int AppCallBack::GetClientVersion() {
    
    return [[MarsAppCallback sharedInstance] clientVersion];
}

DeviceInfo AppCallBack::GetDeviceInfo() {
    
    MarsDeviceInfo* device =[[MarsAppCallback sharedInstance] deviceInfo];
    DeviceInfo info;

    info.devicename = SAFE_UTF8STRING(device.deviceName);
    info.devicetype = SAFE_UTF8STRING(device.deviceType);;
    
    return info;
}

}}
