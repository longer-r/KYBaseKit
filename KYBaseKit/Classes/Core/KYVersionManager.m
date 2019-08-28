//
//  NSNumber+KY.m
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import "KYVersionManager.h"

@interface KYWeakVersionBlockObject : NSObject
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) KYVersionUpdateBlock block;
@end

@implementation KYWeakVersionBlockObject

- (void)dealloc {
    
}

- (instancetype)initWithBlock:(KYVersionUpdateBlock)block version:(NSString *)version {
    
    self = [super init];
    if (self) {
        _block = block;
        _version = version;
    }
    return self;
}
@end

@interface KYVersionManager()

@property(nonatomic, strong) NSMutableArray *targetBlockArray;

@end

@implementation KYVersionManager

SingletonM

- (instancetype)init {
    
    if (self=[super init]) {
        self.targetBlockArray = [NSMutableArray array];
    }
    
    return self;
}


+ (NSString *)getStringFromOperatingVersion:(KYOperatingVersion)version {
    
    NSString *string = [NSString stringWithFormat:@"%zd.%zd.%zd", version.majorVersion, version.minorVersion, version.patchVersion];
    
    return string;
}

+ (KYOperatingVersion)getOperatingVersionFromString:(NSString *)string {
    
    if (string==nil) {
        return (KYOperatingVersion){0,0,0};
    }
    
    NSArray *array = [string componentsSeparatedByString:@"."];
    
    if (array==nil || array.count==0) {
        return (KYOperatingVersion){0,0,0};
    }
    
    KYOperatingVersion version = (KYOperatingVersion){0,0,0};
    
    if (array.count == 1) {
        
        version.majorVersion = [array[0] integerValue];
        
    }else if (array.count == 2) {
        
        version.majorVersion = [array[0] integerValue];
        version.minorVersion = [array[1] integerValue];

    }else if (array.count == 3) {
        
        version.majorVersion = [array[0] integerValue];
        version.minorVersion = [array[1] integerValue];
        version.patchVersion = [array[2] integerValue];
    }
    
    return version;
}

- (BOOL)isVersion1:(KYOperatingVersion)version1 lessThanVersion2:(KYOperatingVersion)version2 {
    
    if (version1.majorVersion==version2.majorVersion
        && version1.minorVersion==version2.minorVersion
        && version1.patchVersion==version2.patchVersion) {
        return NO;
    }
    
    if (version1.majorVersion > version2.majorVersion) {
        return NO;
    }else if (version1.majorVersion < version2.majorVersion) {
        return YES;
    }
    
    else if (version1.minorVersion > version2.minorVersion) {
        return NO;
    }else if (version1.minorVersion < version2.minorVersion) {
        return YES;
    }
    
    else if (version1.patchVersion > version2.patchVersion) {
        return NO;
    }else if (version1.patchVersion < version2.patchVersion) {
        return YES;
    }
    
    else {
        return YES;
    }
}

/*
 * 版本升级时， 小于version且不等于{0,0,0}， 将通过block回调
 * version, 格式参照， (KYOperatingVersion){2,1,2}
 * 注: 请在 +(void)load{} 方法里面调用，保证upgradeIfNeed执行时，各升级block已注册
 */
- (void)registerUpdateWithVerison:(KYOperatingVersion)version block:(KYVersionUpdateBlock)block {
    
    NSString *stringVersion = [KYVersionManager getStringFromOperatingVersion:version];
    KYWeakVersionBlockObject *temp = [[KYWeakVersionBlockObject alloc] initWithBlock:block version:stringVersion];
    [self.targetBlockArray addObject:temp];
}

- (void)upgradeIfNeed {
    
    //get current version
    NSString *currentVerString = [self getCurrentVersion];
    
    //get cache version
    KYOperatingVersion cacheVersion = [KYVersionManager getOperatingVersionFromString:[self getCacheVersion]];
    
    //版本比较
    for (KYWeakVersionBlockObject *object in self.targetBlockArray) {

        KYOperatingVersion targetVersion = [KYVersionManager getOperatingVersionFromString:object.version];
        BOOL less = [self isVersion1:cacheVersion lessThanVersion2:targetVersion];
        if (less == YES) {
            if (object.block) {
                object.block(cacheVersion);
            }
        }
    }
    
    [self cacheVersion:currentVerString];
}

- (NSString *)getCurrentVersion {
    
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [dic objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *array = [version componentsSeparatedByString:@"."];
    if (array && array.count >= 3) {
        return version;
    }

    if (array==nil || array.count==0) {
        return @"0.0.0";
        
    }else if (array.count==1) {
        NSString *temp = [NSString stringWithFormat:@"%@.0.0", version];
        return temp;
        
    }else if (array.count==2) {
        
        NSString *temp = [NSString stringWithFormat:@"%@.0", version];
        return temp;
        
    }else {
        return @"0.0.0";
    }
}

- (NSString *)getCacheVersion {
    
    NSString *version = [[NSUserDefaults standardUserDefaults] valueForKey:@"BBUpgradeCacheVersion"];
    
    return version;
}

- (void)cacheVersion:(NSString *)version {
    
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"BBUpgradeCacheVersion"];
}

@end


NSComparisonResult KY_CompareVersion(KYOperatingVersion left, KYOperatingVersion right) {
    
    //如果new版本信息为空，默认降序
    if (right.majorVersion == 0 && right.minorVersion == 0 && right.patchVersion == 0) {
        return NSOrderedDescending;
    }
    //如果old版本信息为空，默认升序
    if (left.majorVersion == 0 && left.minorVersion == 0 && left.patchVersion == 0) {
        return NSOrderedAscending;
    }
    //全部相等
    if (right.majorVersion == left.majorVersion &&
        right.minorVersion == left.minorVersion &&
        right.patchVersion == left.patchVersion) {
        return NSOrderedSame;
    }
    //比较主版本号
    if (left.majorVersion != right.majorVersion) {
        return left.majorVersion < right.majorVersion ? NSOrderedAscending : NSOrderedDescending;
    }
    if (left.minorVersion != right.minorVersion) {
        return left.minorVersion < right.minorVersion ? NSOrderedAscending : NSOrderedDescending;
    }
    if (left.patchVersion != right.patchVersion) {
        return left.patchVersion < right.patchVersion ? NSOrderedAscending : NSOrderedDescending;
    }
    
    return NSOrderedSame;
}
