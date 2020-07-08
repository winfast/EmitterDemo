//
//  NSObject+KLExtension.h
//  KLCategory
//
//  Created by Logic on 2019/11/30.
//

#import <Foundation/Foundation.h>

#ifndef weakify
# define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#endif

#ifndef strongify
# define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Foundation)

// MARK: - Foundation
/// 获取首次启动标识
extern BOOL KLFirstLaunch(void);
/// 设置首次启动标识
extern void KLSetFirstLaunch(void);
/// 自动设置并获取启动标识
extern BOOL KLFirstAutoLaunch(void);
/// 是否是iPhoneX系列刘海屏
extern BOOL KLIsphoneXabove(void);
/// 是否是苹果手机
extern BOOL KLIsphone(void);

/// 屏幕宽度
extern CGFloat KLScreenWidth(void);
/// 屏幕高度
extern CGFloat KLScreenHeight(void);
/// 等比例缩放计算, 以375pt为基准值
/// @param origin 以375pt为基准的参考值
extern CGFloat KLAuto(CGFloat origin);
/// 状态栏高度
extern CGFloat KLAutoStatus(void);
/// 导航栏高度
extern CGFloat KLAutoTop(void);
/// 选项栏高度
extern CGFloat KLAutoBottom(void);
/// iPhoneX底部安全高度
extern CGFloat KLAutoBottomInset(void);

// MARK: - Math
/// 角度转弧度
/// @param degrees 角度
extern CGFloat KLDegreesToRadian(CGFloat degrees);
/// 弧度转角度
/// @param radian 弧度
extern CGFloat KLRadianToDegrees(CGFloat radian);

/// 计算数组和
extern CGFloat KLSumOfArray(NSArray *numbers);
/// 计算数组平均值
extern CGFloat KLAverageOfArray(NSArray *numbers);
/// 获取数组最大值
extern CGFloat KLMaxNumberOfArray(NSArray *numbers);
/// 获取数组最小值
extern CGFloat KLMinNumberOfArray(NSArray *numbers);

@end

NS_ASSUME_NONNULL_END
