//
//  NSDate+MADDateFormatter.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 22.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MADDateFormatter)

+ (NSDate *)formattedDate;
+ (NSDate *)startCurrentDay;

@end
