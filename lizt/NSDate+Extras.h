//
//  NSDate+Extras.h
//  lizt
//
//  Created by Ziyang Tan on 5/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

@import UIKit;

@interface NSDate (Extras)

+(NSDate*)getDateWithHour:(NSUInteger)hour fromDate:(NSDate*)date;

+(NSDate*)dateWithZeroSeconds:(NSDate *)date;

@end
