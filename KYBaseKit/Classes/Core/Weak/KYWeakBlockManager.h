//
//  KYWeakBlockManager.h
//
//  Created by zr on 2019/8/28.
//


#import <Foundation/Foundation.h>

@interface KYWeakBlockManager: NSObject

- (void)registerTarget:(id)target block:(id)block;
- (void)unRegisterTarget:(id)target;

- (void)removeAll;

/*
 * 执行所有已注册block
 */
- (void)excuteAllBlocks:(void(^)(id tempBlock))block;

@end

