//
//  MADWeatherDescription.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 03.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADWeatherDescription.h"
#import "MADDescriptionTableViewCell.h"
#import "CoreData/CoreData.h"
#import "MADCoreDataStack.h"
#import "MADHourly.h"
#import "MADDownloader.h"

@interface MADWeatherDescription ()

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSDate *date;

@end

@implementation MADWeatherDescription

- (instancetype)initWithDate:(NSDate *)date {
    self = [super init];
    
    if (self) {
        _date = [self prepareDateForWork:date];
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    NSLog(@"%lu", (unsigned long)sectionInfo.numberOfObjects);
    
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADDescriptionTableViewCell"];
    MADHourly *hourly = (MADHourly *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.timeLabel.text = [NSString stringWithFormat:@"%@:00", [hourly.time substringToIndex:hourly.time.length - 2]];
    cell.tempLabel.text = [NSString stringWithFormat:@"%@°", hourly.currentTempC];
    
    if (!hourly.icon) {
        [[MADDownloader sharedAPIDownloader] downloadDataWithURL:hourly.weatherIconURL callBack:^(NSData *imageData) {
            cell.descriptionIconImageView.image = [UIImage imageWithData:imageData];
        }];
    } else {
        cell.descriptionIconImageView.image = [UIImage imageWithData:hourly.icon];
    }
    
    return cell;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }

    _managedObjectContext = [[MADCoreDataStack sharedCoreDataStack] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MADHourly"
                                              inManagedObjectContext:_managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weather.date == %@", _date];

    request.entity = entity;
    request.fetchBatchSize = 4;
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = predicate;
    
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

- (NSDate *)prepareDateForWork:(NSDate *)date {
    NSDateFormatter * formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];

    return [formatter dateFromString:[formatter stringFromDate:date]];
}

@end
