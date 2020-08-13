#import <Foundation/Foundation.h>
#import "KiwiSDKMacro.h"

typedef NS_ENUM(NSInteger, DYEnvironmentVersion) {
    DYEnvironmentVersionDebug = 0,
    DYEnvironmentVersionSnapshot,
    DYEnvironmentVersionRelease
};

@protocol DYArkSDKManagerDataSource <NSObject>

@required

- (DYEnvironmentVersion)dy_environmentVersion;

- (BOOL)dy_isBeta;
@end

@interface DYArkSDKManager : NSObject<DYArkSDKManagerDataSource>

@property (nonatomic,assign) DYEnvironmentVersion environment;
@property (nonatomic,assign) BOOL isBeta;

@property (nonatomic,weak) id<DYArkSDKManagerDataSource> dataSource;

WF_AS_SINGLETION(DYArkSDKManager);

@end
