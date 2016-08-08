//
//  MADForecastWeather.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 05.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MADForecastWeather : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithForecastInfo:(NSArray *)forecastInfo;

@end
