//
//  NSObject+KYLayout.h
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KYLayout)

//是否按垂直方向作为布局基准（横屏）, default is NO for iPad,  is NO for iPhone
- (BOOL)ky_isBaseVertical;

+ (CGFloat)ky_getWidth:(CGFloat)originWidth;

@end

NS_ASSUME_NONNULL_END
