//
//  KYOpenUDID.h
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import <Foundation/Foundation.h>

//
// Usage:
//    #include "KYOpenUDID.h"
//    NSString* openUDID = [KYOpenUDID value];
//

NS_ASSUME_NONNULL_BEGIN

@interface KYOpenUDID : NSObject

+ (NSString *)value;
+ (NSString *)valueWithError:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
