//
//  MADWeatherDescription.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 03.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MADWeatherDescription : NSObject <UITableViewDataSource>

- (instancetype)initWithDate:(NSDate *)date;

@end
