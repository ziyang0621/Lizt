//
//  NSDate+Extras.m
//  lizt
//
//  Created by Ziyang Tan on 5/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "NSDate+Extras.h"

@implementation NSDate (Extras)

+(NSDate*)getDateWithHour:(NSUInteger)hour fromDate:(NSDate*)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger timeComps = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit);
    NSDateComponents *comps = [gregorian components:timeComps fromDate:date];
    [comps setHour:hour];
    [comps setMinute:0];
    return [gregorian dateFromComponents:comps];
}

+ (NSDate *)dateWithZeroSeconds:(NSDate *)date {
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

@end
