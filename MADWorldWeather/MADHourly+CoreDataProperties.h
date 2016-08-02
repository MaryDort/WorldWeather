//
//  MADHourly+CoreDataProperties.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MADHourly.h"

NS_ASSUME_NONNULL_BEGIN

@interface MADHourly (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *currentTempC;
@property (nullable, nonatomic, retain) NSString *currentTempF;
@property (nullable, nonatomic, retain) NSString *feelsLikeC;
@property (nullable, nonatomic, retain) NSString *feelsLikeF;
@property (nullable, nonatomic, retain) NSString *humidity;
@property (nullable, nonatomic, retain) NSString *pressure;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *weatherDesc;
@property (nullable, nonatomic, retain) NSString *weatherIconURL;
@property (nullable, nonatomic, retain) NSString *windSpeedMiles;
@property (nullable, nonatomic, retain) MADWeather *weather;

@end

NS_ASSUME_NONNULL_END
