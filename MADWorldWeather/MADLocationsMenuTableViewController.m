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

@interface MADLocationsMenuTableViewController ()

@property (strong, nonatomic, readwrite) NSMutableArray *locationsArray;
@property (strong, nonatomic, readwrite) UISearchController *searchController;
@property (strong, nonatomic, readwrite) MADLocationSearchTableViewController *searchResultsController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;

@end

@implementation MADLocationsMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationsArray = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MADLocationsMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADLocationsMenuTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (IBAction)addLocation:(UIBarButtonItem *)sender {
    _searchResultsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MADLocationSearchTableViewController"];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultsController];
    _searchController.searchResultsUpdater = _searchResultsController;
    
    __weak MADLocationsMenuTableViewController *temp = self;
    _searchResultsController.complitionBlock = ^void(NSString *placeName) {
        MADLocationsMenuTableViewController *temp2 = temp;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [[MADDownloader sharedDownloader] downloadDataWithLocationName:placeName days:[NSNumber numberWithInteger:1] callBack:^(NSDictionary *results) {
            [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
            
            
            MADFetchedResults *fetchedResults = [[MADFetchedResults alloc] initWithDate:[NSDate date]];
            
            fetchedResults.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@" & date = %@", [NSDate startOfDay]];
            
            
            
            
            
            
        }];
        
        
        [temp2.locationsArray insertObject:placeName atIndex:temp2.locationsArray.count];
        [temp2.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [temp2.tableView reloadData];
    };
    
    [self presentViewController:_searchController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _locationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADLocationsMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADLocationsMenuTableViewCell"];
    
    cell.currentLocationNameLabel.text = [_locationsArray objectAtIndex:indexPath.row];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_locationsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

@end
