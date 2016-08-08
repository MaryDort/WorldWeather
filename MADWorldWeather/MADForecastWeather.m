//
//  MADForecastWeather.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 05.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADForecastWeather.h"
#import "MADWeather.h"
#import "MADForecastWeatherTableViewCell.h"

@interface MADForecastWeather ()

@property (strong, nonatomic, readwrite) NSArray *forecastInfo;

@end

@implementation MADForecastWeather

- (instancetype)initWithForecastInfo:(NSArray *)forecastInfo {
    self = [super init];
    
    if (self) {
        _forecastInfo = forecastInfo;
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _forecastInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADForecastWeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADForecastWeatherTableViewCell"];
    MADWeather *weather = [_forecastInfo objectAtIndex:indexPath.row];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", weather.date];
    cell.maxTempLabel.text = weather.maxTempC;
    cell.minTempLabel.text = weather.minTempC;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.f;
}

@end
