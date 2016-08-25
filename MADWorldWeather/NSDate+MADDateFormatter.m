//
//  NSDate+MADDateFormatter.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 22.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "NSDate+MADDateFormatter.h"

@implementation NSDate (MADDateFormatter)

+ (NSDate *)formattedDate {
    NSDate *startCurrentDay = [self startCurrentDay];
    NSDateFormatter * formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter dateFromString:[formatter stringFromDate:startCurrentDay]];
}

+ (NSDate *)startCurrentDay {
    return [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
}

@end
