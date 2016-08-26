//
//  MADFetchedResultsTableViewDataSource.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 26.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADFetchedResultsTableViewDataSource.h"

@interface MADFetchedResultsTableViewDataSource ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) CellForRowAtIndexPathBlock cellForRowAtIndexPathBlock;

@end

@implementation MADFetchedResultsTableViewDataSource

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)controller
                                cellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)cellForRowAtIndexPathBlock {
    self = [super init];
    
    if (self) {
        self.fetchedResultsController = controller;
        self.cellForRowAtIndexPathBlock = cellForRowAtIndexPathBlock;
    }
    
    return self;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchedResultsController.sections[section];
    
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cellForRowAtIndexPathBlock == nil) {
        return nil;
    }
    return _cellForRowAtIndexPathBlock(tableView, indexPath, [_fetchedResultsController objectAtIndexPath:indexPath]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_canEditItemAtIndexPathBlock != nil) {
        return _canEditItemAtIndexPathBlock(tableView, indexPath, [_fetchedResultsController objectAtIndexPath:indexPath]);
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_commitEditingItemBlock != nil) {
        _commitEditingItemBlock(tableView, editingStyle, indexPath, [_fetchedResultsController objectAtIndexPath:indexPath]);
    }
}

@end
