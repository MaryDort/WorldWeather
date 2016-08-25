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
#import "MADWeatherParser.h"

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
    MADWeatherParser *weatherParcer = [[MADWeatherParser alloc] initWithManagedObjectContext:self.managedObjectContext];
    MADCity *city = (MADCity*)[NSEntityDescription insertNewObjectForEntityForName:@"MADCity" inManagedObjectContext:self.managedObjectContext];
    
    city.name = results[@"data"][@"request"][0][@"query"];
    city.currentHourlyWeather = [weatherParcer currentHourlyWeather:results[@"data"][@"current_condition"][0]];
    
//    видалити погоду за попередні дні
    [self removeOutdatedWeatherByCity:city];
    
    [city addWeather:[self weatherbyCity:city weatherParcer:weatherParcer data:results[@"data"][@"weather"]]];
    [self saveToStorage];
}

- (void)updateObjects:(NSDictionary *)results {
    NSString *currentConditionTime = results[@"data"][@"current_condition"][0][@"observation_time"];
    NSString *cityName = results[@"data"][@"request"][0][@"query"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", cityName];
    MADCity *city = [self fetchingDistinctValueByPredicate:predicate entityName:@"MADCity"].firstObject;
    MADWeatherParser *weatherParcer = [[MADWeatherParser alloc] initWithManagedObjectContext:self.managedObjectContext];
    
//       1. то й ж день
    if ([city.currentHourlyWeather.date isEqual:[NSDate startCurrentDay]]) {
        //        той ж день, перевіряємо чи observationTime != currentConditionTime, якщо не дорівнює - зберігаємо(видаляємо попередній), дорівнює - нічого не робимо
        if (![city.currentHourlyWeather.observationTime isEqualToString:currentConditionTime]) {
            [self.managedObjectContext deleteObject:city.currentHourlyWeather];
            
            city.currentHourlyWeather = [weatherParcer currentHourlyWeather:results[@"data"][@"current_condition"][0]];
        }
//       2. інший день - видалити попередню погоду, зберегти поточну
    } else {
        [self.managedObjectContext deleteObject:city.currentHourlyWeather];
        
        for (MADWeather *weather in city.weather) {
            [self.managedObjectContext deleteObject:weather];
        }
        
        city.currentHourlyWeather = [weatherParcer currentHourlyWeather:results[@"data"][@"current_condition"][0]];
        [city addWeather:[self weatherbyCity:city weatherParcer:weatherParcer data:results[@"data"][@"weather"]]];
    }
    [self saveToStorage];
}

- (NSSet *)weatherbyCity:(MADCity *)city weatherParcer:(MADWeatherParser *)weatherParcer data:(NSArray *)data {
    NSArray *preparedWeather = [self prepareDateForWork:data];
    NSArray *uniqueWeather = [self uniquenessWeatherCheck:preparedWeather city:city];
    
    return [weatherParcer weatherSetFromData:uniqueWeather];
}

- (NSArray *)custDates:(NSArray *)datesString {
    NSMutableArray *newDates = [[NSMutableArray alloc] init];
    
    for (NSString *date in datesString) {
        [newDates addObject:[_dateFormatter dateFromString:date]];
    }
    
    return newDates;
}

- (NSArray *)prepareDateForWork:(NSArray *)source {
    NSArray *workingDates = [self custDates:[source valueForKeyPath:@"date"]];
    
//    NSString  date замінити NSDate date
    for (NSInteger i = 0; i < source.count; i++) {
        [source[i] setValue:workingDates[i] forKeyPath:@"date"];
    }
    
    return source;
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
}

@end
