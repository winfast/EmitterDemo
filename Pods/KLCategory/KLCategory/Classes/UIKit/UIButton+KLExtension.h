//
//  UIButton+KLLayout.h
//  KLCategory
//
//  Created by Logic on 2019/11/25.
//

/**
 Button 的样式，以图片为基准
 */
typedef NS_ENUM(NSInteger, KLButtonContentLayoutStyle) {
    KLButtonContentLayoutStyleNormal = 0,       // 内容居中-图左文右
    KLButtonContentLayoutStyleCenterImageRight, // 内容居中-图右文左
    KLButtonContentLayoutStyleCenterImageTop,   // 内容居中-图上文下
    KLButtonContentLayoutStyleCenterImageBottom,// 内容居中-图下文上
    KLButtonContentLayoutStyleLeftImageLeft,    // 内容居左-图左文右
    KLButtonContentLayoutStyleLeftImageRight,   // 内容居左-图右文左
    KLButtonContentLayoutStyleRightImageLeft,   // 内容居右-图左文右
    KLButtonContentLayoutStyleRightImageRight,  // 内容居右-图右文左
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (KLExtension)

/// 图文间距，默认为：0
@property (nonatomic, assign) CGFloat kl_padding;

/// 图文边界的间距，默认为：5
@property (nonatomic, assign) CGFloat kl_paddingInset;

/// button 的布局样式
@property(nonatomic, assign) KLButtonContentLayoutStyle kl_layoutStyle;

/// 添加快捷事件
- (void)kl_controlEvents:(UIControlEvents)events completion:(void (^)(UIButton *sender))completion;

@end

NS_ASSUME_NONNULL_END

