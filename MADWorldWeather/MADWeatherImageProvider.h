//
//  MADWeatherImageProvider.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 28.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MADHourly;

@interface MADWeatherImageProvider : NSObject

- (UIImage *)backgroundImageForHourlyWeather:(MADHourly *)hourlyWeather;
- (UIImage *)weatherIconForHourlyWeather:(MADHourly *)hourlyWeather;

@end
