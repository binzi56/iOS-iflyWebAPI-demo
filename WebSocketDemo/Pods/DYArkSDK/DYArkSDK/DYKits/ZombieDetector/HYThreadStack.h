////  HYThreadStack.h
//  HYZombieDetector
//
//  Created by Haisheng Ding on 2018/5/23.
//  Copyright © 2018年 YY Inc. All rights reserved.
//

#include <stdio.h>

#include <stdint.h>
#include <iostream>

using namespace std;


class HYThreadStack
{
public:
    string currentStackInfo(); //get stack info with format {\ntid:xxx\r\nstack:[xxx,xxx,xxx]\n}
    void fetchCurrentStack(); //fetch current stack
    size_t occupyMemorySize(); //total occupy memory size, include stack memory and class memeory
    HYThreadStack();
    ~HYThreadStack();
private:
    uint32_t _tid; //线程id
    uint32_t _depth; //栈深度
    unsigned char* _stack; //iOS64位系统虚拟地址只用了36位，所以每个栈地址只用40位(char整数倍方便处理)，以节省内存，模拟器和32位系统不做特殊处理
};

inline HYThreadStack* hy_getCurrentStack() {
    HYThreadStack *thread_stack = new HYThreadStack();
    thread_stack->fetchCurrentStack();
    return thread_stack;
}
