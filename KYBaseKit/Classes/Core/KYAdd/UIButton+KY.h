//
//  UIButton+KY.h
//  Pods
//
//  Created by zr on 2019/9/19.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KYImagePosition) {
    KYImagePositionLeft     = 0,            //图片在左，文字在右，默认
    KYImagePositionRight    = 1,            //图片在右，文字在左
    KYImagePositionTop      = 2,            //图片在上，文字在下
    KYImagePositionBottom   = 3,            //图片在下，文字在上
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (KY)

@property (nonatomic, assign) CGFloat fontSize;

- (void)setBackground:(UIImage *)normalImage :(UIImage *)highlightImage;

+ (UIButton *)btnWithImage:(UIImage * _Nullable)image
                 withTitle:(NSString * _Nullable)title
                  fontSize:(CGFloat)fontSize
             setTitleColor:(UIColor * _Nullable)color
                  forState:(UIControlState)stateType;

+ (UIButton *)btnWithBackgroundImage:(UIImage * _Nullable)image
                           withTitle:(NSString * _Nullable)title
                            fontSize:(CGFloat )fontSize
                       setTitleColor:(UIColor * _Nullable)color
                            forState:(UIControlState)stateType;
/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)setImagePosition:(KYImagePosition)postion spacing:(CGFloat)spacing;

/**
 *  利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 *
 *  @param margin 图片、文字离button边框的距离
 */
- (void)setImagePosition:(KYImagePosition)postion WithMargin:(CGFloat )margin;


@end

NS_ASSUME_NONNULL_END
