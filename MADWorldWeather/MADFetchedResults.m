//
//  MADFetchedResults.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 08.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADFetchedResults.h"
#import "MADCoreDataStack.h"
#include "NSDate+MADDateFormatter.h"


@interface MADFetchedResults ()

@property (nonatomic, readwrite, strong) NSDate *currentDate;

@end

@implementation MADFetchedResults

- (instancetype)initWithDate:(NSDate *)currentDate {
    self = [super init];
    
    if (self) {
        _currentDate = [NSDate formattedDate];
    }
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    _managedObjectContext = [[MADCoreDataStack sharedCoreDataStack] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MADWeather"
                                              inManagedObjectContext:_managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", _currentDate];
    request.entity = entity;
    request.fetchBatchSize = 1;
    request.predicate = predicate;
    request.sortDescriptors = @[];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:request
                                                             managedObjectContext:_managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:nil];
    _fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

@end
