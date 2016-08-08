//
//  MADDescriptionTableViewCell.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 03.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADHourlyWeatherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end
