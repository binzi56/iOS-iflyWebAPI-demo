
#import "DYArkSDKManager.h"

@interface DYArkSDKManager ()

@end

@implementation DYArkSDKManager

WF_DEF_SINGLETION(DYArkSDKManager);

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (DYEnvironmentVersion)environment
{
    if([self.dataSource respondsToSelector:@selector(dy_environmentVersion)]){
       return  [self.dataSource dy_environmentVersion];
    }
    
    return DYEnvironmentVersionDebug;
}

- (BOOL)isBeta
{
    if([self.dataSource respondsToSelector:@selector(dy_isBeta)]){
        return  [self.dataSource dy_isBeta];
    }
    
    return NO;
}

@end
