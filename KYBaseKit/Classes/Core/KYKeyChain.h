//
//  KYKeyChain.h
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKey:(NSString *)service;

@end

NS_ASSUME_NONNULL_END
