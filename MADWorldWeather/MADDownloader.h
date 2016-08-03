//
//  MADAPIDownloader.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADDownloader : NSObject

+ (instancetype)sharedAPIDownloader;

- (void)downloadDataWithCallBack:(void (^)(NSArray *results))callBack;
- (void)downloadDataWithURL:(NSString *)url callBack:(void (^)(NSData *imageData))callBack;

@end
