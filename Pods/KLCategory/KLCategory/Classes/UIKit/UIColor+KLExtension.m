//
//  UIColor+KLExtension.m
//  KLCategory
//
//  Created by Logic on 2019/11/25.
//

#import "UIColor+KLExtension.h"

@implementation UIColor (KLExtension)

+ (UIColor *)kl_colorWithHexString:(NSString *)hexString {
    return [self kl_colorWithHexString:hexString alpha:1];
}

+ (UIColor *)kl_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    unsigned int value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:[hexString hasPrefix:@"0x"] ? 2 : [hexString hasPrefix:@"#"] ? 1 : 0];
    [scanner scanHexInt:&value];
    return [[self kl_colorWithHexNumber:value] colorWithAlphaComponent:alpha];
}

+ (UIColor *)kl_colorWithHexNumber:(unsigned int)hexNumber {
    return [self kl_colorWithHexNumber:hexNumber alpha:1];
}

+ (UIColor *)kl_colorWithHexNumber:(unsigned int)hexNumber alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(((float)((hexNumber & 0xFF0000) >> 16)) / 255.0)
                           green:(((float)((hexNumber & 0xFF00) >> 8)) / 255.0)
                            blue:(((float)(hexNumber & 0xFF)) / 255.0)
                           alpha:alpha];
}

+ (UIColor *)kl_randomColor {
    return [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1];
}

@end
