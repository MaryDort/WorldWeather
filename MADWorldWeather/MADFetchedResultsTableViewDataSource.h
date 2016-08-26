//
//  MADFetchedResultsTableViewDataSource.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 26.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

@import CoreData;
@import UIKit;

typedef UITableViewCell* (^CellForRowAtIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath, id object);
typedef BOOL (^CanEditItem)(UITableView *tableView, NSIndexPath *indexPath, id object);
typedef void (^CommitEditingItem)(UITableView *tableView, UITableViewCellEditingStyle editingStyle,NSIndexPath *indexPath, id object);

@interface MADFetchedResultsTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) CanEditItem canEditItemAtIndexPathBlock;
@property (nonatomic, copy) CommitEditingItem commitEditingItemBlock;

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller
                                cellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)cellForRowAtIndexPathBlock;

@end
