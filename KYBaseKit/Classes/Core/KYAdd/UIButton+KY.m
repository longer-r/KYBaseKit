//
//  UIButton+KY.m
//  Pods
//
//  Created by zr on 2019/9/19.
//

#import "UIButton+KY.h"

@implementation UIButton (KY)

- (CGFloat)fontSize
{
    return self.titleLabel.font.pointSize;
}

- (void)setFontSize:(CGFloat)fontSize
{
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setBackground:(UIImage *)normalImage :(UIImage *)highlightImage
{
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
}

+ (UIButton *)btnWithImage:(UIImage * _Nullable)image
    withTitle:(NSString * _Nullable)title
     fontSize:(CGFloat)fontSize
setTitleColor:(UIColor * _Nullable)color
     forState:(UIControlState)stateType;
{
    UIButton *button = [[UIButton alloc]init];
    [button setImage:image forState:stateType];
    !color ?: [button setTitleColor:color forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [button setTitle:NSLocalizedString(title,nil)  forState:stateType];
    
    return button;
}

+ (UIButton *)btnWithBackgroundImage:(UIImage * _Nullable)image
    withTitle:(NSString * _Nullable)title
     fontSize:(CGFloat )fontSize
setTitleColor:(UIColor * _Nullable)color
     forState:(UIControlState)stateType;
{
    UIButton *button = [[UIButton alloc]init];
    [button setBackgroundImage:image forState:stateType];
    !color ?: [button setTitleColor:color forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [button setTitle:NSLocalizedString(title,nil)  forState:stateType];
    
    return button;
    
}

- (void)setImagePosition:(KYImagePosition)postion spacing:(CGFloat)spacing {
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat labelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    CGFloat labelHeight = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    
    //image中心移动的x距离
    CGFloat imageOffsetX = labelWidth / 2 ;
    //image中心移动的y距离
    CGFloat imageOffsetY = labelHeight / 2 + spacing / 2;
    //label中心移动的x距离
    CGFloat labelOffsetX = imageWith/2;
    //label中心移动的y距离
    CGFloat labelOffsetY = imageHeight / 2 + spacing / 2;
    
    switch (postion) {
        case KYImagePositionLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
            
        case KYImagePositionRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, 0, -(labelWidth + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageHeight + spacing/2), 0, imageHeight + spacing/2);
            break;
            
        case KYImagePositionTop:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
            break;
            
        case KYImagePositionBottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX, labelOffsetY, labelOffsetX);
            break;
            
        default:
            break;
    }
    
}


/**根据图文距边框的距离调整图文间距*/
- (void)setImagePosition:(KYImagePosition)postion WithMargin:(CGFloat )margin{
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat labelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    CGFloat spacing = self.bounds.size.width - imageWith - labelWidth - 2*margin;
    
    [self setImagePosition:postion spacing:spacing];
}

@end
