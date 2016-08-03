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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentWeatherTemp;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescription;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *humidityValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureValueLabel;
@property (weak, nonatomic) IBOutlet UITableView *descriptionTabelView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTabelName;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) MADWeatherDescription *weatherDesc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_descriptionTabelView registerNib:[UINib nibWithNibName:@"MADDescriptionTableViewCell" bundle:nil]
                forCellReuseIdentifier:@"MADDescriptionTableViewCell"];
    [[MADDownloader sharedAPIDownloader] downloadDataWithCallBack:^(NSArray *results) {
        [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
        [self tuneTabelView];
    }];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    _managedObjectContext = [[MADCoreDataStack sharedCoreDataStack] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"data" ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MADWeather"
                                              inManagedObjectContext:_managedObjectContext];
    request.entity = entity;
    request.fetchBatchSize = 5;
    request.sortDescriptors = @[sortDescriptor];
    
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

- (void)tuneTabelView {
    _weatherDesc = [[MADWeatherDescription alloc] initWithDate:[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]]];
    
    _descriptionTabelView.dataSource = _weatherDesc;
    [_descriptionTabelView reloadData];
}


@end
