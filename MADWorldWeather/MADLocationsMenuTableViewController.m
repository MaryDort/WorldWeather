//
//  MADLocationsMenuTableViewController.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 07.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADLocationsMenuTableViewController.h"
#import "MADLocationSearchTableViewController.h"
#import "MADLocationsMenuTableViewCell.h"
#import "MADCoreDataStack.h"
#import "MADDownloader.h"
#import "MADFetchedResults.h"
#import "NSDate+MADDateFormatter.h"
#import "MADDetailViewController.h"
#import "MADCity.h"
#import "MADHourly.h"
#import "UIViewController+MADAlert.h"
#import "MADFetchedResultsTableViewDataSource.h"
#import "MADFetchedResultsTableViewAdapter.h"

@interface MADLocationsMenuTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *locationsArray;
@property (strong, nonatomic, readwrite) UISearchController *searchController;
@property (strong, nonatomic, readwrite) MADLocationSearchTableViewController *searchResultsController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (strong, nonatomic) IBOutlet UIView *backgraundView;
@property (strong, nonatomic, readwrite) MADFetchedResultsTableViewDataSource *dataSource;
@property (strong, nonatomic, readwrite) MADFetchedResultsTableViewAdapter *fetchedResultsAdapter;

@end

@implementation MADLocationsMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRefreshControl];
    [self configureFetchedResultsAdapter];
    [self configureDataSource];
    _locationsArray = [[NSMutableArray alloc] init];
    self.tableView.backgroundView = self.backgraundView;

    [self.tableView registerNib:[UINib nibWithNibName:@"MADLocationsMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADLocationsMenuTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)configureRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blackColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.layer.zPosition = 1.f;
    
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlRequest)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControlRequest {
    NSArray *cities = [self.fetchedResultsAdapter.fetchedResultsController.fetchedObjects valueForKeyPath:@"name"];
    __weak MADLocationsMenuTableViewController *weakSelf = self;
    
    for (NSString *city in cities) {
        [[MADDownloader sharedDownloader] downloadDataWithLocationName:city days:[NSNumber numberWithInteger:1] callBack:^(NSDictionary *results) {
            MADLocationsMenuTableViewController *strongSelf = weakSelf;
            
            if (results[@"data"][@"error"] == nil && results != nil) {
                [[MADCoreDataStack sharedCoreDataStack] updateObjects:results];
            } else {
                [strongSelf showFailedAlertWithMessage:[NSString stringWithFormat:@"Server error! Can't load %@ weather. Try next time.", city]];
            }
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void)configureDataSource {
    self.dataSource = [[MADFetchedResultsTableViewDataSource alloc] initWithFetchedResultsController:self.fetchedResultsAdapter.fetchedResultsController cellForRowAtIndexPathBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id object) {
        
        MADLocationsMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADLocationsMenuTableViewCell"];
        MADCity *city = object;
        NSString *temp = city.name;
        
        if ([temp containsString:@"United States of America"]) {
            temp = [temp stringByReplacingOccurrencesOfString:@"United States of America" withString:@"USA"];
        }
        cell.currentLocationNameLabel.text = temp;
        cell.currentTempLabel.text = [NSString stringWithFormat:@"%@°", city.currentHourlyWeather.currentTempC];
        
        return cell;
    }];
    
    self.dataSource.canEditItemAtIndexPathBlock = ^(UITableView *tableView, NSIndexPath *indexPath, MADCity *city) {
        return YES;
    };
    self.dataSource.commitEditingItemBlock = ^(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath, MADCity *city) {
        [city.managedObjectContext deleteObject:city];
        [[MADCoreDataStack sharedCoreDataStack] saveToStorage];
    };
    self.tableView.dataSource = self.dataSource;
}

- (void)configureFetchedResultsAdapter {
    MADFetchedResults *fetchedResults = [[MADFetchedResults alloc] init];
    self.fetchedResultsAdapter = [[MADFetchedResultsTableViewAdapter alloc] initWithFetchedResultsController:fetchedResults.fetchedResultsController tableView:self.tableView];
    fetchedResults.fetchedResultsController.delegate = self.fetchedResultsAdapter;
}

- (IBAction)addLocation:(UIBarButtonItem *)sender {
    _searchResultsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MADLocationSearchTableViewController"];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultsController];
    _searchController.searchResultsUpdater = _searchResultsController;
    __weak MADLocationsMenuTableViewController *weakSelf = self;
    _searchResultsController.complitionBlock = ^void(NSString *placeName) {
        [[MADDownloader sharedDownloader] downloadDataWithLocationName:placeName days:[NSNumber numberWithInteger:1] callBack:^(NSDictionary *results) {
            MADLocationsMenuTableViewController *strongSelf = weakSelf;
            
            if (results == nil || results[@"data"][@"error"] != nil){
                [strongSelf showFailedAlertWithMessage:@"Unable to find city!"];
            } else {
                [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
            }
        }];
    };
    
    [self presentViewController:_searchController animated:YES completion:nil];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MADCity *city = [self.fetchedResultsAdapter.fetchedResultsController objectAtIndexPath:indexPath];
    MADDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MADDetailViewController"];
    
    detailViewController.city = city;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

@end
