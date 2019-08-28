//
//  KYVersionManager.h
//  AFNetworking
//
//  Created by 涂勇彬 on 2018/9/4.
//

#import <Foundation/Foundation.h>
#import "KYBaseMacro.h"

typedef struct {
    NSInteger majorVersion;
    NSInteger minorVersion;
    NSInteger patchVersion;
} KYOperatingVersion;

NSComparisonResult KY_CompareVersion(KYOperatingVersion left, KYOperatingVersion right);

typedef void(^KYVersionUpdateBlock)(KYOperatingVersion lastVersion);

@interface KYVersionManager : NSObject

SingletonH

/*
 * 应用启动后应当立即调用次方法
 */
- (void)upgradeIfNeed;

/*
 * 版本升级时， 小于version且不等于{0,0,0}， 将通过block回调
 * version, 格式参照， (KYOperatingVersion){2,1,2}
 * 注: 请在 +(void)load{} 方法里面调用，保证upgradeIfNeed执行时，各升级block已注册
 */
- (void)registerUpdateWithVerison:(KYOperatingVersion)version block:(KYVersionUpdateBlock)block;

+ (KYOperatingVersion)getOperatingVersionFromString:(NSString *)string;

+ (NSString *)getStringFromOperatingVersion:(KYOperatingVersion)version;

@end
