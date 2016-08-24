//
//  MADAPIDownloader.m
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADDownloader.h"

@implementation MADDownloader

+ (instancetype)sharedDownloader {
    static MADDownloader *_APIDownloader = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _APIDownloader = [[MADDownloader alloc] init];
    });
    
    return _APIDownloader;
}

- (NSString *)preparePlaceForWork:(NSString *)place {
    NSRange range = [place rangeOfString:@","];

    if (range.location != NSNotFound) {
        place = [place substringToIndex:range.location];
    }
    
    NSMutableString *result = [NSMutableString stringWithString:place];
    if ([place containsString:@" "]) {
        NSRange range = [place rangeOfString:@" "];
        
        result = [NSMutableString stringWithString:[place substringToIndex:range.location]];
        [result appendString:[place substringFromIndex:range.location+1]];
    }
    
    return result;
}

- (void)downloadDataWithLocationName:(NSString *)locationName days:(NSNumber *)days callBack:(void (^)(NSDictionary *results))callBack {
    NSString *srtURL = [NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/weather.ashx?key=eb8899f2e04349c298291316160208&q=%@&format=json&num_of_days=%@", [self preparePlaceForWork:locationName], days];
    [self loadDataWithURL:srtURL callBack:^(NSData *data) {
        //        Check for JSON error
        NSError *JSONerror;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&JSONerror];
        
        if (JSONerror) {
            NSLog(@"Error: Couldn't parse response: %@", JSONerror);
        }
        callBack(results);
    }];
}

- (void)downloadDataWithURL:(NSString *)url callBack:(void (^)(NSData *imageData))callBack {
    [self loadDataWithURL:url callBack:^(NSData *data) {
        callBack(data);
    }];
}

- (void)loadDataWithURL:(NSString *)url callBack:(void (^)(NSData *results))callBack {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse *response, NSError *error) {
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

        if (error) {
            //        Check for network error
            NSLog(@"Error: Couldn't finish request: %@", error);
        } else if (statusCode < 200 || statusCode >= 300) {
            //        Check for HTTP error
            NSLog(@"Error: Got stutus code %ld", (long)statusCode);
        } else if (data == nil) {
            //        Check for data == nil error
            NSLog(@"Error: Data is nil");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack(data);
        });
    }];
    [dataTask resume];
}

@end
