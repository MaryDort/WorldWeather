//
//  MADLocationSearchTableViewController.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 07.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADLocationSearchTableViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MADLocationSearchTableViewController () 

@property (strong, nonatomic, readwrite) CLPlacemark *placemark;
@property (strong, nonatomic, readwrite) CLGeocoder *geocoder;
@property (strong, nonatomic, readwrite) NSArray *locations;

@end

@implementation MADLocationSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    _geocoder = [[CLGeocoder alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    _placemark = _locations[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", _placemark.addressDictionary[@"City"], _placemark.addressDictionary[@"Country"]];

    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
         _complitionBlock([[_locations objectAtIndex:indexPath.row] name]);
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [_geocoder cancelGeocode];
    [_geocoder geocodeAddressString:searchController.searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [error description]);
        } else {
            _locations = placemarks;
            
            [self.tableView reloadData];
        }
    }];
}

@end
