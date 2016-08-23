//
//  MADCity+CoreDataProperties.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 23.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MADCity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MADCity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<MADWeather *> *weather;

@end

@interface MADCity (CoreDataGeneratedAccessors)

- (void)addWeatherObject:(MADWeather *)value;
- (void)removeWeatherObject:(MADWeather *)value;
- (void)addWeather:(NSSet<MADWeather *> *)values;
- (void)removeWeather:(NSSet<MADWeather *> *)values;

@end

NS_ASSUME_NONNULL_END
