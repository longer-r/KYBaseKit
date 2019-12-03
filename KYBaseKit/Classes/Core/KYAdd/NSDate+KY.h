//
//  NSDate+KY.h
//  KYBaseKit
//
//  Created by zr on 2019/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (KY)

#pragma mark - Formatter
///=============================================================================
/// @name Formatter
///=============================================================================
+ (NSDateFormatter *)formatterWithCurrentLocale;
+ (NSDateFormatter *)formatterWithTimeZoneSeconds;

#pragma mark - 日期属性（Component Properties）
///=============================================================================
/// @name 日期属性（Component Properties）
///=============================================================================

@property (nonatomic, readonly) NSInteger ky_year; ///< Year component
@property (nonatomic, readonly) NSInteger ky_month; ///< Month component (1~12)
@property (nonatomic, readonly) NSInteger ky_day; ///< Day component (1~31)
@property (nonatomic, readonly) NSInteger ky_hour; ///< Hour component (0~23)
@property (nonatomic, readonly) NSInteger ky_minute; ///< Minute component (0~59)
@property (nonatomic, readonly) NSInteger ky_second; ///< Second component (0~59)
@property (nonatomic, readonly) NSInteger ky_nanosecond; ///< Nanosecond component
@property (nonatomic, readonly) NSInteger ky_weekday; ///< Weekday component (1~7, first day is based on user setting)
@property (nonatomic, readonly) NSInteger ky_weekdayOrdinal; ///< WeekdayOrdinal component
@property (nonatomic, readonly) NSInteger ky_weekOfMonth; ///< WeekOfMonth component (1~5)
@property (nonatomic, readonly) NSInteger ky_weekOfYear; ///< WeekOfYear component (1~53)
@property (nonatomic, readonly) NSInteger ky_yearForWeekOfYear; ///< YearForWeekOfYear component
@property (nonatomic, readonly) NSInteger ky_quarter; ///< Quarter component
@property (nonatomic, readonly) BOOL ky_isLeapMonth; ///< whether the month is leap month
@property (nonatomic, readonly) BOOL ky_isLeapYear; ///< whether the year is leap year
@property (nonatomic, readonly) BOOL ky_isToday; ///< whether date is today (based on current locale)
@property (nonatomic, readonly) BOOL ky_isYesterday; ///< whether date is yesterday (based on current locale)
@property (nonatomic, readonly) NSDate *ky_startOfMonth;
@property (nonatomic, readonly) NSDate *ky_endOfMonth;

- (NSDate *)ky_dateByAddingDays:(NSInteger)days;
- (NSDate *)ky_dateByAddingMonths:(NSInteger)monthsToAdd;

#pragma mark - Date Format
///=============================================================================
/// @name Date Format
///=============================================================================


/**
 返回当前日期的字符串，使用 `format` 控制格式
 see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 for format description.
 
 @param format   日期的格式化方式
 e.g. @"yyyy-MM-dd HH:mm:ss"
 
 @return 格式化后的字符串。
 */
- (nullable NSString *)ky_stringWithFormat:(NSString *)format;

/**
 返回当前日期的字符串，使用 `format` 控制格式
 see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 for format description.
 
 @param format    日期的格式化方式
 e.g. @"yyyy-MM-dd HH:mm:ss"
 @param timeZone  使用的时区
 @param locale    使用地区
 
 @return 格式化后的字符串。
 */
- (nullable NSString *)ky_stringWithFormat:(NSString *)format
                                   timeZone:(nullable NSTimeZone *)timeZone
                                     locale:(nullable NSLocale *)locale;

/**
 返回当前日期的 ISO8601 格式字符串
 e.g. "2010-07-09T16:13:30+12:00"
 
 @return 格式化后的字符串
 */
- (nullable NSString *)ky_stringWithISOFormat;


/**
 字符串转换成日期，默认使用foramt yyyy-MM-dd HH:mm:ss
 如果字符串为空，返回当前日期[NSDate date]
 
 @param dateString 要转换日期的字符串
 */
+ (nullable NSDate *)ky_dateWithString:(NSString *)dateString;

/**
 字符串转换成日期
 如果字符串为空，返回当前日期[NSDate date]
 如果无法解析字符串，返回nil
 
 @param dateString 要转换日期的字符串
 @param format    日期的格式化方式
 e.g. @"yyyy-MM-dd HH:mm:ss"
 
 */
+ (nullable NSDate *)ky_dateWithString:(NSString *)dateString format:(NSString *)format;

/**
 字符串转换成日期，默认使用foramt yyyy-MM-dd HH:mm:ss
 如果字符串为空，返回当前日期[NSDate date]
 如果无法解析字符串，返回nil
 
 @param dateString 要转换日期的字符串
 @param timeZone  使用的时区
 @param locale    使用地区
 */
+ (nullable NSDate *)ky_dateWithString:(NSString *)dateString
                                 format:(NSString *)format
                               timeZone:(nullable NSTimeZone *)timeZone
                                 locale:(nullable NSLocale *)locale;

/**
 字符串转换成日期，使用ISO8601的日期格式
 
 @param dateString 要转换日期的字符串。 e.g. "2010-07-09T16:13:30+12:00"
 
 @return 返回转换成功的日期，如果无法转换返回nil
 */
+ (nullable NSDate *)ky_dateWithISOFormatString:(NSString *)dateString;


/// 日期装时间戳
/// @param date 日期
/// @param format 日期的格式化方式,默认使用foramt yyyy-MM-dd HH:mm:ss
+ (nullable NSString *)ky_timestampWithDate:(NSDate *)date format:(nullable NSString *)format;

/// 字符串转换成时间戳(单位毫秒),默认使用foramt yyyy-MM-dd HH:mm:ss
/// @param dateString 日期字符串
+ (nullable NSString *)ky_timestampWithString:(NSString *)dateString;

/// 字符串转换成时间戳(单位毫秒)
/// @param dateString 日期字符串
/// @param format 日期的格式化方式,默认使用foramt yyyy-MM-dd HH:mm:ss
+ (nullable NSString *)ky_timestampWithString:(NSString *)dateString format:(nullable NSString *)format;

/// 时间字符串转日期字符串,默认使用foramt yyyy-MM-dd HH:mm:ss
/// @param timestamp 时间字符串
+ (nullable NSString *)ky_dateStrWithTimestamp:(NSString *)timestamp;

/// 时间字符串转日期字符串
/// @param timestamp 时间字符串
/// @param format 日期的格式化方式,默认使用foramt yyyy-MM-dd HH:mm:ss
+ (nullable NSString *)ky_dateStrWithTimestamp:(NSString *)timestamp format:(nullable NSString *)format;

@end

NS_ASSUME_NONNULL_END
