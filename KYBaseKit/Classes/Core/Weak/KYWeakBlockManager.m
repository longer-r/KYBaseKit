//
//  KYWeakBlockManager.m
//
//  Created by zr on 2019/8/28.
//

#import "KYWeakBlockManager.h"
#import "KYBaseMacro.h"


@interface KYWeakBlockObject : NSObject

@property (nonatomic, weak) id weakTarget;
@property (nonatomic, copy) id block;

- (instancetype)initWithTarget:(id)target block:(id)block;

@end

@implementation KYWeakBlockObject

- (void)dealloc {
    
}

- (instancetype)initWithTarget:(id)target block:(id)block {
    
    self = [super init];
    if (self) {
        _weakTarget = target;
        _block = block;
    }
    return self;
}

@end



@interface KYWeakBlockManager ()

@property(nonatomic, strong) NSMutableArray *weakObjectArray;

@end

@implementation KYWeakBlockManager

- (instancetype)init {
    
    if (self=[super init]) {
        self.weakObjectArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)registerTarget:(id)target block:(id)block {
    
    dispatch_main_async_safe(^{
        if ([self isExistWeakObjectAtTarget:target] == NO) {
            
            KYWeakBlockObject *temp = [[KYWeakBlockObject alloc] initWithTarget:target block:block];
            [self.weakObjectArray addObject:temp];
        }
    });
}

- (void)unRegisterTarget:(id)target {
    
    dispatch_main_async_safe(^{
        //remove all nilDelegates
        NSArray *array = [self allNilDelegate];
        [self.weakObjectArray removeObjectsInArray:array];
        
        KYWeakBlockObject *object = [self weakObjectAtTarget:target];
        if (object) {
            [self.weakObjectArray removeObject:object];
        }
    });
}

- (void)removeAll {
    
    dispatch_main_async_safe(^{
        [self.weakObjectArray removeAllObjects];
    });
}

- (void)excuteAllBlocks:(void(^)(id tempBlock))block {
    
    dispatch_main_async_safe(^{
        for (KYWeakBlockObject *object in self.weakObjectArray) {
            if (object.weakTarget && object.block) {
                
                if (block) {
                    block(object.block);
                }
            }
        }
    });
}

- (BOOL)isExistWeakObjectAtTarget:(id)target {
    
    KYWeakBlockObject *object = [self weakObjectAtTarget:target];
    if (object) {
        return YES;
    }else {
        return NO;
    }
}

- (KYWeakBlockObject *)weakObjectAtTarget:(id)target {
    
    KYWeakBlockObject *object = nil;
    for (KYWeakBlockObject *temp in self.weakObjectArray) {
        
        if (temp.weakTarget && temp.weakTarget==target) {
            
            object = temp;
            break;
        }
    }
    
    return object;
}

- (NSArray *)allNilDelegate {
    
    NSMutableArray *array = [NSMutableArray array];
    for (KYWeakBlockObject *temp in self.weakObjectArray) {
        
        if (temp.weakTarget == nil) {
            [array addObject:temp];
        }
    }
    
    return array;
}


@end
