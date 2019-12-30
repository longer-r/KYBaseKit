//
//  NSDate+KY.m
//  KYBaseKit
//
//  Created by zr on 2019/8/30.
//

#import "NSDate+KY.h"
#import "KYBaseMacro.h"

KYSYNTH_DUMMY_CLASS(NSDate_KY)

@implementation NSDate (KY)

#pragma mark - 日期修改（Date modify）

- (NSInteger)ky_year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)ky_month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)ky_day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)ky_hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)ky_minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)ky_second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)ky_nanosecond {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] nanosecond];
}

- (NSInteger)ky_weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)ky_weekdayOrdinal {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekdayOrdinal fromDate:self] weekdayOrdinal];
}

- (NSInteger)ky_weekOfMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:self] weekOfMonth];
}

- (NSInteger)ky_weekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:self] weekOfYear];
}

- (NSInteger)ky_yearForWeekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYearForWeekOfYear fromDate:self] yearForWeekOfYear];
}

- (NSInteger)ky_quarter {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] quarter];
}

- (BOOL)ky_isLeapMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] isLeapMonth];
}

- (BOOL)ky_isLeapYear {
    NSUInteger year = self.ky_year;
    return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)));
}

- (BOOL)ky_isToday {
    if (fabs(self.timeIntervalSinceNow) >= 60 * 60 * 24) return NO;
    return [NSDate new].ky_day == self.ky_day;
}

- (BOOL)ky_isYesterday {
    NSDate *added = [self ky_dateByAddingDays:1];
    return [added ky_isToday];
}

- (NSDate *)ky_dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)ky_dateByAddingMonths:(NSInteger)monthsToAdd {
    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth:monthsToAdd];
    return [[NSCalendar currentCalendar] dateByAddingComponents:months toDate:self options:0];
}

- (NSDate *)ky_startOfMonth {
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate: self];
    NSDate * startOfMonth = [[NSCalendar currentCalendar] dateFromComponents: currentDateComponents];
    return startOfMonth;
}

- (NSDate *)ky_endOfMonth {
    NSDate * plusOneMonthDate = [self ky_dateByAddingMonths:1];
    NSDateComponents *plusOneMonthDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate: plusOneMonthDate];
    // One second before the start of next month
    NSDate * endOfMonth = [[[NSCalendar currentCalendar] dateFromComponents:plusOneMonthDateComponents] dateByAddingTimeInterval: -1];
    return endOfMonth;
}


#pragma mark - Date Format

+ (NSDateFormatter *)formatterWithCurrentLocale {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return formatter;
}

+ (NSDateFormatter *)formatterWithTimeZoneSeconds {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    return formatter;
}

- (NSString *)ky_stringWithFormat:(NSString *)format {
    [[NSDate formatterWithCurrentLocale] setDateFormat:format];
    return [[NSDate formatterWithCurrentLocale] stringFromDate:self];
}

- (NSString *)ky_stringWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

- (NSString *)ky_stringWithISOFormat {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter stringFromDate:self];
}

+ (NSDate *)ky_dateWithString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)ky_dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)ky_dateWithString:(NSString *)dateString format:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) [formatter setTimeZone:timeZone];
    if (locale) [formatter setLocale:locale];
    return [formatter dateFromString:dateString];
}

+ (NSDate *)ky_dateWithISOFormatString:(NSString *)dateString {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [formatter dateFromString:dateString];
}

+ (nullable NSString *)ky_timestampWithDate:(NSDate *)date format:(nullable NSString *)format;
{
    return [NSDate ky_timestampWithString:[date ky_stringWithFormat:format] format:format];
}

+ (nullable NSString *)ky_timestampWithString:(NSString *)dateString;
{
    return [NSDate ky_timestampWithString:dateString format:nil];
}

+ (nullable NSString *)ky_timestampWithString:(NSString *)dateString format:(nullable NSString *)format;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    if (format) {
        [formatter setDateFormat:format];
    }
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [formatter dateFromString:dateString];
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    return [NSString stringWithFormat:@"%ld", (long)(timeSp * 1000)];
}

+ (nullable NSString *)ky_dateStrWithTimestamp:(NSString *)timestamp;
{
    return [NSDate ky_dateStrWithTimestamp:timestamp format:nil];
}

+ (nullable NSString *)ky_dateStrWithTimestamp:(NSString *)timestamp format:(NSString *)format;
{
    long long time = [timestamp longLongValue];
    //如果是13位字符串，需要除以1000,(13位代表的是毫秒，需要除以1000)
    if (timestamp.length == 13) {
        time = time / 1000;
    }
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    if (format) {
        [formatter setDateFormat:format];
    }
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;

}
@end
