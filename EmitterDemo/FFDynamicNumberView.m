//
//  FFDynamicNumberView.m
//  FFDynamicNumberView
//
//  Created by huangqun on 2019/9/7.
//  Copyright © 2019 hq. All rights reserved.
//

#import "FFDynamicNumberView.h"

/**
 计算单个数字的size
 
 @param font 字体
 @return size
 */
static CGSize singleNumerSize(UIFont *font) {
    CGRect rect = [@"0" boundingRectWithSize:CGSizeZero
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{ NSFontAttributeName: font }
                                     context:nil];
    return rect.size;
}

@interface FFDynamicNumberView ()

@property (nonatomic, strong) NSMutableArray<FFSingleNunberView *> *numberViews; /**< 数字视图列表 */

@end

@implementation FFDynamicNumberView

- (instancetype)init {
    if (self = [super init]) {
        // 设置默认值
        self.numberFont = [UIFont systemFontOfSize:15];
        self.numberColor = UIColor.blackColor;
        self.numberBackColor = UIColor.whiteColor;
        self.numberSpace = 5.0;
        self.currentNumber = 0;
    }
    return self;
}

- (NSMutableArray<FFSingleNunberView *> *)numberViews {
    if (_numberViews == nil) {
        _numberViews = @[].mutableCopy;
    }
    return _numberViews;
}

/**
 更新数字
 
 @param numbers 数值
 @param animation 动画类型
 @param duration 动画持续时长
 */
- (void)updateNumbers:(NSInteger)numbers
            animation:(AnimationType)animation
             duration:(NSTimeInterval)duration {
    NSAssert(numbers >= 0, @"组件不支持显示负数");
    if (numbers < 0) {
        return;
    }

    // 将原来多余的数字视图移除
    NSInteger count = 0;
    if (self.numberCount > 0) {
        count = [NSString stringWithFormat:[NSString stringWithFormat:@"%%.%ldlu", self.numberCount], numbers].length;
    } else {
        count = [NSString stringWithFormat:@"%lu", numbers].length;
    }
    if (self.numberViews.count > count) {
        for (int i = 0; i < self.numberViews.count - count; i++) {
            FFSingleNunberView *numberView = self.numberViews[i];
            [self.numberViews removeObjectAtIndex:i];
            [numberView removeFromSuperview];
            numberView = nil;
        }
    }

    // 创建视图，如果原来的视图有多余则移除
    NSInteger viewCount = count - self.numberViews.count;
    NSMutableArray *tempArray = self.numberViews.mutableCopy;
    for (int i = 0; i < viewCount; i++) {
        FFSingleNunberView *numberView = [FFSingleNunberView new];
        numberView.backgroundColor = self.numberBackColor;
        numberView.numberFont = self.numberFont;
        numberView.numberColor = self.numberColor;
        [self addSubview:numberView];
        if (self.numberViews.count) {
            [tempArray insertObject:numberView atIndex:0];
        } else {
            [tempArray addObject:numberView];
        }
    }
    self.numberViews = tempArray.mutableCopy;
    
    // 根据对齐方式计算第一位数的x坐标
    CGFloat firstX = 0.0;
    // 单个数组的size
    CGSize numberSize = singleNumerSize(self.numberFont);
    // 所有数字占的总宽
    CGFloat numbersWidht = count * numberSize.width + (count - 1) * self.numberSpace;
    switch (self.numberAlignment) {
        case NumberAlignmentRight: {
            firstX = self.frame.size.width - numbersWidht;
            break;
        }
        case NumberAlignmentCenter: {
            firstX = (self.frame.size.width - numbersWidht) / 2;
            break;
        }
        default:
            break;
    }
    
    // 设置动画类型
    AnimationType animationType = animation;
    if (animationType == AnimationTypeAutomatic) {
        animationType = numbers > self.currentNumber ? AnimationTypeScrollUp : AnimationTypeScrollDown;
    }
    
    // 创建或调整数字视图
    for (int i = 0; i < count; i++) {
        FFSingleNunberView *numberView = self.numberViews[i];

        // 根据对齐方式计算每个numberView的位置
        CGFloat x = firstX + i * (numberSize.width + self.numberSpace);
        numberView.frame = CGRectMake(x, (self.frame.size.height - numberSize.height) / 2, numberSize.width, numberSize.height);
        
        // 设置数字label的高度
        [numberView setDispalyNumber:[self subnumberWithNumer:numbers atIndex:i] startNumber:numberView.currentNumber animation:animationType];
    }
    
    // 动态更新label到指定的数字
    for (FFSingleNunberView *numberView in self.numberViews) {
        [numberView updateNumberWithAnimation:animationType duration:duration];
    }
    
    // 记录当前的数值
    self.currentNumber = numbers;
}

/**
 获取数值中指定位置的单个数字
 
 @param number 原数字
 @param index 指定的位置
 @return 单个数字
 */
- (NSInteger)subnumberWithNumer:(NSInteger)number atIndex:(NSInteger)index {
    NSString *numberStr = [NSString stringWithFormat:[NSString stringWithFormat:@"%%.%ldlu", self.numberCount], number];
    NSAssert(numberStr.length > index, @"截取数字索引越界");
    NSInteger num = 0;
    if (numberStr.length > index) {
        num = [[numberStr substringWithRange:NSMakeRange(index, 1)] integerValue];
    }
    return num;
}

