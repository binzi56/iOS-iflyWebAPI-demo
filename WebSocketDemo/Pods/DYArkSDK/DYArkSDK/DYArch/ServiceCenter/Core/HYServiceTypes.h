//
//  ServiceTypes.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/8.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHYService.h"
#import "IHYServiceEntryLoader.h"

#define HYServiceSectName "HYAnonServices"

#define HYAnontionDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define HYExportService(servicename,impl) \
char * k##servicename##_service HYAnontionDATA(HYAnonServices) = "{ \""#servicename"\" : \""#impl"\"}";

@protocol IWFServiceManager<NSObject>

@required

- (BOOL)registerService:(Class)cls toProtocol:(Protocol *)protocol extraProtocol:(Protocol *)extraProtocol;

- (BOOL)unregisterService:(Protocol *)protocol;

- (BOOL)unregisterExtraProtocol:(Protocol *)protocol;

- (id<IWFService>)serviceWithProtocol:(Protocol *)protocol;

- (id)objectForKeyedSubscript:(Protocol*)key;

@end

typedef enum {
    HYServiceEntryTypeShareObject
} HYServiceEntryType;

@interface HYServiceEntry : NSObject

@property(nonatomic,strong,readonly) Class cls;
@property(nonatomic,strong,readonly) Protocol* protocol;
@property(nonatomic,strong,readonly) Protocol* extraProtocol;
@property(nonatomic,assign,readonly) HYServiceEntryType type;

- (id)initWithClass:(Class)theClass
           protocol:(Protocol *)protocol
      extraProtocol:(Protocol *)extraProtocol
               type:(HYServiceEntryType)type;

- (id)initWithClass:(Class)theClass
           protocol:(Protocol *)protocol
               type:(HYServiceEntryType)type;

@end

@interface HYServiceEntryConfig : NSObject

@property(nonatomic,strong) NSArray<HYServiceEntry*>* entrys;

@end


