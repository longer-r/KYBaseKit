//
//  UILabel+KY.m
//  Pods
//
//  Created by zr on 2019/10/10.
//

#import "UILabel+KY.h"

@implementation UILabel (KY)

+ (UILabel *)labelWithText:(NSString * _Nullable)text font:(int)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment;
{
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(text,nil);
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    return label;
}

+ (UILabel *)labelWithText:(NSString * _Nullable)text blodFont:(int)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment) textAlignment;
{
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(text,nil);
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    return label;
}

- (void)changeLineSpaceWithSpace:(float)space {
    
    NSString *labelText = self.text;
    if(!labelText)return;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

- (void)changeWordSpaceWithSpace:(float)space {
    
    NSString *labelText = self.text;
    if(!labelText)return;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace {
    
    NSString *labelText = self.text;
    if(!labelText)return;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

-(void)changeAlignmentLeftAndRightWithSpace:(float)space
{
    NSString *labelText = self.text;
    if(!labelText)return;
    NSMutableAttributedString *mAbStr = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.paragraphSpacing = 11.0;
    paragraphStyle.paragraphSpacingBefore = 10.0;
    paragraphStyle.firstLineHeadIndent = 0.0;
    paragraphStyle.headIndent = 0.0;
    [paragraphStyle setLineSpacing:3];
    [mAbStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    NSAttributedString *attrString = [mAbStr copy];
    self.attributedText = attrString;
}

@end
