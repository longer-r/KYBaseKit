//
//  NSObject+KYRuntime.m
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import "NSObject+KYRuntime.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation NSObject (KYRuntime)

+ (BOOL)bbp_swizzleInstanceMethod:(SEL)originalSel targetSel:(SEL)targetSel {
    
    return [self bbp_swizzleInstanceMethod:[self class] originalSel:originalSel targetClass:[self class] targetSel:targetSel];
}

+ (BOOL)bbp_swizzleInstanceMethod:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel {
    if (!originalSel || !targetClass || !targetSel) {
        return NO;
    }
    return [self bbp_swizzleInstanceMethod:[self class] originalSel:originalSel targetClass:targetClass targetSel:targetSel];
}

+ (BOOL)bbp_swizzleInstanceMethod:(Class)originalClass originalSel:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel {
    if (!originalClass || !originalSel || !targetClass || !targetSel) {
        return NO;
    }
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method newMethod = class_getInstanceMethod(targetClass, targetSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(originalClass,
                    originalSel,
                    class_getMethodImplementation(originalClass, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(targetClass,
                    targetSel,
                    class_getMethodImplementation(targetClass, targetSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(originalClass, originalSel),
                                   class_getInstanceMethod(targetClass, targetSel));
    
    return YES;
}

+ (BOOL)bbp_swizzleClassMethod:(SEL)originalSel targetSel:(SEL)targetSel {
    
    return [self bbp_swizzleClassMethod:object_getClass(self) originalSel:originalSel targetClass:object_getClass(self) targetSel:targetSel];
}

+ (BOOL)bbp_swizzleClassMethod:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel {
    
    return [self bbp_swizzleClassMethod:object_getClass(self) originalSel:originalSel targetClass:targetClass targetSel:targetSel];
}

+ (BOOL)bbp_swizzleClassMethod:(Class)originalClass originalSel:(SEL)originalSel targetClass:(Class)targetClass targetSel:(SEL)targetSel {
    if (!originalClass || !originalSel || !targetClass || !targetSel) {
        return NO;
    }
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method newMethod = class_getInstanceMethod(targetClass, targetSel);
    if (!originalMethod || !newMethod) return NO;
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

- (void)bbp_setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bbp_setAssociateWeakValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)bbp_removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

- (id)bbp_getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}


@end
