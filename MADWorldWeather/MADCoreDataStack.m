//
//  MADCoreDataStack.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADCoreDataStack.h"
#import "MADWeather.h"
#import "MADHourly.h"
#import "MADCity.h"
#import "NSDate+MADDateFormatter.h"

@interface MADCoreDataStack()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MADCoreDataStack

+ (instancetype)sharedCoreDataStack {
    static MADCoreDataStack *coreDataStack = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        coreDataStack = [[MADCoreDataStack alloc] init];
    });
    
    return coreDataStack;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return self;
}

#pragma mark - get CoreDataStack

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"worldWeatherModel" ofType:@"momd"]];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WorldWeather.sqlite"];
    
    
    NSLog(@" storeURL = %@", storeURL);
    NSError *error;

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        NSLog(@"%@", [error description]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return _managedObjectContext;
}

#pragma mark - Private

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] firstObject];
}

- (void)saveObjects:(NSDictionary *)results {
//    BOOL uniqueCurrentCondition = [self uniquenessCurrentConditionCheck:results[@"data"][@"current_condition"][0][@"observation_time"] cityName:results[@"data"][@"request"][0][@"query"]];
//    MADHourly *currentCondition = nil;
//    
//    if (!uniqueCurrentCondition) {
       MADHourly *currentCondition = (MADHourly *)[NSEntityDescription insertNewObjectForEntityForName:@"MADHourly" inManagedObjectContext:self.managedObjectContext];
        
        currentCondition.date = [NSDate startOfDay];
        currentCondition.weatherDesc = results[@"data"][@"current_condition"][0][@"weatherDesc"][0][@"value"];
        currentCondition.currentTempC = results[@"data"][@"current_condition"][0][@"temp_C"];
        currentCondition.currentTempF = results[@"data"][@"current_condition"][0][@"temp_F"];
        currentCondition.windSpeed = [NSString stringWithFormat:@"%@ at %@ km/h",  results[@"data"][@"current_condition"][0][@"winddir16Point"], results[@"data"][@"current_condition"][0][@"windspeedKmph"]];
        currentCondition.pressure = results[@"data"][@"current_condition"][0][@"pressure"];
        currentCondition.weatherIconURL = results[@"data"][@"current_condition"][0][@"weatherIconUrl"][0][@"value"];
        currentCondition.humidity = results[@"data"][@"current_condition"][0][@"humidity"];
        currentCondition.feelsLikeF = results[@"data"][@"current_condition"][0][@"FeelsLikeF"];
        currentCondition.feelsLikeC = results[@"data"][@"current_condition"][0][@"FeelsLikeC"];
        currentCondition.observationTime = results[@"data"][@"current_condition"][0][@"observation_time"];
//    }
    
    MADCity *city = (MADCity*)[NSEntityDescription insertNewObjectForEntityForName:@"MADCity" inManagedObjectContext:self.managedObjectContext];
    
    city.name = results[@"data"][@"request"][0][@"query"];
//    if (currentCondition != nil) {
        city.currentHourlyWeather = currentCondition;
//    }
    [self removeOutdatedWeatherByCity:city];
    
    NSArray *workingDates = [self custDate:[results[@"data"][@"weather"] valueForKeyPath:@"date"]];
    NSArray *uniqueWeather = [self uniquenessWeatherCheck:[self prepareArrayForWork:results[@"data"][@"weather"] substitutionalResource:workingDates] city:city];
    NSMutableSet *weatherSet = [[NSMutableSet alloc] init];
    
    for (NSDictionary *data in uniqueWeather) {
        MADWeather *weather = (MADWeather *)[NSEntityDescription insertNewObjectForEntityForName:@"MADWeather" inManagedObjectContext:self.managedObjectContext];
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
            MADHourly *hourly = (MADHourly *)[NSEntityDescription insertNewObjectForEntityForName:@"MADHourly" inManagedObjectContext:self.managedObjectContext];
            
            hourly.time = [NSNumber numberWithInteger:[hourlyData[@"time"] integerValue]/100];
            hourly.weatherDesc = hourlyData[@"weatherDesc"][0][@"value"];
            hourly.currentTempC = hourlyData[@"tempC"];
            hourly.currentTempF = hourlyData[@"tempF"];
            hourly.windSpeed = [NSString stringWithFormat:@"%@ at %@ km/h", hourlyData[@"winddir16Point"], hourlyData[@"windspeedKmph"]];
            hourly.pressure = hourlyData[@"pressure"];
            hourly.weatherIconURL = hourlyData[@"weatherIconUrl"][0][@"value"];
            hourly.humidity = hourlyData[@"humidity"];
            hourly.feelsLikeF = hourlyData[@"FeelsLikeF"];
            hourly.feelsLikeC = hourlyData[@"FeelsLikeC"];
            
            [hourlySet addObject:hourly];
        }
        [weather addHourly:hourlySet];
        [weatherSet addObject:weather];
    }
    [city addWeather:weatherSet];
    [self saveToStorage];
}

- (NSArray *)custDate:(NSArray *)datesString {
    NSMutableArray *newDates = [[NSMutableArray alloc] init];
    
    for (NSString *date in datesString) {
        [newDates addObject:[_dateFormatter dateFromString:date]];
    }
    
    return newDates;
}

- (NSArray *)prepareArrayForWork:(NSArray *)source
          substitutionalResource:(NSArray *)substitutionalResource {
//    NSString  date замінити NSDate date
    for (NSInteger i = 0; i < source.count; i++) {
        [source[i] setValue:substitutionalResource[i] forKeyPath:@"date"];
    }
    
    return source;
}

- (BOOL)uniquenessCurrentConditionCheck:(NSString *)currentConditionTime cityName:(NSString *)cityName {
//        перевірити чи є місто в базі
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", cityName];
    MADCity *city = [self fetchingDistinctValueByPredicate:predicate entityName:@"MADCity"].firstObject;
    
    if (city == nil) {
//        немає, зберігаємо
        return NO;
    } else if ([city.currentHourlyWeather.observationTime isEqualToString:currentConditionTime]) {
//        є, перевіряємо чи observationTime == currentConditionTime, якщо так - НЕзберігаємо
        return YES;
    } else {
//        ні - зберігаємо
        return NO;
    }
}

- (NSArray *)uniquenessWeatherCheck:(NSArray *)weathers city:(MADCity *)city {
    NSArray *oldWeahtersDates = [city.weather valueForKeyPath:@"date"];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSDate *date = evaluatedObject[@"date"];
        return ![oldWeahtersDates containsObject:date];
    }];
    return [weathers filteredArrayUsingPredicate:predicate];
}

- (NSArray *)fetchingDistinctValueByPredicate:(NSPredicate *)predicate
                                   entityName:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    request.predicate = predicate;
    request.sortDescriptors = [[NSArray alloc] init];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"%@", [error description]);
    }
    
    return array;
}

- (void)saveToStorage {
    NSError *error;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error description]);
    }
}

- (void)removeOutdatedWeatherByCity:(MADCity *)city {
    NSDate *currentDate = [NSDate formattedDate];
    
    for (MADWeather *weather in city.weather) {
        if ([weather.date compare:currentDate] == NSOrderedAscending) {
            [self.managedObjectContext deleteObject:weather];
        }
    }
    [self saveToStorage];
}

@end
