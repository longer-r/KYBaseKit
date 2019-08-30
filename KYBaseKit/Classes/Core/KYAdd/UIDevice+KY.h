//
//  UIDevice+KY.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <UIKit/UIKit.h>
#import "KYVersionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (KY)

#pragma mark - 设备信息(Device Information)
///=============================================================================
/// @name 设备信息(Device Information)
///=============================================================================

///浏览器UserAgent
//+ (NSString *)ky_webUserAgent; 迁移到WebView

/// 判断设备是否是 iPad/iPad mini.
@property (nonatomic, readonly) BOOL ky_isPad;

/// 判断设备是否是 iPhone/iPod touch.
@property (nonatomic, readonly) BOOL ky_isPhone;

/// 判断设备是否是 模拟器
@property (nonatomic, readonly) BOOL ky_isSimulator;

/// 判断设备是否越狱
@property (nonatomic, readonly) BOOL ky_isJailbroken;

/// 判断设备是否可以打电话
@property (nonatomic, readonly) BOOL ky_canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

//设备当前使用语言环境
@property (nonatomic, readonly) NSString *ky_language;

/// KY 生成的唯一设备号，存放在keychina
@property (nonatomic, readonly) NSString *ky_udid;

//设备链接路由ssid
//@property (nonatomic, readonly) NSString *ky_ssid;

//设备广告跟踪标志符
@property (nonatomic, readonly) NSString *ky_idfa;

//设备identifierForVendor
@property (nonatomic, readonly) NSString *ky_idfv;

//设备序列号
//@property (nonatomic, readonly) NSString *ky_serialNumber;

//设备mac地址
//@property (nonatomic, readonly) NSString *ky_macAddress;

/// 设备型号
@property (nonatomic, readonly) NSString *ky_deviceModel;
@property (nonatomic, readonly) NSInteger ky_deviceModelStatus;

/// 设备唯一标识
//@property (nonatomic, readonly) NSString *ky_deviceUDID;

/// 第三方设备标识
@property (nonatomic, readonly) NSString *ky_openUDID;

//设备名称
@property (nonatomic, readonly) NSString *ky_machineName;

/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nonatomic, readonly) NSString *ky_machineModel;

/// The device's machine model name. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nonatomic, readonly) NSString *ky_machineModelName;

/// 进程启动时间
//@property (nonatomic, readonly) NSString *ky_rtime;

/*
 * 模拟设备IDFA
 * data-format: 626363D0-90D4-06BF-C281-384E4E69D3E2
 *
 * see detai: https://github.com/youmi/SimulateIDFA/wiki/
 */
@property (nonatomic, readonly) NSString *ky_simIDFA;

/// 系统启动时间
@property (nonatomic, readonly) NSDate *ky_systemUptime;

/// 是否首次安装
@property (nonatomic, readonly) BOOL ky_isFirstInstall;
/// 首次安装时间
@property (nonatomic, readonly) NSTimeInterval ky_firstInstallTime;

#pragma mark - System Vertion

/// 获取当前系统版本
@property (nonatomic, readonly) KYOperatingVersion ky_operatingSystemVersion;

/// 获取当前系统版本字符串
@property (nonatomic, readonly, copy) NSString *ky_operatingSystemVersionString;

/// 系统版本比较
- (BOOL) ky_isOperatingSystemAtLeastVersion:(KYOperatingVersion)version;

/// 设备系统版本 (e.g. 8.1)
+ (double)ky_systemVersion;

/// 系统版本号 (e.g. @"iOS 4.0")
+ (NSString *)ky_osVersion;

/// 系统内部版本 (版本号*100)(e.g. 7.1.1 = 711)
+ (NSInteger)ky_osVersionInteger;

#pragma mark - Network Information
///=============================================================================
/// @name Network Information
///=============================================================================

/// WIFI IP address of this device (can be nil). e.g. @"192.168.1.111"
@property (nullable, nonatomic, readonly) NSString *ky_ipAddressWIFI;

/// Cell IP address of this device (can be nil). e.g. @"10.2.2.222"
@property (nullable, nonatomic, readonly) NSString *ky_ipAddressCell;


/**
 Network traffic type:
 
 WWAN: Wireless Wide Area Network.
 For example: 3G/4G.
 
 WIFI: Wi-Fi.
 
 AWDL: Apple Wireless Direct Link (peer-to-peer connection).
 For exmaple: AirDrop, AirPlay, GameKit.
 */
typedef NS_OPTIONS(NSUInteger, KYNetworkTrafficType) {
    KYNetworkTrafficTypeWWANSent     = 1 << 0,
    KYNetworkTrafficTypeWWANReceived = 1 << 1,
    KYNetworkTrafficTypeWIFISent     = 1 << 2,
    KYNetworkTrafficTypeWIFIReceived = 1 << 3,
    KYNetworkTrafficTypeAWDLSent     = 1 << 4,
    KYNetworkTrafficTypeAWDLReceived = 1 << 5,
    
    KYNetworkTrafficTypeWWAN = KYNetworkTrafficTypeWWANSent | KYNetworkTrafficTypeWWANReceived,
    KYNetworkTrafficTypeWIFI = KYNetworkTrafficTypeWIFISent | KYNetworkTrafficTypeWIFIReceived,
    KYNetworkTrafficTypeAWDL = KYNetworkTrafficTypeAWDLSent | KYNetworkTrafficTypeAWDLReceived,
    
    KYNetworkTrafficTypeALL = KYNetworkTrafficTypeWWAN |
    KYNetworkTrafficTypeWIFI |
    KYNetworkTrafficTypeAWDL,
};

/**
 Get device network traffic bytes.
 
 @discussion This is a counter since the device's last boot time.
 Usage:
 
 uint64_t bytes = [[UIDevice currentDevice] getNetworkTrafficBytes:KYNetworkTrafficTypeALL];
 NSTimeInterval time = CACurrentMediaTime();
 
 uint64_t bytesPerSecond = (bytes - _lastBytes) / (time - _lastTime);
 
 _lastBytes = bytes;
 _lastTime = time;
 
 
 @param types traffic types
 @return bytes counter.
 */
- (uint64_t)ky_getNetworkTrafficBytes:(KYNetworkTrafficType)types;


#pragma mark - Disk Space
///=============================================================================
/// @name Disk Space
///=============================================================================

/// Total disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_diskSpace;

/// Free disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_diskSpaceFree;

/// Used disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_diskSpaceUsed;


#pragma mark - Memory Information
///=============================================================================
/// @name Memory Information
///=============================================================================

/// Total physical memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryTotal;

/// Used (active + inactive + wired) memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryUsed;

/// Free memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryFree;

/// Acvite memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryActive;

/// Inactive memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryInactive;

/// Wired memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryWired;

/// Purgable memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t ky_memoryPurgable;

#pragma mark - CPU Information
///=============================================================================
/// @name CPU Information
///=============================================================================

/// Avaliable CPU processor count.
@property (nonatomic, readonly) NSUInteger ky_cpuCount;

/// Current CPU usage, 1.0 means 100%. (-1 when error occurs)
@property (nonatomic, readonly) float ky_cpuUsage;

/// Current CPU usage per processor (array of NSNumber), 1.0 means 100%. (nil when error occurs)
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *ky_cpuUsagePerProcessor;


@end

NS_ASSUME_NONNULL_END
