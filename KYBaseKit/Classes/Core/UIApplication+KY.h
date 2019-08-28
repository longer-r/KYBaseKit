//
//  UIApplication+KY.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <UIKit/UIKit.h>
#import "KYVersionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (KY)

/// 文档目录，需要ITUNES同步备份的数据存这里
@property (nonatomic, readonly) NSURL *ky_documentsURL;
@property (nonatomic, readonly) NSString *ky_documentsPath;

/// 缓存目录，系统永远不会删除这里的文件，ITUNES会删除
@property (nonatomic, readonly) NSURL *ky_cachesURL;
@property (nonatomic, readonly) NSString *ky_cachesPath;

/// Library目录
@property (nonatomic, readonly) NSURL *ky_libraryURL;
@property (nonatomic, readonly) NSString *ky_libraryPath;

/// 缓存目录，APP退出后，系统可能会删除这里的内容
@property (nonatomic, readonly) NSString *ky_tempPath;

/// Application's Bundle Name (show in SpringBoard).
@property (nullable, nonatomic, readonly) NSString *ky_appBundleName;

/// Application's Bundle ID.  e.g. "com.ibireme.MyApp"
@property (nullable, nonatomic, readonly) NSString *ky_appBundleID;

/// Application's Version.  e.g. "1.2.0"
@property (nullable, nonatomic, readonly) NSString *ky_appVersion;

/// Application's Version Number.  e.g. {1,2,0}
@property (nonatomic, readonly) KYOperatingVersion ky_appVersionNumber;

/// Application's Version Number.  e.g. 1200
@property (nonatomic, readonly) NSUInteger ky_appVersionInt;

/// Application's Build number. e.g. "123"
@property (nullable, nonatomic, readonly) NSString *ky_appBuildVersion;

/// 应用SchemaURL. e.g. g10ch1
@property (nullable, nonatomic, readonly) NSString *ky_appSchemaURL;

/// 应用语言环境
@property (nullable, nonatomic, readonly) NSString *ky_appLanguage;

/// Whether this app is pirated (not install from appstore).
@property (nonatomic, readonly) BOOL ky_isPirated;

/// Whether this app is being debugged (debugger attached).
@property (nonatomic, readonly) BOOL ky_isBeingDebugged;

/// Current thread real memory used in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryUsage;

/// Current thread CPU usage, 1.0 means 100%. (-1 when error occurs)
@property (nonatomic, readonly) float ky_cpuUsage;

/**
 Returns `nil` in an application extension, otherwise returns the singleton app instance.
 
 @return `nil` in an application extension, otherwise the app instance is created in the `UIApplicationMain` function.
 */
+ (UIApplication *)ky_sharedApplication;


@end

NS_ASSUME_NONNULL_END
