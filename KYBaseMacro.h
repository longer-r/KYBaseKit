//
//  KYBaseMacro.h
//  KYBaseKit
//
//  Created by zr on 2019/8/26.
//

#ifndef KYBaseMacro_h
#define KYBaseMacro_h


/**
 * 系统版本判断
 */
#pragma mark- 系统版本
#define _KY_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define _KY_SYSTEM_VERSION_EQUAL(version) (_KY_SYSTEM_VERSION == version)
#define _KY_SYSTEM_VERSION_LATER(version) (_KY_SYSTEM_VERSION >= version)

#define KY_IOS7_LATER      _KY_SYSTEM_VERSION_LATER(7.0)
#define KY_IOS8_LATER      _KY_SYSTEM_VERSION_LATER(8.0)
#define KY_IOS9_LATER      _KY_SYSTEM_VERSION_LATER(9.0)
#define KY_IOS10_LATER     _KY_SYSTEM_VERSION_LATER(10.0)
#define KY_IOS11_LATER     _KY_SYSTEM_VERSION_LATER(11.0)
#define KY_IOS12_LATER     _KY_SYSTEM_VERSION_LATER(12.0)
#define KY_IOS12_LATER     _KY_SYSTEM_VERSION_LATER(13.0)

#define KY_IOS_7    _KY_SYSTEM_VERSION_EQUAL(7.0)
#define KY_IOS_8    _KY_SYSTEM_VERSION_EQUAL(8.0)
#define KY_IOS_9    _KY_SYSTEM_VERSION_EQUAL(9.0)
#define KY_IOS_10   _KY_SYSTEM_VERSION_EQUAL(10.0)
#define KY_IOS_11   _KY_SYSTEM_VERSION_EQUAL(11.0)
#define KY_IOS_12   _KY_SYSTEM_VERSION_EQUAL(12.0)
#define KY_IOS_12   _KY_SYSTEM_VERSION_EQUAL(13.0)

/**
 * 布局尺寸宏
 */
#pragma mark- 布局尺寸宏

#define KY_IPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define KY_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define KY_STATUSBAR_ORIENTATION ([[UIApplication sharedApplication] statusBarOrientation])
//横屏
#define KY_PORTRAIT    UIInterfaceOrientationIsPortrait(KY_STATUSBAR_ORIENTATION)
//竖屏
#define KY_LANDSCAPE   UIInterfaceOrientationIsLandscape(KY_STATUSBAR_ORIENTATION)

// 设备全屏宽
#define KY_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
// 设备全屏高
#define KY_SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height

#define KY_SCREEN_MAX (MAX(KY_SCREEN_WIDTH, KY_SCREEN_HEIGHT))
#define KY_SCREEN_MIN (MIN(KY_SCREEN_WIDTH, KY_SCREEN_HEIGHT))

#define _KY_IPHONE_EQUAL(height) (KY_IPHONE && KY_SCREEN_MAX==height)
#define _KY_IPAD_EQUAL(height) (KY_IPAD && KY_SCREEN_MAX==height)

#define KY_IPHONE_4        _KY_IPHONE_EQUAL(480.0f) //320 * 480
#define KY_IPHONE_5        _KY_IPHONE_EQUAL(568.0f) //320 * 568
#define KY_IPHONE_6        _KY_IPHONE_EQUAL(667.0f)
#define KY_IPHONE_6_P      _KY_IPHONE_EQUAL(736.0f) //414 * 736
#define KY_IPHONE_X        _KY_IPHONE_EQUAL(812.0f) //375 * 812
#define KY_IPHONE_XR      （ _KY_IPHONE_EQUAL(896.0f) && [UIScreen mainScreen].scale == 2.0) ） //414 * 896
#define KY_IPHONE_XM      （ _KY_IPHONE_EQUAL(896.0f) && [UIScreen mainScreen].scale == 3.0) ） //414 * 896
#define KY_IPHONE_X_ALL    ( KY_IPHONE_X || KY_IPHONE_XM )

#define KY_IPAD_9_7        _KY_IPAD_EQUAL(1024.0f) //9.7英寸及以下   1024* 768     1.333
#define KY_IPAD_10_5       _KY_IPAD_EQUAL(1112.0f) //10.5英寸       1112* 834     1.333
#define KY_IPAD_11_0       _KY_IPAD_EQUAL(1194.0f) //11英寸         1194* 834     1.432
#define KY_IPAD_12_9       _KY_IPAD_EQUAL(1366.0f) //12.9英寸       1366* 1024    1.333

#pragma mark - 其他
//版本号
#define KY_AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#endif /* KYBaseMacroHelper_h */
