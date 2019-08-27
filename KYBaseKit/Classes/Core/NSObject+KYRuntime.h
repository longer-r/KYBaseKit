//
//  NSObject+KYRuntime.h
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KYRuntime)

#pragma mark - Swap method (Swizzling)
///=============================================================================
/// @name Swap method (Swizzling)
///=============================================================================

/**
 替换self的实例方法实现，将 `originalSel` 的实现替换成 `targetSel` 的实现。
 
 @param originalSel        原方法
 @param targetSel        目标方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleInstanceMethod:(SEL)originalSel targetSel:(SEL)targetSel;

/**
 将self的实例方法 `originalSel` 的实现，替换成 `targetClass` 的实例方法 `targetSel` 的实现。
 
 @param originalSel        原方法
 @param targetClass        目标类
 @param targetSel        目标方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleInstanceMethod:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel;

/**
 替换两个类的实例方法实现，将 `originalClass` 的实例方法 `originalSel` 的实现，替换成 `targetClass` 的实例方法 `targetSel` 的实现。
 
 @param originalClass   原类
 @param originalSel        原方法
 @param targetClass        目标类
 @param targetSel        目标方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleInstanceMethod:(Class)originalClass originalSel:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel;

/**
 替换self class的类方法实现，将 `originalSel` 替换成 `targetSel` 的实现。
 
 @param originalSel        原类方法
 @param targetSel        目标类方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleClassMethod:(SEL)originalSel targetSel:(SEL)targetSel;

/**
 将self class的 `originalSel` 类方法实现，替换成 `targetClass` 的类方法 `targetSel` 的实现。
 
 @param originalSel        原类方法
 @param targetClass        目标类
 @param targetSel        目标类方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleClassMethod:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel;

/**
 替换两个类的类方法实现，将 `originalClass` 的类方法 `OriginalSel`的实现，替换成 `targetClass` 的类方法 `targetSel`的实现。
 
 @param originalClass   原类
 @param originalSel        原类方法
 @param targetClass        目标类
 @param targetSel        目标类方法
 @return                如果替换成功返回 YES；否则，NO。
 */
+ (BOOL)bbp_swizzleClassMethod:(Class)originalClass originalSel:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel;


#pragma mark - 关联值（Associate value）
///=============================================================================
/// @name 关联值（Associate value）
///=============================================================================

/**
 关联一个强引用对象属性到 `self` 实例，相当于声明属性 property (strong, nonatomic) 。
 
 @param value   强引用对象。
 @param key     引用的指针，通过指针可以从 `self` 获取引用对象。
 */
- (void)bbp_setAssociateValue:(nullable id)value withKey:(void *)key;

/**
 关联一个弱引用对象到 `self` 实例，相当于声明属性 property (week, nonatomic) 。
 
 @param value  引用对象。
 @param key    引用的指针，通过指针可以从 `self` 获取引用对象。
 */
- (void)bbp_setAssociateWeakValue:(nullable id)value withKey:(void *)key;

/**
 从 `self` 实例中获取关联的值对象。
 
 @param key 引用指针。
 */
- (nullable id)bbp_getAssociatedValueForKey:(void *)key;

/**
 从 `self` 实例移除关联的值对象。
 */
- (void)bbp_removeAssociatedValues;

@end

NS_ASSUME_NONNULL_END
