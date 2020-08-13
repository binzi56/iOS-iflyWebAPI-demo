//
//  DYTestModeManager+protocol.h
//  Exchange
//
//  Created by EasyinWan on 13/06/2018.
//  Copyright © 2018 Consensus. All rights reserved.
//

#ifdef INTELNAL_VERSION

//#import "DYTestModeManager.h"

@protocol DYTestModeManagerProtocol <NSObject>

+ (void)setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args;

+ (id)getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig;

@end

@interface NSObject (TestManager) <DYTestModeManagerProtocol>

@end

#endif
