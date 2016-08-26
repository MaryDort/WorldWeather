//
//  MADLocationsMenuTableViewCell.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 07.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADLocationsMenuTableViewCell.h"

@implementation MADLocationsMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *backgroundView = [[UIView alloc] init];
    
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.4];
    
    self.selectedBackgroundView = backgroundView;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
