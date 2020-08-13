//
//  DYMenuModel.h
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/9.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "DYInterlockPageViewProtocol.h"

@interface DYMenuModel : NSObject

@property (nonatomic, readonly, assign) NSUInteger tag;
@property (nonatomic, readonly, copy) NSString *text;

@property (nonatomic, assign) BOOL isDefaultSelected;

+ (instancetype)modelWithTag:(NSUInteger)tag
                        text:(NSString *)text;

- (void)resetText:(NSString *)text;

@end
