//
//  UILabel+KLExtension.h
//  KLCategory
//
//  Created by Logic on 2019/12/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (KLExtension)

/// 字间距
- (void)kl_setWordSpace:(CGFloat)wordSpace;

/// 行间距
- (void)kl_setLineSpace:(CGFloat)lineSpace;

@end

NS_ASSUME_NONNULL_END
