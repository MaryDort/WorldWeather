//
//  MADAPIDownloader.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADDownloader : NSObject

+ (instancetype)sharedDownloader;

- (void)downloadDataWithLocationName:(NSString *)locationName days:(NSNumber *)days callBack:(void (^)(NSDictionary *results))callBack;
- (void)downloadDataWithURL:(NSString *)url callBack:(void (^)(NSData *imageData))callBack;

@end
