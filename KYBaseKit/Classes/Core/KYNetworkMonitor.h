//
//  YKNetworkMonitor.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <Foundation/Foundation.h>
#import "KYBaseMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KYNetworkStatus) {
    
    KYNetworkStatusNone  = 0, ///< Not Reachable
    KYNetworkStatusWWAN  = 1, ///< Reachable via WWAN (2G/3G/4G/5G)
    KYNetworkStatusWiFi  = 2, ///< Reachable via WiFi
};

typedef NS_ENUM(NSUInteger, KYNetworkDetailStatus) {
    
    KYNetworkDetailStatusNone      = 0,
    KYNetworkDetailStatusWiFi      = 1,
    KYNetworkDetailStatus2G        = 2,
    KYNetworkDetailStatus3G        = 3,
    KYNetworkDetailStatus4G        = 4,
    KYNetworkDetailStatus5G        = 5,
    KYNetworkDetailStatusUnKnow    = 6,
};

typedef void(^KYNetworkMonitorBlock)(BOOL isReachable, KYNetworkStatus preStatus, KYNetworkStatus currentStatus);

@interface KYNetworkMonitor : NSObject

SingletonH

//网络类型 None/WWAN/WiFi (Support KVO, you should replace with registerMonitorTarget:)
@property(nonatomic, assign, readonly) KYNetworkStatus networkStatus;

//详细网络类型 None/WiFi/2G/3G/4G/5G/UnKnow  (not Support KVO)
@property(nonatomic, assign, readonly) KYNetworkDetailStatus networkDetailStatus;

//当前网络是否连接   (not Support KVO)
@property(nonatomic, assign, readonly) BOOL isReachable;

/*
 * 注册网络变化监听
 */
- (void)registerMonitorTarget:(id)target block:(KYNetworkMonitorBlock)block;

/*
 * 注销网络变化监听
 */
- (void)unregisterMonitorTarget:(id)target;

/*
 * 注册网络重连监听
 * 此方法只有在应用启动无网络，变为有网络时执行一次Block
 */
- (void)registerOnceMonitorTarget:(id)target block:(KYNetworkMonitorBlock)block;


@end

NS_ASSUME_NONNULL_END
