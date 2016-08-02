//
//  MADWeather+CoreDataProperties.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MADWeather.h"

NS_ASSUME_NONNULL_BEGIN

@interface MADWeather (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSString *maxTempC;
@property (nullable, nonatomic, retain) NSString *maxTempF;
@property (nullable, nonatomic, retain) NSString *minTempF;
@property (nullable, nonatomic, retain) NSString *mixTempC;
@property (nullable, nonatomic, retain) NSString *moonrise;
@property (nullable, nonatomic, retain) NSString *moonset;
@property (nullable, nonatomic, retain) NSString *sunrise;
@property (nullable, nonatomic, retain) NSString *sunset;
@property (nullable, nonatomic, retain) NSSet<MADHourly *> *hourly;

@end

@interface MADWeather (CoreDataGeneratedAccessors)

- (void)addHourlyObject:(MADHourly *)value;
- (void)removeHourlyObject:(MADHourly *)value;
- (void)addHourly:(NSSet<MADHourly *> *)values;
- (void)removeHourly:(NSSet<MADHourly *> *)values;

@end

NS_ASSUME_NONNULL_END
