//
//  FFDynamicNumberView.h
//  FFDynamicNumberView
//
//  Created by huangqun on 2019/9/7.
//  Copyright © 2019 hq. All rights reserved.
//
//  动态数字(不支持负数)
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 数字变化时的动画类型

 - AnimationTypeNone: 默认动画(无滚动，快速变换数值)
 - AnimationTypeAutomatic: 自动, 如果新值比原值大则执行AnimationTypeScrollUp(加法)
 - AnimationTypeScrollUp: 向上滚动(加法)
 - AnimationTypeScrollDown: 向下滚动(减法)
 */
typedef NS_ENUM(NSUInteger, AnimationType) {
    AnimationTypeNone,
    AnimationTypeAutomatic,
    AnimationTypeScrollUp,
    AnimationTypeScrollDown,
};

/**
 数值列表相对父视图的对齐方式

 - NumberAlignmentCenter: 居中
 - NumberAlignmentLeft: 左对齐
 - NumberAlignmentRight: 右对齐
 */
typedef NS_ENUM(NSUInteger, NumberAlignment) {
    NumberAlignmentCenter,
    NumberAlignmentLeft,
    NumberAlignmentRight,
};

#pragma mark -
#pragma mark - 动态数字视图
@interface FFDynamicNumberView : UIView

@property (nonatomic, strong) UIFont *numberFont;              /**< 字体 */
@property (nonatomic, strong) UIColor *numberColor;            /**< 字体颜色 */
@property (nonatomic, strong) UIColor *numberBackColor;        /**< 字体背景颜色 */
@property (nonatomic, assign) NumberAlignment numberAlignment; /**< 对齐方式 */
@property (nonatomic, assign) CGFloat numberSpace;             /**< 字体之间的间距 */
@property (nonatomic, assign) NSInteger numberCount;           /**< 数字位数限定 */
@property (nonatomic, assign) NSInteger currentNumber;         /**< 当前的数值 */

/**
 更新数字
 
 @param numbers 数值
 @param animation 动画类型
 @param duration 动画持续时长
 */
- (void)updateNumbers:(NSInteger)numbers
            animation:(AnimationType)animation
             duration:(NSTimeInterval)duration;

@end

#pragma mark -
#pragma mark - 单个数字视图
@interface FFSingleNunberView : UIView

@property (nonatomic, strong) UIFont *numberFont;       /**< 字体 */
@property (nonatomic, strong) UIColor *numberColor;     /**< 字体颜色 */
@property (nonatomic, assign) NSInteger currentNumber; /**< 当前的数值 */

/**
 设置将要显示的数值
 计算label文案的高度来调整label的高度
 
 @param dispalyNumber 将要显示的数字
 @param startNumber 开始时的数字
 @param animation 数字切换的动画
 */
- (void)setDispalyNumber:(NSInteger)dispalyNumber
             startNumber:(NSInteger)startNumber
               animation:(AnimationType)animation;

/**
 更新数字,执行对应的动画

 @param animation 动画类型
 @param duration 动画持续时长
 */
- (void)updateNumberWithAnimation:(AnimationType)animation
                         duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
