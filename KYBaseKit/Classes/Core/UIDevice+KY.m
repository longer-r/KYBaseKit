//
//  UIDevice+KY.m
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import "UIDevice+KY.h"
#import "KYBaseMacro.h"
#import "KYSimulateIDFA.h"
#import "UIApplication+KY.h"

@import SystemConfiguration.CaptiveNetwork;
@import AdSupport.ASIdentifierManager;

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>

#include <net/if.h>
#include <net/if_dl.h>
#include <mach/mach.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>

#import "KYKeychain.h"
#import "NSString+KY.h"
#import "KYOpenUDID.h"

NSString * KY_IDFA_KEY = @"com.tandy.idfa";

static NSString *__webuseragent = nil;

KYSYNTH_DUMMY_CLASS(UIDevice_KY)

@implementation UIDevice (KY)

+ (void)load {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KY_IDFA_KEY];
}

+ (double)ky_systemVersion {
    
    double version = [UIDevice currentDevice].systemVersion.doubleValue;;
    return version;
}

+ (NSString *)ky_osVersion {
    
    static NSString *osVerson;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        osVerson = [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    });
    
    return osVerson;
}

+ (NSInteger)ky_osVersionInteger {
    
    static NSInteger osIntVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        if ([NSString ky_isNotEmpty:systemVersion]) {
            systemVersion = [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        }
        
        if ([NSString ky_isNotEmpty:systemVersion]) {
            osIntVersion = [systemVersion intValue];
            if (systemVersion.length < 3)  {
                osIntVersion = 10 * osIntVersion;
            }else if (systemVersion.length < 2) {
                osIntVersion = 100 * osIntVersion;
            }
        }
    });
    
    return osIntVersion;
}

- (KYOperatingVersion)ky_operatingSystemVersion {
    
    static dispatch_once_t one;
    static KYOperatingVersion systemVersion;
    dispatch_once(&one, ^{
        systemVersion = [self.systemVersion ky_versionNumber];
    });
    
    return systemVersion;
}

- (NSString *)ky_operatingSystemVersionString {
    
    static dispatch_once_t one;
    static NSString *systemVersion;
    dispatch_once(&one, ^{
        systemVersion = [self.systemVersion copy];
    });
    
    return systemVersion;
}

- (BOOL)ky_isOperatingSystemAtLeastVersion:(KYOperatingVersion)version {
    
    NSComparisonResult result = KY_CompareVersion(self.ky_operatingSystemVersion, version);
    if (result == NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

- (BOOL)ky_isPad {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)ky_isPhone {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)ky_isSimulator {
    
    static dispatch_once_t one;
    static BOOL simu = NO;
    dispatch_once(&one, ^{
        NSString *model = [self ky_machineModel];
        if ([model isEqualToString:@"x86_64"] || [model isEqualToString:@"i386"]) {
            simu = YES;
        }
    });
    
    return simu;
}

- (BOOL)ky_isJailbroken {
    
    if ([self ky_isSimulator]) {
        return NO;
    }
    
    __block BOOL jailBreak = NO;
    NSArray *array = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt",
                       @"/usr/lib/system/libsystem_kernel.dylib",
                       @"Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/etc/apt"];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:obj];
        
        if ([obj isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]) {
            jailBreak |= !fileExist;
        }else {
            jailBreak |= fileExist;
        }
    }];
    
    return jailBreak;
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)ky_canMakePhoneCalls {
    
    __block BOOL can;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        can = [[UIApplication ky_sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    });
    
    return can;
}
#endif

- (NSString *)ky_language {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString *currentLanguage = nil;
    if ([languages count] > 0) {
        currentLanguage = [languages objectAtIndex:0];
    }
    
    return [NSString ky_notNilString:currentLanguage];
}

- (NSString *)ky_udid {
    
    NSString *openUDID = [KYOpenUDID value];
    return openUDID;
}

//- (NSString *)ky_ssid {
//    if ([self ky_isSimulator]) return @"";
//
//    static NSString *bssid = @"";
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
//        id info = nil;
//        for (NSString *ifnam in ifs) {
//            info = (__bridge id)CNCopyCurrentNetworkInfo((CFStringRef)CFBridgingRetain(ifnam));
//            if (info && [info count]) {
//                NSDictionary *dic = (NSDictionary *)info;
//                bssid = [dic valueForKey:@"BSSID"];
//                break;
//            }
//        }
//    });
//    return [NSString ky_notNilString:bssid];
//}

