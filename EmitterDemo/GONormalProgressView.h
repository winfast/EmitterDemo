//
//  GONormalProgressView.h
//  EmitterDemo
//
//  Created by QinChuancheng on 2020/7/4.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOProgressConfig.h"
#import "GOInnerShadowLayer.h"

@import KLCategory;
//不显示指针和粒子效果

NS_ASSUME_NONNULL_BEGIN

@interface GONormalProgressView : UIView

@property (nonatomic, strong) CALayer *borderLayer;

/// 内阴影的颜色通过backgroundColor来修改颜色
@property (nonatomic, strong) CALayer *innerShadowLayer;
@property (nonatomic, strong) CALayer *circleLayer;

//这个Layer本身没有动画, 需要自己实现旋转
@property (nonatomic, strong) CALayer *rotateLayer;

///  必须给width和height, 因为里面使用layer,需要知道这两个数据
/// @param frame CGRect(0,0,width, height)
/// @param config 属性
- (instancetype)initWithFrame:(CGRect)frame config:(GOProgressConfig *)config;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
