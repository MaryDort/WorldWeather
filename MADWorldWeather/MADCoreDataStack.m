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

@implementation MADCoreDataStack

+ (instancetype)sharedCoreDataStack {
    static MADCoreDataStack *coreDataStack = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        coreDataStack = [[MADCoreDataStack alloc] init];
    });
    
    return coreDataStack;
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

- (void)saveObjects:(NSArray *)results {
    NSArray *workingDates = [self prepareDateForWork:[results valueForKeyPath:@"date"]];
    NSArray *uniqueWeather = [self uniquenessCheck:[self prepareArrayForWork:results substitutionalResource:workingDates]];
    
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
        weather.mixTempC = data[@"mintempC"];
        
        for (NSDictionary *hourlyData in data[@"hourly"]) {
            MADHourly *hourly = (MADHourly *)[NSEntityDescription insertNewObjectForEntityForName:@"MADHourly" inManagedObjectContext:self.managedObjectContext];
            
            hourly.time = hourlyData[@"time"];
            hourly.weatherDesc = hourlyData[@"weatherDesc"][0][@"value"];
            hourly.currentTempC = hourlyData[@"tempC"];
            hourly.currentTempF = hourlyData[@"tempF"];
            hourly.windSpeedMiles = hourlyData[@"windspeedMiles"];
            hourly.pressure = hourlyData[@"pressure"];
            hourly.weatherIconURL = hourlyData[@"weatherIconUrl"][0][@"value"];
            hourly.humidity = hourlyData[@"humidity"];
            hourly.feelsLikeF = hourlyData[@"FeelsLikeF"];
            hourly.feelsLikeC = hourlyData[@"FeelsLikeC"];
            
            [hourlySet addObject:hourly];
        }
        [weather addHourly:hourlySet];
        NSLog(@"");
    }
    
    if (uniqueWeather.count > 0) {
        [self saveToStorage];
    }
}

- (NSArray *)prepareDateForWork:(NSArray *)datesString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableArray *newDates = [[NSMutableArray alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    for (NSString *date in datesString) {
        [newDates addObject:[dateFormatter dateFromString:date]];
    }
    
    return newDates;
}

- (NSArray *)prepareArrayForWork:(NSArray *)source substitutionalResource:(NSArray *)substitutionalResource {
    for (NSInteger i = 0; i < source.count; i++) {
        [source[i] setValue:substitutionalResource[i] forKeyPath:@"date"];
    }
    
    return source;
}

- (NSArray *)uniquenessCheck:(NSArray *)weathers {
    NSArray *weatherDates = [weathers valueForKeyPath:@"date"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date IN %@", weatherDates];
    NSArray *response = [[self fetchingDistinctValueByPredicate:predicate] valueForKeyPath:@"date"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:
                                    ^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                                        return ![response containsObject:evaluatedObject[@"date"]];
                                    }];
    
    return [weathers filteredArrayUsingPredicate:filterPredicate];
}

- (NSArray *)fetchingDistinctValueByPredicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MADWeather"
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

@end
