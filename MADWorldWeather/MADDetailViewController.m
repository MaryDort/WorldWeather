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
#import "CoreData/CoreData.h"
#import "MADHourlyWeather.h"
#import "MADForecastWeather.h"
#import "MADWeather.h"
#import "MADHourly.h"
#import "NSDate+MADDateFormatter.h"

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



@property (weak, nonatomic) IBOutlet UITableView *forecastWeatherTabelView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTabelName;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *fondVisualEffectView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *tabelVisualEffectView;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) MADHourlyWeather *hourlyWeather;
@property (nonatomic, readwrite, strong) MADForecastWeather *forecastWeather;
@property (nonatomic, readwrite, strong) NSDate *currentDate;
@property (nonatomic, readwrite, strong) MADWeather *currentWeather;
@property (nonatomic, readwrite, strong) MADHourly *observationHourly;

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
    [_forecastWeatherTabelView registerNib:[UINib nibWithNibName:@"MADForecastWeatherTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADForecastWeatherTableViewCell"];
    
    [self configureObservationWeatherViews];
    [self configureHourlyWeatherTabelView];
//    [self configureForecastWeatherTabelView];
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
    NSLog(@"%@", _observationHourly.weatherDesc);
    
    if ([_observationHourly.weatherDesc containsString:@"Sunny"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"sunny"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"sun"];
    } else if ([_observationHourly.weatherDesc containsString:@"Partly Cloudy"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"part"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"partly"];
    } else if ([_observationHourly.weatherDesc containsString:@"Overcast"] || [_observationHourly.weatherDesc containsString:@"Cloudy"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"over"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"overcast"];
    } else if ([_observationHourly.weatherDesc containsString:@"Clear"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"clear"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"sun"];
    } else if ([_observationHourly.weatherDesc containsString:@"Light Rain"] || [_observationHourly.weatherDesc containsString:@"Light rain shower"] || [_observationHourly.weatherDesc containsString:@"Light drizzle"] || [_observationHourly.weatherDesc containsString:@"Patchy light drizzle"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"lightRain"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"rain"];
    } else if ([_observationHourly.weatherDesc containsString:@"Moderate rain"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"moderateRain"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"rain"];
    } else if ([_observationHourly.weatherDesc containsString:@"Fog"] || [_observationHourly.weatherDesc containsString:@"Haze"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"fog"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"fogIcon"];
    } else if ([_observationHourly.weatherDesc containsString:@"Thunderstorm"] && [_observationHourly.weatherDesc containsString:@"Heavy Rain"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"heavyRain"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"storm"];
    } else if ([_observationHourly.weatherDesc containsString:@"Thunderstorm"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"thunderstorm"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"storm"];
    }
    
    _fondVisualEffectView.layer.cornerRadius = 5.f;
    _fondVisualEffectView.layer.masksToBounds = YES;
    _currentWeatherTemp.text = [NSString stringWithFormat:@"%@°", _observationHourly.currentTempC];
    _humidityValueLabel.text = [NSString stringWithFormat:@"Humidity %@ %%", _observationHourly.humidity];
    _pressureValueLabel.text = [NSString stringWithFormat:@"Pressure %@ hPa", _observationHourly.pressure];
    _windValueLabel.text = [NSString stringWithFormat:@"%@", _observationHourly.windSpeed];
}

- (void)configureHourlyWeatherTabelView {
    _hourlyWeather = [[MADHourlyWeather alloc] initWithDate:_currentDate
                                                 hourlyInfo:_currentWeather.hourly.allObjects];
    
    _hourlyWeatherTabelView.dataSource = _hourlyWeather;
    _hourlyWeatherTabelView.delegate = _hourlyWeather;
    _tabelVisualEffectView.layer.cornerRadius = 5.f;
    _tabelVisualEffectView.layer.masksToBounds = YES;
    
    [_hourlyWeatherTabelView reloadData];
}

//- (void)configureForecastWeatherTabelView {
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MADWeather"
//                                                         inManagedObjectContext:_managedObjectContext];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
//    self.fetchedResultsController.fetchRequest.entity = entityDescription;
//    self.fetchedResultsController.fetchRequest.sortDescriptors = @[sortDescriptor];
//    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date > %@", _currentDate];
//    
//    NSError *error = nil;
//    if (![self.fetchedResultsController performFetch:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//    }
//    
//    _forecastWeather = [[MADForecastWeather alloc] initWithForecastInfo:self.fetchedResultsController.fetchedObjects];
//    
//    _forecastWeatherTabelView.dataSource = _forecastWeather;
//    _forecastWeatherTabelView.delegate = _forecastWeather;
//    _forecastWeatherTabelView.layer.cornerRadius = 5.f;
//    [_forecastWeatherTabelView reloadData];
//}

- (NSArray *)prepareHourlyForWork:(NSArray *)objects {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    
    return [objects sortedArrayUsingDescriptors:@[sortDesc]];
}

@end
