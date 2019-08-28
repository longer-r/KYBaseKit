//
//  NSObject+KYLayout.m
//  KYBaseKit
//
//  Created by zr on 2019/8/27.
//

#import "NSObject+KYLayout.h"
#import "KYBaseMacro.h"

YKSYNTH_DUMMY_CLASS(NSObject_KYLayout)
@implementation NSObject (KYLayout)

//设计稿布局基准
+(CGSize)inner_baseSize {
    
    CGSize baseSize;
    if (KY_IPAD) {
        baseSize = self.ky_isBaseVertical ? CGSizeMake(1024, 768) : CGSizeMake(768, 1024);
    }else {
        baseSize = self.ky_isBaseVertical ? CGSizeMake(667, 375) : CGSizeMake(375, 667);
    }
    
    return baseSize;
}

//是否按垂直方向作为布局基准
- (BOOL)ky_isBaseVertical {
    
    if (KY_IPAD) {
        return NO;
    }else {
        return NO;
    }
}

+ (CGFloat)inner_currentScale {
    
    float baseWidth = self.inner_baseSize.width;
    return KY_SCREEN_WIDTH / baseWidth;
}


+ (CGFloat)ky_getWidth:(CGFloat)originWidth {
    
    return originWidth * self.inner_currentScale;
}

@end
