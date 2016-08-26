//
//  MADArrayTabelViewDataSource.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 26.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

@import UIKit;

typedef UITableViewCell* (^CellForRowAtIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath, id object);

@interface MADArrayTableViewDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithObjects:(NSArray *)objects cellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)cellForRowAtIndexPathBlock;

@end
