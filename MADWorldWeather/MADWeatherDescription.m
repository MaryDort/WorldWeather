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
@property (nonatomic, readwrite, strong) NSArray *hourlyInfo;

@end

@implementation MADWeatherDescription

- (instancetype)initWithDate:(NSDate *)date hourlyInfo:(NSArray *)hourlyInfo {
    self = [super init];
    
    if (self) {
        _date = date;
        _hourlyInfo = [self prepareHourlyForWork:hourlyInfo];
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"%lu", (unsigned long)_hourlyInfo.count);
    
    return _hourlyInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADDescriptionTableViewCell"];
    MADHourly *hourly = [_hourlyInfo objectAtIndex:indexPath.row];

    cell.timeLabel.text = [NSString stringWithFormat:@"%@:00", hourly.time];
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

- (NSArray *)prepareHourlyForWork:(NSArray *)objects {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    
    return [objects sortedArrayUsingDescriptors:@[sortDesc]];
}

@end
