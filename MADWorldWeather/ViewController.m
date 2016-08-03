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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentWeatherTemp;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescription;
@property (weak, nonatomic) IBOutlet UILabel *location;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MADDownloader sharedAPIDownloader] downloadDataWithCallBack:^(NSArray *results) {
        [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
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

@end
