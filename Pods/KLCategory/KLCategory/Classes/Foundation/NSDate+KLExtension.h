//
//  NSDate+KLExtension.h
//  KLCategory
//
//  Created by Logic on 2019/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (KLExtension)

/// 年
- (NSUInteger)kl_year;
/// 月
- (NSUInteger)kl_month;
/// 周
- (NSUInteger)kl_week;
/// 一月中的第几周
- (NSUInteger)kl_weekInMonth;
/// 一年中的第几周
- (NSUInteger)kl_weekInYear;
/// 日
- (NSUInteger)kl_day;
/// 时
- (NSUInteger)kl_hour;
/// 分
- (NSUInteger)kl_minute;
/// 秒
- (NSUInteger)kl_second;

/// 计算日期对应的年份
+ (NSUInteger)kl_year:(NSDate *)date;
/// 计算日期对应的月份
+ (NSUInteger)kl_month:(NSDate *)date;
/// 计算日期对应的日期
+ (NSUInteger)kl_day:(NSDate *)date;
/// 计算日期对应的小时
+ (NSUInteger)kl_hour:(NSDate *)date;
/// 计算日期对应的分钟
+ (NSUInteger)kl_minute:(NSDate *)date;
/// 计算日期对应的秒数
+ (NSUInteger)kl_second:(NSDate *)date;

/// 是否是今天
- (BOOL)kl_isToday;

/// 时间戳转时分秒，用于倒计时场景
+ (NSInteger)kl_dayWithTimestamp:(NSInteger)timestamp;
+ (NSInteger)kl_hourWithTimestamp:(NSInteger)timestamp;
+ (NSInteger)kl_minuteWithTimestamp:(NSInteger)timestamp;
+ (NSInteger)kl_secondWithTimestamp:(NSInteger)timestamp;

@end

NS_ASSUME_NONNULL_END
