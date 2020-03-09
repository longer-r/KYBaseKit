//
//  YKNetworkMonitor.m
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import "KYNetworkMonitor.h"
#import "KYWeakBlockManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface KYNetworkMonitor()

@property(nonatomic, strong) KYWeakBlockManager *weakBlockManager;
@property(nonatomic, strong) KYWeakBlockManager *onceWeakBlockManager;
@property(nonatomic, assign) BOOL reachableViaWWAN;
@property(nonatomic, assign) BOOL reachableViaWiFi;
@property(nonatomic, assign) KYNetworkStatus networkStatus;
@property(nonatomic, assign) BOOL didInitNetworkStatus;
    
@end

@implementation KYNetworkMonitor

SingletonM

+ (void)load {

    //初始化网络状态是在后台线程做的， 提前调用，确保appDidLaunch时已获取到初始状态
    [[KYNetworkMonitor sharedInstance] startMonitoring];
}

- (instancetype)init {
    
    if (self=[super init]) {
        
        self.weakBlockManager = [[KYWeakBlockManager alloc] init];
        self.onceWeakBlockManager = [[KYWeakBlockManager alloc] init];
        _networkStatus = KYNetworkStatusNone;
        _didInitNetworkStatus = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNetworkChangeNotice:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)startMonitoring {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopMonitoring {
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (KYNetworkStatus)getNetworkStatusFromAF {
    
    BOOL reachable = self.isReachable;
    if (reachable == NO) {
        return KYNetworkStatusNone;
    }
    
    BOOL isWiFi = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    if (isWiFi) {
        return KYNetworkStatusWiFi;
    }else {
        return KYNetworkStatusWWAN;
    }
}

- (void)excuteIfReconnected:(BOOL)isReachable newStatus:(KYNetworkStatus)newStatus {
    
    static BOOL excuteOnce = NO;
    if (excuteOnce == YES) {
        return;
    }
    
    if (_networkStatus==KYNetworkStatusNone
        && newStatus!=KYNetworkStatusNone) {
        //无网络变成有网络
        @weakify(self)
        [_onceWeakBlockManager excuteAllBlocks:^(id tempBlock) {
            
            KYNetworkMonitorBlock netBlock = (KYNetworkMonitorBlock)tempBlock;
            if (netBlock) {
                netBlock(isReachable, weak_self.networkStatus, newStatus);
            }
        }];
        
        [_onceWeakBlockManager removeAll];
    }
    
    excuteOnce = YES;
}


#pragma mark- public
- (void)registerMonitorTarget:(id)target block:(KYNetworkMonitorBlock)block {
    
    [_weakBlockManager registerTarget:target block:block];
}

- (void)unregisterMonitorTarget:(id)target {
    
    [_weakBlockManager unRegisterTarget:target];
}

- (void)registerOnceMonitorTarget:(id)target block:(KYNetworkMonitorBlock)block {
    
    [_onceWeakBlockManager registerTarget:target block:block];
}

- (BOOL)isReachable {
    
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].isReachable;
    
    return isReachable;
}

- (KYNetworkDetailStatus)networkDetailStatus {
    
    KYNetworkDetailStatus detailStatus = KYNetworkDetailStatusNone;
    if (self.isReachable == NO) {
        return detailStatus;
    }
    
    if (self.reachableViaWiFi) {
        return KYNetworkDetailStatusWiFi;
    }
    
    NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                               CTRadioAccessTechnologyGPRS,
                               CTRadioAccessTechnologyCDMA1x];
    NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
    
    CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
    NSString *accessString = teleInfo.currentRadioAccessTechnology;
    
    if ([typeStrings4G containsObject:accessString]) {
        detailStatus = KYNetworkDetailStatus4G;
    } else if ([typeStrings3G containsObject:accessString]) {
        detailStatus = KYNetworkDetailStatus3G;
    } else if ([typeStrings2G containsObject:accessString]) {
        detailStatus = KYNetworkDetailStatus2G;
    } else {
        detailStatus = KYNetworkDetailStatusUnKnow;
    }
    
    return detailStatus;
}

#pragma mark- receive network change notice
- (void)receiveNetworkChangeNotice:(NSNotification *)notice {

    KYNetworkStatus newStatus = [self getNetworkStatusFromAF];
    BOOL isReachable = self.isReachable;
    if (_didInitNetworkStatus == YES) {
        [self excuteIfReconnected:isReachable newStatus:newStatus];
    }
    
    KYNetworkStatus preNetworkStatus = _networkStatus;
    self.networkStatus = newStatus;
    
    //网络环境已发生变化
    [_weakBlockManager excuteAllBlocks:^(id tempBlock) {
        KYNetworkMonitorBlock netBlock = (KYNetworkMonitorBlock)tempBlock;
        if (netBlock) {
            netBlock(isReachable, preNetworkStatus, newStatus);
        }
    }];
    
    _didInitNetworkStatus = YES;
}

@end
