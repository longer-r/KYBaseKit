//
//  KYBaseMacro.h
//  KYBaseKit
//
//  Created by zr on 2019/8/26.
//

#import "NSObject+KYLayout.h"
#import <sys/time.h>
#import <pthread.h>

#ifndef KYBaseMacro_h
#define KYBaseMacro_h

#ifdef __cplusplus
#define KY_EXTERN_C_BEGIN  extern "C" {
#define KY_EXTERN_C_END  }
#else
#define KY_EXTERN_C_BEGIN
#define KY_EXTERN_C_END
#endif



KY_EXTERN_C_BEGIN

#ifndef KY_CLAMP // return the clamped value
#define KY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef KY_SWAP // swap two value
#define KY_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif


#define KYAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define KYCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define KYAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define KYCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define KYAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#define KYCAssertMainThread() NSCAssert([NSThread isMainThread], @"This method must be called on the main thread")


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
#define KY_IOS13_LATER     _KY_SYSTEM_VERSION_LATER(13.0)

#define KY_IOS_7    _KY_SYSTEM_VERSION_EQUAL(7.0)
#define KY_IOS_8    _KY_SYSTEM_VERSION_EQUAL(8.0)
#define KY_IOS_9    _KY_SYSTEM_VERSION_EQUAL(9.0)
#define KY_IOS_10   _KY_SYSTEM_VERSION_EQUAL(10.0)
#define KY_IOS_11   _KY_SYSTEM_VERSION_EQUAL(11.0)
#define KY_IOS_12   _KY_SYSTEM_VERSION_EQUAL(12.0)
#define KY_IOS_13   _KY_SYSTEM_VERSION_EQUAL(13.0)

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
#define KY_IPHONE_XR       ( _KY_IPHONE_EQUAL(896.0f) && [UIScreen mainScreen].scale == 2.0 ) //414 * 896
#define KY_IPHONE_XM       ( _KY_IPHONE_EQUAL(896.0f) && [UIScreen mainScreen].scale == 3.0 )  //414 * 896
#define KY_IPHONE_X_ALL    ( KY_IPHONE_X || KY_IPHONE_XM )

#define KY_IPAD_9_7        _KY_IPAD_EQUAL(1024.0f) //9.7英寸及以下   1024* 768     1.333
#define KY_IPAD_10_5       _KY_IPAD_EQUAL(1112.0f) //10.5英寸       1112* 834     1.333
#define KY_IPAD_11_0       _KY_IPAD_EQUAL(1194.0f) //11英寸         1194* 834     1.432
#define KY_IPAD_12_9       _KY_IPAD_EQUAL(1366.0f) //12.9英寸       1366* 1024    1.333

/**
 * 单例宏
 */
#pragma mark - 单例

#undef    SingletonH
#define SingletonH + (instancetype)sharedInstance;

#undef    SingletonM
#define SingletonM \
static id _instance; \
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}

/**
 * 布局缩放
 */
#pragma mark - 布局缩放

#define KYWidth(width) ([self ky_getWidth:(width)])

#define KYScaleSpace(width) ([self ky_getSpaceWidth:(width)])

#define KYFrame(x,y,width,height) CGRectMake(KYWidth(x), KYWidth(y), KYWidth(width), KYWidth(height))

#define KYSize(width, height) CGSizeMake(KYWidth(width), KYWidth(height))

#define KYPoint(width, height) CGPointMake(KYWidth(width), KYWidth(height))

#define KYEdgeInsets(top, left, bottom, right) UIEdgeInsetsMake(KYWidth(top), KYScaleSpace(left), KYWidth(bottom), KYScaleSpace(right))


/**
 Perform Selector with ignored warning
 
 Example:
 KYPerformSelector(self, selector);
 */
#undef KYPerformSelector
#define KYPerformSelector(_target, _selector)                           \
if ([_target respondsToSelector:@selector(_selector)]) {        \
[_target performSelector:@selector(_selector)];             \
}


/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 More info: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 Example:
 YYSYNTH_DUMMY_CLASS(UIColor_YK)
 */
#ifndef KYSYNTH_DUMMY_CLASS
#define KYSYNTH_DUMMY_CLASS(_name_) \
@interface KYSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation KYSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


/**
Synthsize a dynamic object property in @implementation scope.
It allows us to add custom properties to existing classes in categories.

@param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
@warning #import <objc/runtime.h>
*******************************************************************************
Example:
@interface NSObject (MyAdd)
@property (nonatomic, retain) UIColor *myColor;
@end

#import <objc/runtime.h>
@implementation NSObject (MyAdd)
KYSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
@end
*/
#ifndef KYSYNTH_DYNAMIC_PROPERTY_OBJECT
#define KYSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

/**
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 KYSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 */
#ifndef KYSYNTH_DYNAMIC_PROPERTY_CTYPE
#define KYSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}
#endif

#pragma mark - 其他

#define KYDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
//版本号
#define KY_AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define KYAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

KY_EXTERN_C_END
#endif /* KYBaseMacroHelper_h */
