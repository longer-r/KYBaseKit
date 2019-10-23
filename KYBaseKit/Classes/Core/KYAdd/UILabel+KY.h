//
//  UILabel+KY.h
//  Pods
//
//  Created by zr on 2019/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (KY)

+ (UILabel *)labelWithText:(NSString * _Nullable)text font:(int)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment;

+ (UILabel *)labelWithText:(NSString * _Nullable)text blodFont:(int)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment;

/**
 *  改变行间距
 */
- (void)changeLineSpaceWithSpace:(float)space;

/**
 *  改变字间距
 */
- (void)changeWordSpaceWithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

/**
 *  左右对齐,改变行间距
 */
-(void)changeAlignmentLeftAndRightWithSpace:(float)space;

@end

NS_ASSUME_NONNULL_END
