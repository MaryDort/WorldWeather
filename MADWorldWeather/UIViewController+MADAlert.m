//
//  UIViewController+MADAlert.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 25.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "UIViewController+MADAlert.h"

@implementation UIViewController (MADAlert)

- (void)showFailedAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
