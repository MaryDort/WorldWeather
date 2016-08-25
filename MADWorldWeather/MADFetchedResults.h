//
//  MADFetchedResults.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 08.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@interface MADFetchedResults : NSObject

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;

@end
