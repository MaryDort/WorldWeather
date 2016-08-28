//
//  MADWeatherParser.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 25.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADWeatherParser.h"
#import "MADCoreDataStack.h"
#import "NSDate+MADDateFormatter.h"
#import "MADCity.h"
#import "MADHourly.h"
#import "MADWeather.h"

@interface MADWeatherParser ()

@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation MADWeatherParser

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    
    if (self) {
        _managedObjectContext = managedObjectContext;
    }
    
    return self;
}

- (MADHourly *)currentHourlyWeather:(NSDictionary *)results {
    MADHourly *currentCondition = (MADHourly *)[NSEntityDescription insertNewObjectForEntityForName:@"MADHourly" inManagedObjectContext:[[MADCoreDataStack sharedCoreDataStack] managedObjectContext]];
    
    currentCondition.date = [NSDate startCurrentDay];
    currentCondition.weatherDesc = results[@"weatherDesc"][0][@"value"];
    currentCondition.currentTempC = results[@"temp_C"];
    currentCondition.currentTempF = results[@"temp_F"];
    currentCondition.windSpeed = [NSString stringWithFormat:@"%@ at %@ km/h",  results[@"winddir16Point"], results[@"windspeedKmph"]];
    currentCondition.pressure = results[@"pressure"];
    currentCondition.weatherIconURL = results[@"weatherIconUrl"][0][@"value"];
    currentCondition.humidity = results[@"humidity"];
    currentCondition.feelsLikeF = results[@"FeelsLikeF"];
    currentCondition.feelsLikeC = results[@"FeelsLikeC"];
    currentCondition.observationTime = results[@"observation_time"];
    currentCondition.weatherCode = @([results[@"weatherCode"] integerValue]);
    
    return currentCondition;
}

- (NSSet *)weatherSetFromData:(NSArray *)uniqueWeather {
    NSMutableSet *weatherSet = [[NSMutableSet alloc] init];
    
    for (NSDictionary *data in uniqueWeather) {
        MADWeather *weather = (MADWeather *)[NSEntityDescription insertNewObjectForEntityForName:@"MADWeather" inManagedObjectContext:_managedObjectContext];
        NSMutableSet *hourlySet = [[NSMutableSet alloc] init];
        
        weather.sunrise = data[@"astronomy"][0][@"sunrise"];
        weather.sunset = data[@"astronomy"][0][@"sunset"];
        weather.moonset = data[@"astronomy"][0][@"moonset"];
        weather.moonrise = data[@"astronomy"][0][@"moonrise"];
        weather.date = data[@"date"];
        weather.maxTempF = data[@"maxtempF"];
        weather.minTempF = data[@"mintempF"];
        weather.maxTempC = data[@"maxtempC"];
        weather.minTempC = data[@"mintempC"];
        
        for (NSDictionary *hourlyData in data[@"hourly"]) {
            MADHourly *hourly = (MADHourly *)[NSEntityDescription insertNewObjectForEntityForName:@"MADHourly" inManagedObjectContext:_managedObjectContext];
            
            hourly.time = @([hourlyData[@"time"] integerValue]/100);
            hourly.weatherDesc = hourlyData[@"weatherDesc"][0][@"value"];
            hourly.currentTempC = hourlyData[@"tempC"];
            hourly.currentTempF = hourlyData[@"tempF"];
            hourly.windSpeed = [NSString stringWithFormat:@"%@ at %@ km/h", hourlyData[@"winddir16Point"], hourlyData[@"windspeedKmph"]];
            hourly.pressure = hourlyData[@"pressure"];
            hourly.weatherIconURL = hourlyData[@"weatherIconUrl"][0][@"value"];
            hourly.humidity = hourlyData[@"humidity"];
            hourly.feelsLikeF = hourlyData[@"FeelsLikeF"];
            hourly.feelsLikeC = hourlyData[@"FeelsLikeC"];
            hourly.date = weather.date;
            hourly.weatherCode = @([hourlyData[@"weatherCode"] integerValue]);
            
            [hourlySet addObject:hourly];
        }
        [weather addHourly:hourlySet];
        [weatherSet addObject:weather];
    }
    
    return weatherSet;
}


@end
