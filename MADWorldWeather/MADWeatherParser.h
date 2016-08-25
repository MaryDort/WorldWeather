//
//  MADWeatherParser.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 25.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CoreData/CoreData.h"
#import "MADCity.h"
#import "MADHourly.h"

@interface MADWeatherParser : NSObject

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (MADHourly *)currentHourlyWeather:(NSDictionary *)results;
- (NSSet *)weatherSetFromData:(NSArray *)uniqueWeather;

@end