- (NSString *)ky_idfa {
    
    static NSString *idfa = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idfa = [[NSUserDefaults standardUserDefaults] valueForKey:KY_IDFA_KEY];
        if ([NSString ky_isEmpty:idfa]) {
            
            if(NSClassFromString(@"ASIdentifierManager")) {
                idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                [[NSUserDefaults standardUserDefaults] setValue:idfa forKeyPath:KY_IDFA_KEY];
            }
        }
    });
    
    return [NSString ky_notNilString:idfa];
}

- (NSString *)ky_idfv {
    
    static NSString *idfv = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            idfv = [[UIDevice currentDevice].identifierForVendor UUIDString];
        }
    });
    
    return [NSString ky_notNilString:idfv];
}

- (BOOL)ky_isFirstInstall {
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.ty.key.install"];
    if (number) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"com.ty.key.install"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (NSTimeInterval)ky_firstInstallTime {
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.ty.key.install"];
    if (number) {
        return [number doubleValue];
    }
    NSTimeInterval installTime = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setValue:@(installTime) forKey:@"com.ty.key.install"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return installTime;
}

//
//
//- (NSString *)ky_serialNumber {
//
//    static NSString *serialNumber = @"";
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        if ([[UIDevice currentDevice] ky_isJailbroken] || IOS7_OR_EARLIER) {
//
//            void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
//            if (IOKit) {
//                mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
//                CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
//                mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
//                CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
//                kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
//
//                if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease) {
//                    mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
//                    if (platformExpertDevice) {
//                        CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
//                        if (platformSerialNumber && CFGetTypeID(platformSerialNumber) == CFStringGetTypeID()) {
//                            serialNumber = [NSString stringWithString:(__bridge NSString *)platformSerialNumber];
//                            CFRelease(platformSerialNumber);
//                        }
//                        IOObjectRelease(platformExpertDevice);
//                    }
//                }
//                dlclose(IOKit);
//            }
//        }
//    });
//    return [NSString ky_notNilString:serialNumber];
//}
//
//- (NSString *)ky_macAddress {
//
//    static NSString *macAddress = @"";
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        int                    mib[6];
//        size_t                len;
//        char                *buf;
//        unsigned char        *ptr;
//        struct if_msghdr    *ifm;
//        struct sockaddr_dl    *sdl;
//        mib[0] = CTL_NET;
//        mib[1] = AF_ROUTE;
//        mib[2] = 0;
//        mib[3] = AF_LINK;
//        mib[4] = NET_RT_IFLIST;
//        if ((mib[5] = if_nametoindex("en0")) == 0) {
//            printf("Error: if_nametoindex error/n");
//            return;
//        }
//        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
//            printf("Error: sysctl, take 1/n");
//            return;
//        }
//        if ((buf = malloc(len)) == NULL) {
//            printf("Could not allocate memory. error!/n");
//            return;
//        }
//        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
//            printf("Error: sysctl, take 2");
//            return;
//        }
//        ifm = (struct if_msghdr *)buf;
//        sdl = (struct sockaddr_dl *)(ifm + 1);
//        ptr = (unsigned char *)LLADDR(sdl);
//        NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
//        free(buf);
//
//        macAddress = [outstring uppercaseString];
//    });
//
//    return [NSString ky_notNilString:macAddress];
//
//}
//
- (NSString *)ky_deviceModel {
    static NSString *deviceModel = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceModel = [UIDevice currentDevice].model;
    });
    return [NSString ky_notNilString:deviceModel];
}

- (NSInteger)ky_deviceModelStatus {
    
    static NSInteger deviceModelStatus = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *devModel = [self ky_machineName];
        if ([devModel rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].length > 0) {
            deviceModelStatus = 1;
        }else if ([devModel rangeOfString:@"iPod" options:NSCaseInsensitiveSearch].length > 0) {
            deviceModelStatus = 2;
        }else if ([devModel rangeOfString:@"iPad" options:NSCaseInsensitiveSearch].length > 0) {
            deviceModelStatus = 3;
        }
    });
    
    return deviceModelStatus;
}

