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

@interface MADLocationsMenuTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *locationsArray;
@property (strong, nonatomic, readwrite) UISearchController *searchController;
@property (strong, nonatomic, readwrite) MADLocationSearchTableViewController *searchResultsController;
@property (strong, nonatomic, readwrite) __block MADFetchedResults *fetchedResults;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (strong, nonatomic) IBOutlet UIView *backgraundView;


@end

@implementation MADLocationsMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationsArray = [[NSMutableArray alloc] init];
    _fetchedResults = [[MADFetchedResults alloc] init];
    _fetchedResults.fetchedResultsController.delegate = self;
    
    self.tableView.backgroundView = self.backgraundView;

    [self.tableView registerNib:[UINib nibWithNibName:@"MADLocationsMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"MADLocationsMenuTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (IBAction)addLocation:(UIBarButtonItem *)sender {
    _searchResultsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MADLocationSearchTableViewController"];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultsController];
    _searchController.searchResultsUpdater = _searchResultsController;
    _searchResultsController.complitionBlock = ^void(NSString *placeName) {
        [[MADDownloader sharedDownloader] downloadDataWithLocationName:placeName days:[NSNumber numberWithInteger:1] callBack:^(NSDictionary *results) {
            [[MADCoreDataStack sharedCoreDataStack] saveObjects:results];
        }];
    };
    
    [self presentViewController:_searchController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _fetchedResults.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchedResults.fetchedResultsController.sections[section];
    
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MADLocationsMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MADLocationsMenuTableViewCell"];
    MADCity *city = [_fetchedResults.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.currentLocationNameLabel.text = city.name;
    cell.currentTempLabel.text = [NSString stringWithFormat:@"%@°", city.currentHourlyWeather.currentTempC];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_fetchedResults.fetchedResultsController.managedObjectContext deleteObject:[_fetchedResults.fetchedResultsController objectAtIndexPath:indexPath]];
        
        [[MADCoreDataStack sharedCoreDataStack] saveToStorage];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MADCity *city = [_fetchedResults.fetchedResultsController objectAtIndexPath:indexPath];
    MADDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MADDetailViewController"];
    
    detailViewController.city = city;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray
                                                    arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"A table item was moved");
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"A table item was updated");
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
