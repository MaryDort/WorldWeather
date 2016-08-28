//
//  MADDetailViewController.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADDetailViewController.h"
#import "MADDownloader.h"
#import "MADCoreDataStack.h"
#import "MADWeather.h"
#import "MADHourly.h"
#import "NSDate+MADDateFormatter.h"
#import "MADArrayTableViewDataSource.h"
#import "MADHourlyWeatherTableViewCell.h"
#import "MADWeatherImageProvider.h"

@interface MADDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *weatherDesc;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *fondSunMoonVisualEffectView;
@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moonriseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moonsetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sunriseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sunsetImageView;
@property (weak, nonatomic) IBOutlet UILabel *moonriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *moonsetLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentWeatherTemp;
@property (weak, nonatomic) IBOutlet UILabel *humidityValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *windValueLabel;
@property (weak, nonatomic) IBOutlet UITableView *hourlyWeatherTabelView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTabelName;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *fondVisualEffectView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *tabelVisualEffectView;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSDate *currentDate;
@property (nonatomic, readwrite, strong) MADWeather *currentWeather;
@property (nonatomic, readwrite, strong) MADHourly *observationHourly;
@property (nonatomic, readwrite, strong) MADArrayTableViewDataSource *hourlyDataSource;
@property (nonatomic, readwrite, strong) MADWeatherImageProvider *weatherImageProvider;

@end

@implementation MADDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([_city.name containsString:@"United States of America"]) {
        self.navigationItem.title = [_city.name stringByReplacingOccurrencesOfString:@"United States of America" withString:@"USA"];
    } else {
        self.navigationItem.title = _city.name;
    }
    
    _currentDate = [NSDate formattedDate];
    
    [_hourlyWeatherTabelView registerNib:[UINib nibWithNibName:@"MADHourlyWeatherTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADHourlyWeatherTableViewCell"];

    [self configureObservationWeatherViews];
    [self configureHourlyWeatherTabelView];
}

- (void)configureObservationWeatherViews {
    _currentWeather = [_city.weather.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]].firstObject;
    
    _maxTempLabel.text = [NSString stringWithFormat:@"max - %@°", _currentWeather.maxTempC];
    _minTempLabel.text = [NSString stringWithFormat:@"min - %@°", _currentWeather.minTempC];
    _fondSunMoonVisualEffectView.layer.masksToBounds = YES;
    _fondSunMoonVisualEffectView.layer.cornerRadius = 5.f;
    _moonriseLabel.text = _currentWeather.moonrise;
    _moonsetLabel.text = _currentWeather.moonset;
    _sunriseLabel.text = _currentWeather.sunrise;
    _sunsetLabel.text = _currentWeather.sunset;
    
    _observationHourly = _city.currentHourlyWeather;
    _weatherDesc.text = _observationHourly.weatherDesc;

    _weatherImageProvider = [[MADWeatherImageProvider alloc] init];
    _currentWeatherImageView.image = [_weatherImageProvider backgroundImageForHourlyWeather:_observationHourly];
    _currentWeatherIcon.image = [_weatherImageProvider weatherIconForHourlyWeather:_observationHourly];
    
    _fondVisualEffectView.layer.cornerRadius = 5.f;
    _fondVisualEffectView.layer.masksToBounds = YES;
    _currentWeatherTemp.text = [NSString stringWithFormat:@"%@°", _observationHourly.currentTempC];
    _humidityValueLabel.text = [NSString stringWithFormat:@"Humidity %@ %%", _observationHourly.humidity];
    _pressureValueLabel.text = [NSString stringWithFormat:@"Pressure %@ hPa", _observationHourly.pressure];
    _windValueLabel.text = [NSString stringWithFormat:@"%@", _observationHourly.windSpeed];
}

- (void)configureHourlyWeatherTabelView {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    NSArray *sortedHourly = [_currentWeather.hourly.allObjects sortedArrayUsingDescriptors:@[sortDesc]];
    
    self.hourlyDataSource = [[MADArrayTableViewDataSource alloc] initWithObjects:sortedHourly cellForRowAtIndexPathBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id object) {
        MADHourlyWeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADHourlyWeatherTableViewCell"];
        MADHourly *hourly = object;
        
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
    }];
    
    _hourlyWeatherTabelView.dataSource = _hourlyDataSource;
    _tabelVisualEffectView.layer.cornerRadius = 5.f;
    _tabelVisualEffectView.layer.masksToBounds = YES;
}

@end