//- (NSString *)ky_deviceUDID {
//
//    static NSString *deviceUDID = @"";
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
////        if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
////            deviceUDID = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
////        }
//#pragma clang diagnostic pop
//
//    });
//    return [NSString ky_notNilString:deviceUDID];
//}

- (NSString *)ky_openUDID {
    
    NSString *openUDID = [KYOpenUDID value];
    return openUDID;
}

- (NSString *)ky_machineName {
    
    static NSString *machineName = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    
    return [NSString ky_notNilString:machineName];
}

- (NSString *)ky_machineModel {
    
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    
    return model;
}

- (NSString *)ky_machineModelName {
    
    //https://gist.github.com/adamawolf/3048717
    
    static dispatch_once_t one;
    static NSString *name = @"";
    dispatch_once(&one, ^{
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];
        if (!model) {
            return;
        }
        
        NSDictionary *dic = @{
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4",
                              @"iPhone3,2" : @"Verizon iPhone 4",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5C",
                              @"iPhone5,4" : @"iPhone 5C",
                              @"iPhone6,1" : @"iPhone 5S",
                              @"iPhone6,2" : @"iPhone 5S",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              @"iPhone10,1" : @"iPhone 8",
                              @"iPhone10,4" : @"iPhone 8",
                              @"iPhone10,2" : @"iPhone 8 Plus",
                              @"iPhone10,5" : @"iPhone 8 Plus",
                              @"iPhone10,3" : @"iPhone X",
                              @"iPhone10,6" : @"iPhone X",
                              @"iPhone11,2" : @"iPhone XS",
                              @"iPhone11,4" : @"iPhone XS Max",
                              @"iPhone11,6" : @"iPhone XS Max",
                              @"iPhone11,8" : @"iPhone XR",
                              
                              @"iPod1,1" :  @"iPod Touch 1G",
                              @"iPod2,1" :  @"iPod Touch 2G",
                              @"iPod3,1" :  @"iPod Touch 3G",
                              @"iPod4,1" :  @"iPod Touch 4G",
                              @"iPod5,1" :  @"iPod Touch 5G",
                              @"iPod7,1" :  @"iPod Touch 6G",
                              
                              @"iPad1,1" :  @"iPad",
                              @"iPad2,1" :  @"iPad 2 (WiFi)",
                              @"iPad2,2" :  @"iPad 2 (GSM)",
                              @"iPad2,3" :  @"iPad 2 (CDMA)",
                              @"iPad2,4" :  @"iPad 2 (32nm)",
                              @"iPad2,5" :  @"iPad mini (WiFi)",
                              @"iPad2,6" :  @"iPad mini (GSM)",
                              @"iPad2,7" :  @"iPad mini (CDMA)",
                              @"iPad3,1" :  @"iPad 3(WiFi)",
                              @"iPad3,2" :  @"iPad 3(CDMA)",
                              @"iPad3,3" :  @"iPad 3(4G)",
                              @"iPad3,4" :  @"iPad 4 (WiFi)",
                              @"iPad3,5" :  @"iPad 4 (4G)",
                              @"iPad3,6" :  @"iPad 4 (CDMA)",
                              @"iPad4,1" :  @"iPad Air",
                              @"iPad4,2" :  @"iPad Air",
                              @"iPad4,3" :  @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" :  @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" :  @"iPad mini 4",
                              @"iPad5,2" :  @"iPad mini 4",
                              @"iPad5,3" :  @"iPad Air 2",
                              @"iPad5,4" :  @"iPad Air 2",
                              @"iPad6,3" :  @"iPad Pro",
                              @"iPad6,4" :  @"iPad Pro",
                              @"iPad6,7" :  @"iPad Pro 1",
                              @"iPad6,8" :  @"iPad Pro 1",
                              @"iPad6,11" :  @"iPad (2017)",
                              @"iPad6,12" :  @"iPad (2017)",
                              @"iPad7,1" :  @"iPad Pro 2",
                              @"iPad7,2" :  @"iPad Pro 2",
                              @"iPad7,3" :  @"iPad Pro",
                              @"iPad7,4" :  @"iPad Pro",
                              @"iPad7,5" :  @"iPad 6",
                              @"iPad7,6" :  @"iPad 6",
                              @"iPad8,1" :  @"iPad Pro 3",
                              @"iPad8,2" :  @"iPad Pro 3",
                              @"iPad8,3" :  @"iPad Pro 3",
                              @"iPad8,4" :  @"iPad Pro 3",
                              @"iPad8,5" :  @"iPad Pro 3",
                              @"iPad8,6" :  @"iPad Pro 3",
                              @"iPad8,7" :  @"iPad Pro 3",
                              @"iPad8,8" :  @"iPad Pro 3",
                              
                              
                              @"i386" : @"Simulator",
                              @"x86_64" : @"Simulator"
                              };
        name = dic[model];
        if (!name) {
            name = model;
        }
    });
    
    return name;
}

