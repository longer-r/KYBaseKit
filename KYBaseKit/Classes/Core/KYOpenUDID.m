//
//  KYOpenUDID.m
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import "KYOpenUDID.h"

#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSPasteboard.h>
#endif

#import <AdSupport/AdSupport.h>

#import "KYKeychain.h"
#import <objc/objc.h>
#import <objc/runtime.h>

static NSString * kOpenUDIDSessionCache = nil;
static NSString * const kOpenUDIDKey = @"OpenUDID";
static NSString * const kBBOpenUDIDCacheKey = @"BBOpenUDIDCacheKey";
static NSString * const kOpenUDIDSlotKey = @"OpenUDID_slot";
static NSString * const kOpenUDIDAppUIDKey = @"OpenUDID_appUID";
static NSString * const kOpenUDIDTSKey = @"OpenUDID_createdTS";
static NSString * const kOpenUDIDOOTSKey = @"OpenUDID_optOutTS";
static NSString * const kOpenUDIDDomain = @"org.OpenUDID";
static NSString * const kOpenUDIDPasteboardName = @"org.OpenUDID.slot.0";
static NSString * const kOpenUDIDKeychainCacheKey = @"com.kyd.keychain.openudid";

NSString *const KYKeychainServiceName = @"kyd_keychain";

@implementation KYOpenUDID
// Archive a NSDictionary inside a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (void)_setDict:(id)dict forPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:kOpenUDIDDomain];
#else
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forType:kOpenUDIDDomain];
#endif
}

// Retrieve an NSDictionary from a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    id item = [pboard dataForPasteboardType:kOpenUDIDDomain];
#else
    id item = [pboard dataForType:kOpenUDIDDomain];
#endif
    if (item) {
        @try{
            item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        } @catch(NSException* e) {
            item = nil;
        }
    }
    
    // return an instance of a MutableDictionary
    return [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item : nil];
}

// Private method to create and return a new OpenUDID
// Theoretically, this function is called once ever per application when calling [OpenUDID value] for the first time.
// After that, the caching/pasteboard/redundancy mechanism inside [OpenUDID value] returns a persistent and cross application OpenUDID
//
+ (NSString*) _generateFreshOpenUDID {
    
    NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    NSString *formatIDFA = [self formatUUIDString:idfa];
    if (formatIDFA) {
        
        return formatIDFA;
    }
    
    NSString *UUID = [self ky_stringWithUUID];
    NSString *openUDID = [self formatUUIDString:UUID];
    
    return openUDID;
}

+ (NSString *)ky_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    CFRelease(uuid);
    CFRelease(cfstring);
    
    NSString *openUDID = [NSString stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15],
                          (unsigned long)(arc4random() % NSUIntegerMax)];
    return openUDID;
}

+ (NSString *)formatUUIDString:(NSString *)uuidString {
    
    if (uuidString && [uuidString isEqualToString:@"00000000-0000-0000-0000-000000000000"]==NO) {
        NSString *temp = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (temp && temp.length>0) {
            NSString *formatString = [temp lowercaseString];
            return formatString;
        }
    }
    
    return nil;
}

// Main public method that returns the OpenUDID
// This method will generate and store the OpenUDID if it doesn't exist, typically the first time it is called
// It will return the null udid (forty zeros) if the user has somehow opted this app out (this is subject to 3rd party implementation)
// Otherwise, it will register the current app and return the OpenUDID
//

+ (NSMutableDictionary *)getDictFromPasteboard {
    
    //读取UIPasteboard缓存
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:kOpenUDIDPasteboardName create:NO];
#else
    NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:kOpenUDIDPasteboardName];
#endif
    
    if (slotPB == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [KYOpenUDID _getDictFromPasteboard:slotPB];
    if (dict == nil) {
        return nil;
    }
    
    NSString *openUDID = [dict objectForKey:kOpenUDIDKey];
    if (openUDID && openUDID.length > 0) {
        return dict;
    }else {
        return nil;
    }
}

+ (void)writeDictToPasteboard:(NSMutableDictionary *)dict {
    
    if (dict==nil || [dict isKindOfClass:NSMutableDictionary.class]==NO) {
        return;
    }
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:kOpenUDIDPasteboardName create:YES];
    [slotPB setPersistent:YES];
