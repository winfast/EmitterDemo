//
//  UILabel+KLExtension.m
//  KLCategory
//
//  Created by Logic on 2019/12/18.
//

#import "UILabel+KLExtension.h"
#import <CoreText/CoreText.h>

@implementation UILabel (KLExtension)

- (void)kl_setWordSpace:(CGFloat)wordSpace
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    // 调整字间距
    [attributedString addAttribute:NSKernAttributeName value:@(wordSpace) range:NSMakeRange(0, [attributedString length])];
    self.attributedText = attributedString;
}

- (void)kl_setLineSpace:(CGFloat)lineSpace
{
    self.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    // 调整行距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    self.attributedText = attributedString;
}

@end