- (NSString *)ky_simIDFA {
    
    static NSString *simIDFA = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        simIDFA = [KYSimulateIDFA createSimulateIDFA];
    });
    
    return [NSString ky_notNilString:simIDFA];
}


- (NSDate *)ky_systemUptime {
    
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    return [[NSDate alloc] initWithTimeIntervalSinceNow:(0 - time)];
}

//
//- (NSString *)ky_rtime {
//
//    NSString *lsd= [[NSUserDefaults standardUserDefaults] valueForKey:@"KYDOSSTARTTIME"];
//    if ([NSString ky_isNotEmpty:lsd]) {
//        return lsd;
//    } else {
//        NSString * proc_useTiem;
//        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, 0};
//        size_t miblen = 4;
//        size_t size;
//        int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
//        struct kinfo_proc * process = NULL; struct kinfo_proc * newprocess = NULL;
//
//        do { size += size / 10; newprocess = realloc(process, size);
//            if (!newprocess) {
//                if (process) {
//                    free(process);
//                    process = NULL;
//                }
//                return nil;
//            }
//            process = newprocess;
//            st = sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
//        } while (st == -1 && errno == ENOMEM);
//
//        if (st == 0) {
//            if (size % sizeof(struct kinfo_proc) == 0){
//                int nprocess = (int)size / sizeof(struct kinfo_proc);
//                if (nprocess) {
//                    for (int i = nprocess - 1; i >= 0; i--){
//                        @autoreleasepool{ //the process duration
//                            double t = process[i].kp_proc.p_un.__p_starttime.tv_sec;
//                            proc_useTiem = [NSString stringWithFormat:@"%f",t];
//                            lsd = proc_useTiem;
//                            [[NSUserDefaults standardUserDefaults] setValue:lsd forKeyPath:@"KYDOSSTARTTIME"];
//                        }
//                    }
//                    free(process);
//                    process = NULL;
//                    return proc_useTiem;
//                }
//            }
//        }
//        return [NSString ky_notNilString:lsd];
//    }
//}

- (NSString *)ky_ipAddressWIFI {
    
    NSString *address = nil;
    struct ifaddrs *addrs = NULL;
    if (getifaddrs(&addrs) == 0) {
        struct ifaddrs *addr = addrs;
        while (addr != NULL) {
            if (addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:
                               inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                    break;
                }
            }
            addr = addr->ifa_next;
        }
    }
    freeifaddrs(addrs);
    
    return address;
}

- (NSString *)ky_ipAddressCell {
    
    NSString *address = nil;
    struct ifaddrs *addrs = NULL;
    if (getifaddrs(&addrs) == 0) {
        struct ifaddrs *addr = addrs;
        while (addr != NULL) {
            if (addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    address = [NSString stringWithUTF8String:
                               inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                    break;
                }
            }
            addr = addr->ifa_next;
        }
    }
    freeifaddrs(addrs);
    
    return address;
}

typedef struct {
    uint64_t en_in;
    uint64_t en_out;
    uint64_t pdp_ip_in;
    uint64_t pdp_ip_out;
    uint64_t awdl_in;
    uint64_t awdl_out;
} ky_net_interface_counter;