#else
    NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:kOpenUDIDPasteboardName];
#endif
    
    if (dict) {
        [dict setObject:kOpenUDIDPasteboardName forKey:kOpenUDIDSlotKey];
    }
    
    if (dict) {
        [KYOpenUDID _setDict:dict forPasteboard:slotPB];
    }
}

+ (void)writeDictToUserDefaults:(NSMutableDictionary *)dict {
    
    if (dict==nil || [dict isKindOfClass:NSDictionary.class]==NO) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dict forKey:kBBOpenUDIDCacheKey];
}

+ (NSMutableDictionary *)getDictFromUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //读取userDefaults缓存
    NSDictionary *temp = [defaults objectForKey:kBBOpenUDIDCacheKey];
    if (temp == nil) {
        //兼容旧版本
        temp = [defaults objectForKey:kOpenUDIDKey];
    }
    
    if ([temp isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:temp];
        NSString *openUDID = [dict objectForKey:kOpenUDIDKey];
        
        if (openUDID && openUDID.length > 0) {
            return dict;
        }else {
            return nil;
        }
        
    }else {
        return nil;
    }
}

+ (NSString *)getOpenUDIDFromOldCache {
    
    //读取userDefaults缓存
    NSMutableDictionary *defaultsCacheDict = [self getDictFromUserDefaults];
    if (defaultsCacheDict != nil) {
        
        kOpenUDIDSessionCache = [defaultsCacheDict objectForKey:kOpenUDIDKey];
        return kOpenUDIDSessionCache;
        
    }else {
        
        //读取UIPasteboard缓存
        NSMutableDictionary *pasteboardDict = [self getDictFromPasteboard];
        if (pasteboardDict != nil) {
            
            kOpenUDIDSessionCache = [pasteboardDict objectForKey:kOpenUDIDKey];
            return kOpenUDIDSessionCache;
        }
    }
    
    return nil;
}

+ (NSString *)getOpenUDIDFromKeychain {
    
    NSString *openUDID = nil;
    
    NSMutableDictionary *keychain = [NSMutableDictionary dictionaryWithDictionary:[KYKeychain load:KYKeychainServiceName]];
    if (keychain && [keychain isKindOfClass:[NSMutableDictionary class]]) {
        openUDID = [keychain objectForKey:kOpenUDIDKeychainCacheKey];
    }
    
    return openUDID;
}

+ (void)writeOpenUDIDToKeychain:(NSString *)openUDID {
    
    if (openUDID==nil || [openUDID isEqualToString:@""]==YES) {
        return;
    }
    
    NSMutableDictionary *keychain = [NSMutableDictionary dictionaryWithDictionary:[KYKeychain load:KYKeychainServiceName]];
    
    if (nil == keychain) {
        keychain = [NSMutableDictionary dictionary];
    }
    [keychain setObject:openUDID forKey:kOpenUDIDKeychainCacheKey];
    [KYKeychain save:KYKeychainServiceName data:keychain];
}

+ (NSString *)value {
    return [KYOpenUDID valueWithError:nil];
}

+ (NSString *)valueWithError:(NSError **)error {
    
    if (kOpenUDIDSessionCache != nil) {
        return kOpenUDIDSessionCache;
    }
    
    //从keychain读取
    kOpenUDIDSessionCache = [self getOpenUDIDFromKeychain];
    if (kOpenUDIDSessionCache) {
        return kOpenUDIDSessionCache;
    }
    
    //兼容旧版， 从旧版缓存中获取
    kOpenUDIDSessionCache = [self getOpenUDIDFromOldCache];
    if (kOpenUDIDSessionCache) {
        
        [self writeOpenUDIDToKeychain:kOpenUDIDSessionCache];
        return kOpenUDIDSessionCache;
    }
    
    //没有取到缓存的OpenUDID， 创建一个
    kOpenUDIDSessionCache = [self _generateFreshOpenUDID];
    [self writeOpenUDIDToKeychain:kOpenUDIDSessionCache];
    
    return kOpenUDIDSessionCache;
}

@end
