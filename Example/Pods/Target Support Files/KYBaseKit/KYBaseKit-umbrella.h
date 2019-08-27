#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KYBaseMacro.h"
#import "KYKeyChain.h"
#import "NSObject+KYLayout.h"
#import "NSObject+KYRuntime.h"
#import "KYBaseKit.h"

FOUNDATION_EXPORT double KYBaseKitVersionNumber;
FOUNDATION_EXPORT const unsigned char KYBaseKitVersionString[];