static uint64_t ky_net_counter_add(uint64_t counter, uint64_t bytes) {
    if (bytes < (counter % 0xFFFFFFFF)) {
        counter += 0xFFFFFFFF - (counter % 0xFFFFFFFF);
        counter += bytes;
    } else {
        counter = bytes;
    }
    return counter;
}

static uint64_t ky_net_counter_get_by_type(ky_net_interface_counter *counter, KYNetworkTrafficType type) {
    uint64_t bytes = 0;
    if (type & KYNetworkTrafficTypeWWANSent) bytes += counter->pdp_ip_out;
    if (type & KYNetworkTrafficTypeWWANReceived) bytes += counter->pdp_ip_in;
    if (type & KYNetworkTrafficTypeWIFISent) bytes += counter->en_out;
    if (type & KYNetworkTrafficTypeWIFIReceived) bytes += counter->en_in;
    if (type & KYNetworkTrafficTypeAWDLSent) bytes += counter->awdl_out;
    if (type & KYNetworkTrafficTypeAWDLReceived) bytes += counter->awdl_in;
    return bytes;
}

static ky_net_interface_counter ky_get_net_interface_counter() {
    static dispatch_semaphore_t lock;
    static NSMutableDictionary *sharedInCounters;
    static NSMutableDictionary *sharedOutCounters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInCounters = [NSMutableDictionary new];
        sharedOutCounters = [NSMutableDictionary new];
        lock = dispatch_semaphore_create(1);
    });
    
    ky_net_interface_counter counter = {0};
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        while (cursor) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                const struct if_data *data = cursor->ifa_data;
                NSString *name = cursor->ifa_name ? [NSString stringWithUTF8String:cursor->ifa_name] : nil;
                if (name) {
                    uint64_t counter_in = ((NSNumber *)sharedInCounters[name]).unsignedLongLongValue;
                    counter_in = ky_net_counter_add(counter_in, data->ifi_ibytes);
                    sharedInCounters[name] = @(counter_in);
                    
                    uint64_t counter_out = ((NSNumber *)sharedOutCounters[name]).unsignedLongLongValue;
                    counter_out = ky_net_counter_add(counter_out, data->ifi_obytes);
                    sharedOutCounters[name] = @(counter_out);
                    
                    if ([name hasPrefix:@"en"]) {
                        counter.en_in += counter_in;
                        counter.en_out += counter_out;
                    } else if ([name hasPrefix:@"awdl"]) {
                        counter.awdl_in += counter_in;
                        counter.awdl_out += counter_out;
                    } else if ([name hasPrefix:@"pdp_ip"]) {
                        counter.pdp_ip_in += counter_in;
                        counter.pdp_ip_out += counter_out;
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        dispatch_semaphore_signal(lock);
        freeifaddrs(addrs);
    }
    
    return counter;
}

- (uint64_t)ky_getNetworkTrafficBytes:(KYNetworkTrafficType)types {
    ky_net_interface_counter counter = ky_get_net_interface_counter();
    return ky_net_counter_get_by_type(&counter, types);
}


- (int64_t)ky_diskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)ky_diskSpaceFree {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)ky_diskSpaceUsed {
    int64_t total = self.ky_diskSpace;
    int64_t free = self.ky_diskSpaceFree;
    if (total < 0 || free < 0) return -1;
    int64_t used = total - free;
    if (used < 0) used = -1;
    return used;
}

- (int64_t)ky_memoryTotal {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}

- (int64_t)ky_memoryUsed {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return page_size * (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count);
}

- (int64_t)ky_memoryFree {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

- (int64_t)ky_memoryActive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}

- (int64_t)ky_memoryInactive {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.inactive_count * page_size;
}

- (int64_t)ky_memoryWired {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.wire_count * page_size;
}

- (int64_t)ky_memoryPurgable {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.purgeable_count * page_size;
}

- (NSUInteger)ky_cpuCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}

- (float)ky_cpuUsage {
    float cpu = 0;
    NSArray *cpus = [self ky_cpuUsagePerProcessor];
    if (cpus.count == 0) return -1;
    for (NSNumber *n in cpus) {
        cpu += n.floatValue;
    }
    return cpu;
}

- (NSArray *)ky_cpuUsagePerProcessor {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if (_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}

@end