@end

#pragma mark -
#pragma mark - 单个数字视图
@interface FFSingleNunberView ()

@property (nonatomic, strong) UILabel *numberLabel;  /**< 数字label */

@end

@implementation FFSingleNunberView

- (instancetype)init {
    if (self = [super init]) {
        // 设置默认值
        self.numberFont = [UIFont systemFontOfSize:15];
        self.numberColor = UIColor.blackColor;
        self.currentNumber = 0;
        self.clipsToBounds = YES;
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (UILabel *)numberLabel {
    if (_numberLabel == nil) {
        _numberLabel = [UILabel new];
        _numberLabel.textColor = self.numberColor;
        _numberLabel.font = self.numberFont;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        CGRect rect = self.frame;
        rect.origin = CGPointZero;
        _numberLabel.frame = rect;
        [self addSubview:_numberLabel];
    }
    return _numberLabel;
}

/**
 设置将要显示的数值
 计算label的高度
 最后通过改变label的高度来达到滚动的效果
 
 @param dispalyNumber 将要显示的数字
 @param startNumber 开始时的数字
 @param animation 数字切换的动画（只允许ScrollUp和ScrollDown动画）
 */
- (void)setDispalyNumber:(NSInteger)dispalyNumber
             startNumber:(NSInteger)startNumber
               animation:(AnimationType)animation {
    if (self.currentNumber == dispalyNumber) {
        // Integer的默认值是0，为了避免首次赋值是0时不显示，这里需要给label设置值
        [self updateLabelHeightWithText:[NSString stringWithFormat:@"%lu", dispalyNumber] animation:animation];
        return;
    }
    
    // 记录当前显示的数值
    self.currentNumber = dispalyNumber;
    
    // 只处理向上或向下的滚动动画计算
    if (animation != AnimationTypeScrollUp && animation != AnimationTypeScrollDown) {
        [self updateLabelHeightWithText:[NSString stringWithFormat:@"%lu", dispalyNumber] animation:animation];
        return;
    }

    /* label的值取决于两个因素
     * 1、滚动方向
     * 2、开始的数字与最终的数字的大小
     *
     * 列如：向上滚动(加法)
     * 从 6 -> 3，值为 6543
     * 从 3 -> 6，值为 3456
     *
     * 列如：向下滚动(减法)
     * 从 6 -> 3，值为 6543
     * 从 3 -> 6，值为 3456
     */
    NSMutableString *numberString;
    if (animation == AnimationTypeScrollUp) {
        numberString = [NSMutableString stringWithFormat:@"%lu", (unsigned long)startNumber];
        if (startNumber < dispalyNumber) {
            for (NSInteger i = startNumber + 1; i <= dispalyNumber; i++) {
                [numberString appendFormat:@"\n%ld", (long)i];
            }
        } else {
            for (NSInteger i = startNumber - 1; i >= dispalyNumber; i--) {
                [numberString appendFormat:@"\n%ld", (long)i];
            }
        }
    } else if (animation == AnimationTypeScrollDown) {
        numberString = [NSMutableString stringWithFormat:@"%lu", (unsigned long)dispalyNumber];
        if (startNumber > dispalyNumber) {
            for (NSInteger i = dispalyNumber + 1; i <= startNumber; i++) {
                [numberString appendFormat:@"\n%ld", (long)i];
            }
        } else {
            for (NSInteger i = dispalyNumber - 1; i >= startNumber; i--) {
                [numberString appendFormat:@"\n%ld", (long)i];
            }
        }
    }
    [self updateLabelHeightWithText:numberString animation:animation];
}

/**
 根据文本内容和即将持续的动画设置label的y和height

 @param numberString 数字文本
 @param animation 动画
 */
- (void)updateLabelHeightWithText:(NSString *)numberString animation:(AnimationType)animation {
    // 更新label的内容和size
    NSString *text = [numberString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSInteger numberCount = text.length;
    self.numberLabel.text = numberString;
    self.numberLabel.numberOfLines = numberCount;
    CGSize size = singleNumerSize(self.numberLabel.font);
    CGRect rect = self.numberLabel.frame;
    rect.size.height = size.height * numberCount;
    if (animation == AnimationTypeScrollDown) {
        rect.origin = CGPointMake(0, singleNumerSize(self.numberLabel.font).height - rect.size.height);
    } else {
        rect.origin = CGPointZero;
    }
    self.numberLabel.frame = rect;
}


/**
 更新数字,通过更新y坐标滚动到将要显示的数字(如果需要滚动动画)
 
 @param animation 动画类型
 @param duration 动画持续时长
 */
- (void)updateNumberWithAnimation:(AnimationType)animation
                         duration:(NSTimeInterval)duration {
    
    CGRect rect = self.numberLabel.frame;
    if (animation == AnimationTypeScrollDown) {
        rect.origin.y = 0;
    } else {
        rect.origin.y = singleNumerSize(self.numberLabel.font).height - rect.size.height;
    }
    
    if (animation == AnimationTypeNone) {
        self.numberLabel.frame = rect;
    } else {
        // 动态实现数字的滚动
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.numberLabel.frame = rect;
        } completion:nil];
    }
}

@end

