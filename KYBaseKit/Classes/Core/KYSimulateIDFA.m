//
//  SimulateIDFA.m
//  NON PRODUCTION RELEASE VERSION 1.0
//
//  Created by JFChen on 16/9/7.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "KYSimulateIDFA.h"

#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation KYSimulateIDFA

static NSString *ky_systemBootTime(){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return @"";
    }
    time_t bsec = boottime.tv_sec / 10000;
    
    NSString *bootTime = [NSString stringWithFormat:@"%ld",bsec];
    
    return bootTime;
}

static NSString *ky_countryCode() {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    return countryCode;
}

static NSString *ky_language() {
    NSString *language;
    NSLocale *locale = [NSLocale currentLocale];
    if ([[NSLocale preferredLanguages] count] > 0) {
        language = [[NSLocale preferredLanguages]objectAtIndex:0];
    } else {
        language = [locale objectForKey:NSLocaleLanguageCode];
    }
    
    return language;
}

static NSString *ky_systemVersion() {
    return [[UIDevice currentDevice] systemVersion];
}

static NSString *ky_deviceName(){
    return [[UIDevice currentDevice] name];
}


static const char *TDSIDFAModel =       "hw.model";
static const char *TDSIDFAMachine =     "hw.machine";
static NSString *ky_getSystemHardwareByName(const char *typeSpecifier) {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithUTF8String:answer];
    free(answer);
    return results;
}

static NSUInteger ky_getSysInfo(uint typeSpecifier) {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

static NSString *ky_carrierInfo() {
    NSMutableString* cInfo = [NSMutableString string];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *carrierName = [carrier carrierName];
    if (carrierName != nil){
        [cInfo appendString:carrierName];
    }
    
    NSString *mcc = [carrier mobileCountryCode];
    if (mcc != nil){
        [cInfo appendString:mcc];
    }
    
    NSString *mnc = [carrier mobileNetworkCode];
    if (mnc != nil){
        [cInfo appendString:mnc];
    }
    
    return cInfo;
}


static NSString *ky_systemHardwareInfo(){
    NSString *model = ky_getSystemHardwareByName(TDSIDFAModel);
    NSString *machine = ky_getSystemHardwareByName(TDSIDFAMachine);
    NSString *carInfo = ky_carrierInfo();
    NSUInteger totalMemory = ky_getSysInfo(HW_PHYSMEM);
    
    return [NSString stringWithFormat:@"%@,%@,%@,%td",model,machine,carInfo,totalMemory];
}



static NSString *ky_systemFileTime(){
    NSFileManager *file = [NSFileManager defaultManager];
    NSDictionary *dic= [file attributesOfItemAtPath:@"System/Library/CoreServices" error:nil];
    return [NSString stringWithFormat:@"%@,%@",[dic objectForKey:NSFileCreationDate],[dic objectForKey:NSFileModificationDate]];
}

static NSString *ky_disk(){
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSString *diskSize = [[fattributes objectForKey:NSFileSystemSize] stringValue];
    return diskSize;
}

static void ky_MD5_16(NSString *source, unsigned char *ret){
    const char* str = [source UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    for(int i = 4; i < CC_MD5_DIGEST_LENGTH - 4; i++) {
        ret[i-4] = result[i];
    }
}

static NSString *ky_combineTwoFingerPrint(unsigned char *fp1,unsigned char *fp2){
    NSMutableString *hash = [NSMutableString stringWithCapacity:36];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i+=1)
    {
        if (i==4 || i== 6 || i==8 || i==10)
            [hash appendString:@"-"];
        
        if (i < 8) {
            [hash appendFormat:@"%02X",fp1[i]];
        }else{
            [hash appendFormat:@"%02X",fp2[i-8]];
        }
    }
    
    return hash;
}

+ (NSString *)createSimulateIDFA {
    
    NSString *sysBootTime = ky_systemBootTime();
    NSString *countryC= ky_countryCode();
    NSString *languge = ky_language();
    NSString *deviceN = ky_deviceName();
    
    NSString *sysVer = ky_systemVersion();
    NSString *systemHardware = ky_systemHardwareInfo();
    NSString *systemFT = ky_systemFileTime();
    NSString *diskS = ky_disk();
    
    NSString *fingerPrintUnstablePart = [NSString stringWithFormat:@"%@,%@,%@,%@", sysBootTime, countryC, languge, deviceN];
    NSString *fingerPrintStablePart = [NSString stringWithFormat:@"%@,%@,%@,%@", sysVer, systemHardware, systemFT, diskS];
    
    unsigned char fingerPrintUnstablePartMD5[CC_MD5_DIGEST_LENGTH/2];
    ky_MD5_16(fingerPrintUnstablePart,fingerPrintUnstablePartMD5);
    
    unsigned char fingerPrintStablePartMD5[CC_MD5_DIGEST_LENGTH/2];
    ky_MD5_16(fingerPrintStablePart,fingerPrintStablePartMD5);
    
    NSString *simulateIDFA = ky_combineTwoFingerPrint(fingerPrintStablePartMD5,fingerPrintUnstablePartMD5);
    return simulateIDFA;
}

@end
