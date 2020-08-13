//
//  DYMenuModel.m
//  DYInterlockScrollView
//
//  Created by EasyinWan on 2019/5/9.
//  Copyright © 2019 ___fat___. All rights reserved.
//

#import "DYMenuModel.h"

@interface DYMenuModel ()

@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, copy) NSString *text;

@end

@implementation DYMenuModel

+ (instancetype)modelWithTag:(NSUInteger)tag
                       text:(NSString *)text
{
    DYMenuModel *model = [self.class new];
    model.tag = tag;
    model.text = text;    
    return model;
}


- (void)resetText:(NSString *)text
{
    self.text = text;
}
@end
