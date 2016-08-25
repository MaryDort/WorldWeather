//
//  MADCoreDataStack.h
//  MADWorldWeather
//
//  Created by Mariia Cherniuk on 02.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@interface MADCoreDataStack : NSObject

@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedCoreDataStack;

- (void)saveObjects:(NSDictionary *)results;
- (void)updateObjects:(NSDictionary *)results;
- (void)saveToStorage;

@end
