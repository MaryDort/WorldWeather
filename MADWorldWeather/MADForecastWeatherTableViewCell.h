//
//  MADForecastWeatherTableViewCell.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 05.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADForecastWeatherTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;

@end
