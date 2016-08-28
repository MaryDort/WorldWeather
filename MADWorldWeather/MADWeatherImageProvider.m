//
//  MADWeatherImageProvider.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 28.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADWeatherImageProvider.h"
#import "MADHourly.h"

@interface MADWeatherImageProvider ()

@property (nonatomic, readwrite, strong) NSDictionary *weatherIconDict;

@end

@implementation MADWeatherImageProvider

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _weatherIconDict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"WeathersCodesIconNamesMap" withExtension:@"plist"]];
    }
    
    return self;
}

- (UIImage *)backgroundImageForHourlyWeather:(MADHourly *)hourlyWeather {
    NSString *key = [NSString stringWithFormat:@"%@", hourlyWeather.weatherCode];
    
    return [UIImage imageNamed:_weatherIconDict[key][@"backgrondImage"]];
}

- (UIImage *)weatherIconForHourlyWeather:(MADHourly *)hourlyWeather {
    NSString *key = [NSString stringWithFormat:@"%@", hourlyWeather.weatherCode];
    
    return [UIImage imageNamed:_weatherIconDict[key][@"icon"]];
}

@end
