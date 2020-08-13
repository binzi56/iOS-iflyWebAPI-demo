//
//  HYPlistServiceLoader.h
//  kiwi
//
//  Created by pengfeihuang on 16/12/19.
//  Copyright © 2016年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYServiceTypes.h"

@interface HYPlistEntrtyLoader : NSObject<IWFServiceEntryLoader>

@property(nonatomic,strong) NSString* filePath;
@property(nonatomic,assign) BOOL enableMock;

@end
