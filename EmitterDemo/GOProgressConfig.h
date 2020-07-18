//
//  GOProgressConfig.h
//  EmitterDemo
//
//  Created by QinChuancheng on 2020/7/3.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GOProgressType) {
	GOProgressTypeAnticlockwise,  //逆时针
	GOProgressTypeClockwise,	  //顺时针
	GOProgressTypeRotate		  //旋转
};



@interface GOProgressConfig : NSObject

@property (nonatomic) GOProgressType progressType;

//外面的线宽和颜色 默认线宽11, 默认颜色 0xFF1832  //默认11
@property (nonatomic) CGFloat progressLineWidth;

//背景的线宽和颜色
@property (nonatomic) CGFloat backgroundProgressLineWitdh;  //默认11
@property (nonatomic, strong) UIColor *backgroundProgressLineColor;  //需要单独设置,目前不需要变颜色

/// 是否显示指针, 默认不显示
@property (nonatomic, setter=setShowNeedle:) BOOL isShowNeedle;

/// 是否显示指针, 默认不修改颜色
@property (nonatomic, setter=setUpdateColor:) BOOL isUpdateColor;

@property (nonatomic, setter=setRotate:) BOOL isRotate;

/// 工作圆环半径  无效, 现在使用图片
@property (nonatomic) CGFloat progressCircleRadius;  //默认 宽*0.5

/// 指针半径,默认比工作圆环半径大一点,
@property (nonatomic) CGFloat needleCircleRadius;  //默认 宽*0.5 - 10

/// 中间的字体
@property (nonatomic, strong) UIFont *numberFont;

/// 内阴影
@property (nonatomic) CGFloat innerShadowRadius;

/// 内阴影
@property (nonatomic) CGFloat outerShadowRadius;

//支持选择才有效
@property (nonatomic, copy) NSArray<UIColor *> *gradientLayerColors;


//如果支持颜色变化,保证颜色个数一样,  如果不支持, 颜色获取第一个颜色
/* The array of UIColor objects defining the color of each gradient
 * stop. Defaults to nil. Animatable. */

@property (nonatomic, copy) NSArray<UIColor *> *innerColors;   //内发光
@property (nonatomic, copy) NSArray<UIColor *> *outerColors;	//外发光 (进度条外发光)
@property (nonatomic, copy) NSArray<UIColor *> *emitterColors;	//粒子颜色
@property (nonatomic, copy) NSArray<UIColor *> *progressColors; //进度条颜色
@property (nonatomic, copy) NSArray<UIColor *> *needleColors;	//指针 (光标)颜色


/* An optional array of NSNumber objects defining the location of each
 * gradient stop as a value in the range [0,1]. The values must be
 * monotonically increasing. If a nil array is given, the stops are
 * assumed to spread uniformly across the [0,1] range. When rendered,
 * the colors are mapped to the output colorspace before being
 * interpolated. Defaults to nil. Animatable. */

@property(nullable, copy) NSArray<NSNumber *> *locations;



@end

