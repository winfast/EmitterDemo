//
//  NSDate+KLExtension.m
//  KLCategory
//
//  Created by Logic on 2019/12/16.
//

#import "NSDate+KLExtension.h"

@implementation NSDate (KLExtension)

- (NSUInteger)kl_day
{ return [NSDate kl_day:self]; }

- (NSUInteger)kl_month
{ return [NSDate kl_month:self]; }

- (NSUInteger)kl_week
{ return [NSDate kl_week:self]; }

- (NSUInteger)kl_weekInMonth
{ return [NSDate kl_weekInMonth:self]; }

- (NSUInteger)kl_weekInYear
{ return [NSDate kl_weekInYear:self]; }

- (NSUInteger)kl_year
{ return [NSDate kl_year:self]; }

- (NSUInteger)kl_hour
{ return [NSDate kl_hour:self]; }

- (NSUInteger)kl_minute
{ return [NSDate kl_minute:self]; }

- (NSUInteger)kl_second
{ return [NSDate kl_second:self]; }

+ (NSUInteger)kl_year:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitYear date:date].year; }

+ (NSUInteger)kl_month:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitMonth date:date].month; }

+ (NSUInteger)kl_week:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitWeekday date:date].weekday; }

+ (NSUInteger)kl_weekInMonth:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitWeekOfMonth date:date].weekOfMonth; }

+ (NSUInteger)kl_weekInYear:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitWeekOfYear date:date].weekOfYear; }

+ (NSUInteger)kl_day:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitDay date:date].day; }

+ (NSUInteger)kl_hour:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitHour date:date].hour; }

+ (NSUInteger)kl_minute:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitMinute date:date].minute; }

+ (NSUInteger)kl_second:(NSDate *)date
{ return [self kl_componentsWithUnit:NSCalendarUnitSecond date:date].second; }

+ (NSDateComponents *)kl_componentsWithUnit:(NSCalendarUnit)unit date:(NSDate *)date
{ return [NSCalendar.currentCalendar components:unit fromDate:date]; }

- (BOOL)kl_isToday
{ return [self kl_isSameDay:NSDate.date]; }

- (BOOL)kl_isSameDay:(NSDate *)anotherDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:self];
    NSDateComponents *components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:anotherDate];
    return (components1.year == components2.year
            &&
            components1.month == components2.month
            &&
            components1.day == components2.day);
}

+ (NSInteger)kl_dayWithTimestamp:(NSInteger)timestamp
{ return timestamp / 3600 / 24; }

+ (NSInteger)kl_hourWithTimestamp:(NSInteger)timestamp
{ return timestamp / 3600 % 24; }

+ (NSInteger)kl_minuteWithTimestamp:(NSInteger)timestamp
{ return timestamp % 3600 / 60; }

+ (NSInteger)kl_secondWithTimestamp:(NSInteger)timestamp
{ return timestamp % 3600 % 60; }

@end
