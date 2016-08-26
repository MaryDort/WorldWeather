//
//  MADArrayTabelViewDataSource.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 26.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADArrayTableViewDataSource.h"

@interface MADArrayTableViewDataSource ()

@property (nonatomic, readwrite, strong) NSArray *objects;
@property (nonatomic, copy) CellForRowAtIndexPathBlock cellForRowAtIndexPathBlock;

@end

@implementation MADArrayTableViewDataSource

- (instancetype)initWithObjects:(NSArray *)objects cellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)cellForRowAtIndexPathBlock {
    self = [super init];
    
    if (self) {
        self.objects = objects;
        self.cellForRowAtIndexPathBlock = cellForRowAtIndexPathBlock;
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cellForRowAtIndexPathBlock == nil) {
        return nil;
    }
    return _cellForRowAtIndexPathBlock(tableView, indexPath, _objects[indexPath.row]);
}

@end
