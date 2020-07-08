//
//  UIButton+KLLayout.m
//  KLCategory
//
//  Created by Logic on 2019/11/25.
//

#import "UIButton+KLExtension.h"
#import <objc/runtime.h>

static NSString * const kbuttonContentLayoutTypeKey = @"axcUI_buttonContentLayoutTypeKey";
static NSString * const kpaddingKey = @"axcUI_paddingKey";
static NSString * const kpaddingInsetKey = @"axcUI_paddingInsetKey";

@implementation UIButton (KLExtension)

- (void)setupButtonLayout {
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat image_w = self.imageView.frame.size.width;
    CGFloat image_h = self.imageView.frame.size.height;
    
    CGFloat title_w = self.titleLabel.frame.size.width;
    CGFloat title_h = self.titleLabel.frame.size.height;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0){
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        title_w = self.titleLabel.intrinsicContentSize.width;
        title_h = self.titleLabel.intrinsicContentSize.height;
    }
    
    UIEdgeInsets imageEdge = UIEdgeInsetsZero;
    UIEdgeInsets titleEdge = UIEdgeInsetsZero;
    
    if (self.kl_paddingInset == 0){
        self.kl_paddingInset = 5;
    }
    
    switch (self.kl_layoutStyle) {
        case KLButtonContentLayoutStyleNormal:{
            titleEdge = UIEdgeInsetsMake(0, self.kl_padding, 0, 0);
            imageEdge = UIEdgeInsetsMake(0, 0, 0, self.kl_padding);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
            break;
        case KLButtonContentLayoutStyleCenterImageRight:{
            titleEdge = UIEdgeInsetsMake(0, -image_w - self.kl_padding, 0, image_w);
            imageEdge = UIEdgeInsetsMake(0, title_w + self.kl_padding, 0, -title_w);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
            break;
        case KLButtonContentLayoutStyleCenterImageTop:{
            titleEdge = UIEdgeInsetsMake(0, -image_w, -image_h - self.kl_padding, 0);
            imageEdge = UIEdgeInsetsMake(-title_h - self.kl_padding, 0, 0, -title_w);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
            break;
        case KLButtonContentLayoutStyleCenterImageBottom:{
            titleEdge = UIEdgeInsetsMake(-image_h - self.kl_padding, -image_w, 0, 0);
            imageEdge = UIEdgeInsetsMake(0, 0, -title_h - self.kl_padding, -title_w);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
            break;
        case KLButtonContentLayoutStyleLeftImageLeft:{
            titleEdge = UIEdgeInsetsMake(0, self.kl_padding + self.kl_paddingInset, 0, 0);
            imageEdge = UIEdgeInsetsMake(0, self.kl_paddingInset, 0, 0);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
            break;
        case KLButtonContentLayoutStyleLeftImageRight:{
            titleEdge = UIEdgeInsetsMake(0, -image_w + self.kl_paddingInset, 0, 0);
            imageEdge = UIEdgeInsetsMake(0, title_w + self.kl_padding + self.kl_paddingInset, 0, 0);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
            break;
        case KLButtonContentLayoutStyleRightImageLeft:{
            imageEdge = UIEdgeInsetsMake(0, 0, 0, self.kl_padding + self.kl_paddingInset);
            titleEdge = UIEdgeInsetsMake(0, 0, 0, self.kl_paddingInset);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
            break;
        case KLButtonContentLayoutStyleRightImageRight:{
            titleEdge = UIEdgeInsetsMake(0, -self.frame.size.width / 2, 0, image_w + self.kl_padding + self.kl_paddingInset);
            imageEdge = UIEdgeInsetsMake(0, 0, 0, -title_w + self.kl_paddingInset);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
            break;
        default:break;
    }
    self.imageEdgeInsets = imageEdge;
    self.titleEdgeInsets = titleEdge;
    [self setNeedsDisplay];
}


#pragma mark - SET
- (void)setKl_layoutStyle:(KLButtonContentLayoutStyle)kl_layoutStyle {
    [self willChangeValueForKey:kbuttonContentLayoutTypeKey];
    objc_setAssociatedObject(self, &kbuttonContentLayoutTypeKey,
                             @(kl_layoutStyle),
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:kbuttonContentLayoutTypeKey];
    [self setupButtonLayout];
}

- (KLButtonContentLayoutStyle)kl_layoutStyle {
    return [objc_getAssociatedObject(self, &kbuttonContentLayoutTypeKey) integerValue];
}

- (void)setKl_padding:(CGFloat)kl_padding {
    [self willChangeValueForKey:kpaddingKey];
    objc_setAssociatedObject(self, &kpaddingKey,
                             @(kl_padding),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:kpaddingKey];

    [self setupButtonLayout];
}

- (CGFloat)kl_padding {
    return [objc_getAssociatedObject(self, &kpaddingKey) floatValue];
}

- (void)setKl_paddingInset:(CGFloat)kl_paddingInset {
    [self willChangeValueForKey:kpaddingInsetKey];
    objc_setAssociatedObject(self, &kpaddingInsetKey,
                             @(kl_paddingInset),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:kpaddingInsetKey];
    [self setupButtonLayout];
}

- (CGFloat)kl_paddingInset {
    return [objc_getAssociatedObject(self, &kpaddingInsetKey) floatValue];
}

- (void)kl_controlEvents:(UIControlEvents)events completion:(void (^)(UIButton *sender))completion {
    objc_setAssociatedObject(self, @selector(kl_controlEvents:completion:), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:events];
}

- (void)touchUpInside:(UIButton *)sender {
    void (^block)(UIButton *sender) = objc_getAssociatedObject(self, @selector(kl_controlEvents:completion:));
    if (block) block(sender);
}

@end
