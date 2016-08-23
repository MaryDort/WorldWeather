//
//  MADWeatherDescription.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 03.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADHourlyWeather.h"
#import "MADHourlyWeatherTableViewCell.h"
#import "CoreData/CoreData.h"
#import "MADCoreDataStack.h"
#import "MADHourly.h"
#import "MADDownloader.h"

@interface MADHourlyWeather ()

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSDate *date;
@property (nonatomic, readwrite, strong) NSArray *hourlyInfo;

@end

@implementation MADHourlyWeather

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
    return _hourlyInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADHourlyWeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADHourlyWeatherTableViewCell"];
    MADHourly *hourly = [_hourlyInfo objectAtIndex:indexPath.row];

    cell.timeLabel.text = [NSString stringWithFormat:@"%@:00", hourly.time];
    cell.tempLabel.text = [NSString stringWithFormat:@"%@°", hourly.currentTempC];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (!hourly.icon) {
        [[MADDownloader sharedDownloader] downloadDataWithURL:hourly.weatherIconURL callBack:^(NSData *imageData) {
            cell.descriptionIconImageView.image = [UIImage imageWithData:imageData];
        }];
    } else {
        cell.descriptionIconImageView.image = [UIImage imageWithData:hourly.icon];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.f;
}

#pragma mark - Private

- (NSArray *)prepareHourlyForWork:(NSArray *)objects {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    
    return [objects sortedArrayUsingDescriptors:@[sortDesc]];
}

@end
