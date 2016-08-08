//
//  MADLocationsMenuTableViewCell.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 07.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADLocationsMenuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;

@end
