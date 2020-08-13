//
//  HYServiceLoaderProtocol.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYServiceEntryConfig;

@protocol IWFServiceEntryLoader <NSObject>

@required

- (HYServiceEntryConfig*)loadHYServiceEntryConfig;

@end
