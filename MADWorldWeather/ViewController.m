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
#import "MADWeatherDescription.h"
#import "MADWeather.h"
#import "MADHourly.h"

@interface ViewController ()
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
@property (weak, nonatomic) IBOutlet UITableView *descriptionTabelView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTabelName;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescription;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) MADWeatherDescription *weatherDesc;
@property (nonatomic, readwrite, strong) NSDate *currentDate;
@property (nonatomic, readwrite, strong) MADWeather *currentWeather;
@property (nonatomic, readwrite, strong) MADHourly *observationWeather;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentDate = [self prepareDateForWork:[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]]];
    
    [_descriptionTabelView registerNib:[UINib nibWithNibName:@"MADDescriptionTableViewCell" bundle:nil]
                forCellReuseIdentifier:@"MADDescriptionTableViewCell"];
    [[MADDownloader sharedAPIDownloader] downloadDataWithCallBack:^(NSDictionary *results) {
        [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
        [self configureViews];
        [self configureTabelView];
    }];
}

- (void)configureViews {
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
    
    _currentWeatherTemp.text = [NSString stringWithFormat:@"%@°", _observationWeather.currentTempC];
    _humidityValueLabel.text = [NSString stringWithFormat:@"Humidity %@ %%", _observationWeather.humidity];
    _pressureValueLabel.text = [NSString stringWithFormat:@"Pressure %@ hPa", _observationWeather.pressure];
    _weatherDescription.text = _observationWeather.weatherDesc;
    
    if (!_observationWeather.icon) {
        [[MADDownloader sharedAPIDownloader] downloadDataWithURL:_observationWeather.weatherIconURL callBack:^(NSData *imageData) {
            _currentWeatherIcon.image = [UIImage imageWithData:imageData];
        }];
    } else {
        _currentWeatherIcon.image = [UIImage imageWithData:_observationWeather.icon];
    }
}

- (void)configureTabelView {
    _weatherDesc = [[MADWeatherDescription alloc] initWithDate:_currentDate hourlyInfo:_currentWeather.hourly.allObjects];
    
    _descriptionTabelView.dataSource = _weatherDesc;
    [_descriptionTabelView reloadData];
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

- (NSDate *)prepareDateForWork:(NSDate *)date {
    NSDateFormatter * formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter dateFromString:[formatter stringFromDate:date]];
}

- (NSArray *)prepareHourlyForWork:(NSArray *)objects {
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    
    return [objects sortedArrayUsingDescriptors:@[sortDesc]];
}

@end
