//
//  NSDictionary+Safe.m
//  BBSFoundation
//
//  Created by zr on 2019/8/30.
//

#import "NSDictionary+Safe.h"
#import "NSObject+Swizzling.h"
#import "KYBaseMacro.h"

KYSYNTH_DUMMY_CLASS(NSDictionary_Safe)

@implementation NSDictionary (Safe)

+ (void)load {
    //只执行一次这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 替换 dictionaryWithObjects:forKeys:count:
        NSString *tmpDictionaryStr = @"dictionaryWithObjects:forKeys:count:";
        NSString *tmpSafeDictionaryStr = @"dictionaryWithObjects_safe:forKeys:count:";
        
        [NSObject exchangeClassMethodWithSelfClass:[self class]
                                      originalSelector:NSSelectorFromString(tmpDictionaryStr)                                     swizzledSelector:NSSelectorFromString(tmpSafeDictionaryStr)];
        // 替换 initWithObjects:forKeys:count:
        NSString *tmpInitStr = @"initWithObjects:forKeys:count:";
        NSString *tmpSafeInitStr = @"initWithObjects_safe:forKeys:count:";
        
        [NSObject exchangeInstanceMethodWithSelfClass:[self class]
                                     originalSelector:NSSelectorFromString(tmpInitStr)                                     swizzledSelector:NSSelectorFromString(tmpSafeInitStr)];
        
        
    });
}

+ (instancetype)dictionaryWithObjects_safe:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    id instance = nil;
    
    @try {
        instance = [self dictionaryWithObjects_safe:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self dictionaryWithObjects_safe:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

- (instancetype)initWithObjects_safe:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    id instance = nil;
    
    @try {
        instance = [self initWithObjects_safe:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self initWithObjects_safe:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

@end
