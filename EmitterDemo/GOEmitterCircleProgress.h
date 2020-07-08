//
//  EmitterCircleProgress.h
//  EmitterDemo
//
//  Created by Logic on 2020/5/23.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJShadowLayer.h"
#import "FFDynamicNumberView.h"
#import "GOProgressConfig.h"
#import "GOInnerShadowLayer.h"

@import KLCategory;


@interface GOLayer : CALayer

- (instancetype)initWithFrame:(CGRect)frame;

@end


@interface GOEmitterCircleProgress : UIView

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@property (nonatomic, strong) CALayer *emitterColorLayer;  //控制粒子颜色
@property (nonatomic, strong) CALayer *borderLayer;  // 外层layer
//@property (nonatomic, strong) GOInnerShadowLayer *innerShadowLayer;
@property (nonatomic, strong) CALayer *innerShadowLayer;  //内阴影的颜色通过backgroundColor来修改颜色

@property (nonatomic, strong) KJShadowLayer *outerShadowLayer;
@property (nonatomic, strong) FFDynamicNumberView *numberView;
@property (nonatomic, strong) CALayer *circleLayer;   //背景轨道layer

//指针Layer或者旋转的layer, 但是旋转layer本身没有动画, 需要外部设置动画
@property (nonatomic, strong) CALayer *lineLayer;


///  必须给width和height, 因为里面使用layer,需要知道这两个数据
/// @param frame CGRect(0,0,width, height)
/// @param config 属性
- (instancetype)initWithFrame:(CGRect)frame config:(GOProgressConfig *)config;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration;


@end

