//
//  DateUtilities.h
//  Grocery
//
//  Created by Xiao on 7/15/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtilities : NSObject
+ (NSDate *) startOfDay: (NSDate *) date;
+ (NSDate *) endOfDay: (NSDate *) date;
+ (NSDate *) startOfMonth: (NSDate *) date;
+ (NSDate *) endOfMonth: (NSDate *) date;
+ (NSString *) dayStringForDate: (NSDate *) date;
+ (NSString *) monStringForDate: (NSDate *) date;
+ (NSString *) mySQLDateTimeForDate: (NSDate *) date;
+ (NSDate *) dateTimeUsingStringFromAPI: (NSString *) mySQLDate;
@end
