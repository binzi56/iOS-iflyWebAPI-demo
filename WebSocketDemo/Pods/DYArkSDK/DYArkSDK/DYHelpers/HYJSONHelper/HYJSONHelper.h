//
//  HYJSONHelper.h
//  HYBase
//
//  Created by Gideon on 2017/5/3.
//  Copyright © 2017年 pengfeihuang. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - NSString(HYJSONHelper)

@interface NSString(HYJSONHelper)

- (id)hyObjectFromJSONString;

@end

@interface NSData(HYJSONHelper)

- (id)hyObjectFromJSONData;

@end

@interface NSDictionary(HYJSONHelper)

- (NSString *)hyJSONString;

@end

@interface NSArray(HYJSONHelper)

- (NSString *)hyJSONString;

@end
