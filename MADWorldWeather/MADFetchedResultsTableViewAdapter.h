//
//  MADFetchedResultsTableViewAdapter.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 26.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

@import CoreData;
@import UIKit;

@interface MADFetchedResultsTableViewAdapter : NSObject <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic, readwrite) UITableView *tableView;
@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller
                                       tableView:(UITableView *)tableView;

@end
