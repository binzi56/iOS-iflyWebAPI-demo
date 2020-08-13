//
//  DYTestModeDef.h
//  XHX
//
//  Created by EasyinWan on 2018/10/24.
//  Copyright © 2018 XYWL. All rights reserved.
//

#import "NSString+Log.h"

#ifdef INTELNAL_VERSION /* INTELNAL_VERSION */

    /* DYTestModeDef_h */
    #ifndef DYTestModeDef_h
    #define DYTestModeDef_h

    #import "DYTestModeManager.h"

    //define log module
    DYLogModule(Test);

    //static inline void kDYTest(void (^block)(void)) { block(); }
    #define kDYTest(VAL) do{VAL}while(0)
    #define kDYTestOnlyAssert                                                   \
        if (![DYTestModeManager sharedInstance].isTestSwitchOn)                       \
        {                                                                       \
            NSAssert(NO, @"func %@ is test only", NSStringFromSelector(_cmd));  \
            return;                                                             \
        }
    #define kDYTestIgnoredUndeclaredSelector(VAL) \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
        do{VAL}while(0)   \
        _Pragma("clang diagnostic pop")

    #endif /* DYTestModeDef_h */

#else /* INTELNAL_VERSION */

    //define log module
    #define kDYLogModuleTest @"Test"

    //static inline void kDYTest(void (^block)(void)) {}
    #define kDYTest(VAL)
    #define kDYTestOnlyAssert return;
    #define kDYTestIgnoredUndeclaredSelector(VAL)

#endif /* INTELNAL_VERSION */
