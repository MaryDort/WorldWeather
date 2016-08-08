//
//  MADLocationSearchTableViewController.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 07.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADLocationSearchTableViewController : UITableViewController <UISearchResultsUpdating>

@property (strong, nonatomic, readwrite) void (^complitionBlock)(NSString *);

@end
