//
//  kiwisdkCore.h
//  KiwiSDK
//
//  Created by huya on 2018/7/30.
//  Copyright © 2018年 YY.Inc. All rights reserved.
//

#ifndef kiwisdkCore_h
#define kiwisdkCore_h

//如果是DEBUG那么认为是内部版本
#ifdef DEBUG
#define HYINTERNAL
#endif

//如果是企业版构建也是内部版本
#ifdef HYENTERPRISE
#define HYINTERNAL
#endif

///////////////macros ///////////////////

//注：假如一个作用域内有若干个cleanup的变量，他们的调用顺序是先入后出的栈式顺序；
typedef void (^wf_cleanupBlock_t)(void);
static inline void wf_executeCleanupBlock (__strong wf_cleanupBlock_t *block) {
    (*block)();
}

#define metamacro_concat_(A, B) A ## B

#define metamacro_concat(A, B) \
metamacro_concat_(A, B)

#define onWFExit \
try {} @finally {} \
__strong wf_cleanupBlock_t metamacro_concat(wf_exitBlock_, __LINE__) __attribute__((cleanup(wf_executeCleanupBlock), unused)) = ^


#define wf_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define wf_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#endif /* kiwisdkCore_h */
