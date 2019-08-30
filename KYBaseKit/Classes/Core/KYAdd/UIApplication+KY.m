//
//  UIApplication+KY.m
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import "UIApplication+KY.h"
#import "UIDevice+KY.h"
#import "KYBaseMacro.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <objc/runtime.h>

KYSYNTH_DUMMY_CLASS(UIApplication_YK)
@implementation UIApplication (KY)

+ (void)load
{
    // When you build an extension based on an Xcode template, you get an extension bundle that ends in .appex.
    // https://developer.apple.com/library/ios/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html
    if (![[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) {
        Method sharedApplicationMethod = class_getClassMethod([UIApplication class], @selector(sharedApplication));
        if (sharedApplicationMethod != NULL) {
            IMP sharedApplicationMethodImplementation = method_getImplementation(sharedApplicationMethod);
            Method rsk_sharedApplicationMethod = class_getClassMethod([UIApplication class], @selector(ky_sharedApplication));
            method_setImplementation(rsk_sharedApplicationMethod, sharedApplicationMethodImplementation);
        }
    }
}

+ (UIApplication *)ky_sharedApplication
{
    return nil;
}

- (NSURL *)ky_documentsURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)ky_documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)ky_cachesURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)ky_cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)ky_libraryURL {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)ky_libraryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSString *)ky_tempPath {
    return [[self ky_libraryPath] stringByAppendingFormat:@"/tmp"];
}


- (BOOL)ky_isPirated {
    if ([[UIDevice currentDevice] ky_isSimulator]) return YES; // Simulator is not from appstore
    
    if (getgid() <= 10) return YES; // process ID shouldn't be root
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }
    
    if (![self _TY_fileExistInMainBundle:@"_CodeSignature"]) {
        return YES;
    }
    
    if (![self _TY_fileExistInMainBundle:@"SC_Info"]) {
        return YES;
    }
    
    //if someone really want to crack your app, this method is useless..
    //you may change this method's name, encrypt the code and do more check..
    return NO;
}

- (BOOL)_TY_fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)ky_appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)ky_appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)ky_appVersion {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (KYOperatingVersion)ky_appVersionNumber {
    
    KYOperatingVersion version = [KYVersionManager getOperatingVersionFromString:[self ky_appVersion]];
    return version;
}

- (NSUInteger)ky_appVersionInt {
    
    NSUInteger verInt = [[self class] ky_getIntegerVer:self.ky_appVersion];
    return verInt;
}

- (NSString *)ky_appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)ky_appSchemaURL {
    
    NSArray * array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for ( NSDictionary * dict in array ) {
        
        NSArray * URLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if ( nil == URLSchemes || 0 == URLSchemes.count ) {
            continue;
        }
        
        NSString * schema = [URLSchemes objectAtIndex:0];
        if ( schema && schema.length ) {
            
            return schema;
        }
    }
    
    return @"";
}

- (NSString *)ky_appLanguage {
    
    NSArray *array = [[NSBundle mainBundle] preferredLocalizations];
    if (array && array.count>0) {
        NSString *lan = [array firstObject];
        return lan;
    }else {
        return [UIDevice currentDevice].ky_language;
    }
}

- (BOOL)ky_isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID; name[3] = getpid();
    
    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) {
        return ret != 0;
    }
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

- (int64_t)ky_memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

- (float)ky_cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (NSUInteger)ky_getIntegerVer:(NSString *)verStr {
    
    NSArray *arrVer = [verStr componentsSeparatedByString:@"."];
    if (arrVer==nil || arrVer.count==0) {
        return 0;
    }
    
    NSMutableArray *mutArray = [NSMutableArray arrayWithArray:arrVer];
    if (arrVer.count == 1) {
        [mutArray addObject:@(0)];
        [mutArray addObject:@(0)];
        
    }else if (arrVer.count == 2) {
        [mutArray addObject:@(0)];
    }
    
    NSInteger majorVer = [[mutArray objectAtIndex:0] integerValue];
    NSInteger minorVer = [[mutArray objectAtIndex:1] integerValue];
    NSInteger patchVer = [[mutArray objectAtIndex:2] integerValue];
    NSString *verLong = [NSString stringWithFormat:@"%zd%zd%02zd", majorVer, minorVer, patchVer];
    
    NSUInteger verInt = (NSUInteger)[verLong integerValue];
    
    return verInt;
}

@end


