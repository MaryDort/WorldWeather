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
@property (weak, nonatomic) IBOutlet UIImageView *moonriseImageView
;
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

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) MADWeatherDescription *weatherDesc;
@property (nonatomic, readwrite, strong) NSDate *currentDate;
@property (nonatomic, readwrite, strong) MADWeather *currentWeather;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentDate = [self prepareDateForWork:[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]]];
    
    [_descriptionTabelView registerNib:[UINib nibWithNibName:@"MADDescriptionTableViewCell" bundle:nil]
                forCellReuseIdentifier:@"MADDescriptionTableViewCell"];
    [[MADDownloader sharedAPIDownloader] downloadDataWithCallBack:^(NSArray *results) {
        [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
        [self tuneViews];
        [self tuneTabelView];
    }];
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

- (void)tuneViews {
    _currentWeather = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    _moonriseLabel.text = _currentWeather.moonrise;
    _moonsetLabel.text = _currentWeather.moonset;
    _sunriseLabel.text = _currentWeather.sunrise;
    _sunsetLabel.text = _currentWeather.sunset;
    _currentWeatherTemp.text = [NSString stringWithFormat:@"%@°", _currentWeather.maxTempC];
}

- (void)tuneTabelView {
    _weatherDesc = [[MADWeatherDescription alloc] initWithDate:_currentDate hourlyInfo:_currentWeather.hourly.allObjects];
    
    _descriptionTabelView.dataSource = _weatherDesc;
    [_descriptionTabelView reloadData];
}

- (NSDate *)prepareDateForWork:(NSDate *)date {
    NSDateFormatter * formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter dateFromString:[formatter stringFromDate:date]];
}

@end
