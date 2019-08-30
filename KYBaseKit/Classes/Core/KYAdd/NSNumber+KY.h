//
//  NSNumber+KY.h
//  KYBaseKit
//
//  Created by zr on 2019/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (KY)

/**
Creates and returns an NSNumber object from a string.
Valid format: @"12", @"12.345", @" -0xFF", @" .23e99 "...

@param string  The string described an number.

@return an NSNumber when parse succeed, or nil if an error occurs.
*/
+ (nullable NSNumber *)ky_numberWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
