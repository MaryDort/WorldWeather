//
//  ViewController.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "ViewController.h"
#import "MADDownloader.h"
#import "MADCoreDataStack.h"
#import "CoreData/CoreData.h"
#import "MADHourlyWeather.h"
#import "MADForecastWeather.h"
#import "MADWeather.h"
#import "MADHourly.h"
#import "NSDate+MADDateFormatter.h"

@interface ViewController ()
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
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *humidityValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *windValueLabel;
@property (weak, nonatomic) IBOutlet UITableView *hourlyWeatherTabelView;
@property (weak, nonatomic) IBOutlet UITableView *forecastWeatherTabelView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTabelName;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescription;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *fondVisualEffectView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *tabelVisualEffectView;


@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) MADHourlyWeather *hourlyWeather;
@property (nonatomic, readwrite, strong) MADForecastWeather *forecastWeather;
@property (nonatomic, readwrite, strong) NSDate *currentDate;
@property (nonatomic, readwrite, strong) MADWeather *currentWeather;
@property (nonatomic, readwrite, strong) MADHourly *observationWeather;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentDate = [NSDate formattedDate];
    
    [_hourlyWeatherTabelView registerNib:[UINib nibWithNibName:@"MADHourlyWeatherTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADHourlyWeatherTableViewCell"];
    [_forecastWeatherTabelView registerNib:[UINib nibWithNibName:@"MADForecastWeatherTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADForecastWeatherTableViewCell"];
    
    [[MADDownloader sharedDownloader] downloadDataWithLocationName:@"Kiev" days:[NSNumber numberWithInteger:7] callBack:^(NSDictionary *results) {
        [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
        [self configureObservationWeatherViews];
        [self configureHourlyWeatherTabelView];
        [self configureForecastWeatherTabelView];
    }];
}

- (void)configureObservationWeatherViews {
    _fondVisualEffectView.layer.cornerRadius = 10.f;
    _fondVisualEffectView.layer.masksToBounds = YES;
    _currentWeather = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    _maxTempLabel.text = [NSString stringWithFormat:@"max - %@°", _currentWeather.maxTempC];
    _minTempLabel.text = [NSString stringWithFormat:@"min - %@°", _currentWeather.minTempC];
    _moonriseLabel.text = _currentWeather.moonrise;
    _moonsetLabel.text = _currentWeather.moonset;
    _sunriseLabel.text = _currentWeather.sunrise;
    _sunsetLabel.text = _currentWeather.sunset;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MADHourly" inManagedObjectContext:_managedObjectContext];
    self.fetchedResultsController.fetchRequest.entity = entityDescription;
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"observationTime != %@", nil];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    _observationWeather = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if ([_observationWeather.weatherDesc isEqualToString:@"Sunny"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"sunny"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"sun"];
    } else if ([_observationWeather.weatherDesc isEqualToString:@"Rainy"]) {
        _currentWeatherImageView.image = [UIImage imageNamed:@"rainy"];
        _currentWeatherIcon.image = [UIImage imageNamed:@"rain"];
    }
    
    _currentWeatherTemp.text = [NSString stringWithFormat:@"%@°", _observationWeather.currentTempC];
    _humidityValueLabel.text = [NSString stringWithFormat:@"Humidity %@ %%", _observationWeather.humidity];
    _pressureValueLabel.text = [NSString stringWithFormat:@"Pressure %@ hPa", _observationWeather.pressure];
    _windValueLabel.text = [NSString stringWithFormat:@"%@", _observationWeather.windSpeed];
    _weatherDescription.text = _observationWeather.weatherDesc;
}

- (void)configureHourlyWeatherTabelView {
    _hourlyWeather = [[MADHourlyWeather alloc] initWithDate:_currentDate
                                                 hourlyInfo:_currentWeather.hourly.allObjects];
    
    _hourlyWeatherTabelView.dataSource = _hourlyWeather;
    _hourlyWeatherTabelView.delegate = _hourlyWeather;
    _tabelVisualEffectView.layer.cornerRadius = 10.f;
    _tabelVisualEffectView.layer.masksToBounds = YES;
    
    [_hourlyWeatherTabelView reloadData];
}

- (void)configureForecastWeatherTabelView {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MADWeather"
                                                         inManagedObjectContext:_managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    self.fetchedResultsController.fetchRequest.entity = entityDescription;
    self.fetchedResultsController.fetchRequest.sortDescriptors = @[sortDescriptor];
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date > %@", _currentDate];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    _forecastWeather = [[MADForecastWeather alloc] initWithForecastInfo:self.fetchedResultsController.fetchedObjects];
    _forecastWeatherTabelView.dataSource = _forecastWeather;
    _forecastWeatherTabelView.delegate = _forecastWeather;
    _forecastWeatherTabelView.layer.cornerRadius = 10.f;
    [_forecastWeatherTabelView reloadData];
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

- (NSArray *)prepareHourlyForWork:(NSArray *)objects {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    
    return [objects sortedArrayUsingDescriptors:@[sortDesc]];
}

@end
