//
//  MADHourlyWeather.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 03.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MADHourlyWeather : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithDate:(NSDate *)date hourlyInfo:(NSArray *)hourlyInfo;

@end
