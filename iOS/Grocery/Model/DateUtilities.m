//
//  DateUtilities.m
//  Grocery
//
//  Created by Xiao on 7/15/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "DateUtilities.h"

@implementation DateUtilities
+ (NSDate *)startOfDay:(NSDate *)date {
    NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [startDateComponents setHour:0];
    [startDateComponents setMinute:0];
    [startDateComponents setSecond:0];
    NSDate *startOfDate = [[NSCalendar currentCalendar] dateFromComponents:startDateComponents];
    return startOfDate;
}

+ (NSDate *)endOfDay:(NSDate *)date {
    NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [endDateComponents setHour:0];
    [endDateComponents setMinute:0];
    [endDateComponents setSecond:0];
    [endDateComponents setDay:endDateComponents.day + 1];
    NSDate *endOfDay = [[NSCalendar currentCalendar] dateFromComponents:endDateComponents];
    return endOfDay;
}

+ (NSDate *) startOfMonth:(NSDate *)date{
    NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date];
    //set date components
    [startDateComponents setDay:1];
    [startDateComponents setHour:0];
    [startDateComponents setMinute:0];
    [startDateComponents setSecond:0];
    NSDate *startOfMonth = [[NSCalendar currentCalendar] dateFromComponents:startDateComponents];
    return startOfMonth;
}

+ (NSDate *)endOfMonth:(NSDate *)date {
    NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    [endDateComponents setMonth:[endDateComponents month]+1];
    [endDateComponents setDay:1];
    [endDateComponents setHour:0];
    [endDateComponents setMinute:0];
    [endDateComponents setSecond:0];
    NSDate *endOfMonth = [[NSCalendar currentCalendar] dateFromComponents:endDateComponents];
    return endOfMonth;
}

+ (NSString *) dayStringForDate: (NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd" options:0 locale:[NSLocale currentLocale]];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSString *) monStringForDate: (NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM" options:0 locale:[NSLocale currentLocale]];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSDateFormatter*)dateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
}

+ (NSDateFormatter *) timeFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    return formatter;
}

+ (NSString *) mySQLDateTimeForDate: (NSDate *) date{
    return [NSString stringWithFormat:@"%@ %@", [self mySQLDateForDate:date], [self mySQLTimeForDate:date]];
}

+ (NSString*) mySQLDateForDate: (NSDate*) date {
    return [[DateUtilities dateFormatter] stringFromDate:date];
}

+ (NSString*) mySQLTimeForDate: (NSDate*) date {
    return [[DateUtilities timeFormatter] stringFromDate:date];
}

+ (NSDateFormatter *) dateTimeFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return formatter;
}

+ (NSDate *) dateTimeUsingStringFromAPI: (NSString *) mySQLDate {
    return [[DateUtilities dateTimeFormatter] dateFromString:mySQLDate];
}


@end
