//
//  GroceryManager.m
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "GroceryManager.h"
#import "AppDelegate.h"
#import "Item.h"

@implementation GroceryManager

+ (GroceryManager *) sharedManager {
    static GroceryManager *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GroceryManager alloc] init];
    });
    return sharedEngine;
}

+ (NSURL *)applicationCacheDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (void) logXMLFilePath {
    NSURL *fileURL = [NSURL URLWithString:@"Grocery" relativeToURL:[self XMLDataRecordsDirectory]];
    if (DEVELOPMENT) NSLog(@"%@", [fileURL path]);
}

+ (NSURL *)XMLDataRecordsDirectory{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"XML/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return url;
}

+ (NSMutableArray *)read {
    NSURL *fileURL = [NSURL URLWithString:@"Grocery" relativeToURL:[self XMLDataRecordsDirectory]];
    NSArray *array = [NSMutableArray arrayWithContentsOfURL:fileURL];
    if (array) {
        NSMutableArray *groceryArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            Item *item;
            
            Item *coreDataItem = [Item findByName:item.name time:item.time];
            if (!coreDataItem) {
                NSEntityDescription *entityWorkout = [NSEntityDescription entityForName:@"Item"
                                                                 inManagedObjectContext:[Item managedObjectContext]];
                NSManagedObject *new = [[NSManagedObject alloc] initWithEntity:entityWorkout
                                                insertIntoManagedObjectContext:[Item managedObjectContext]];
                
                // Casting the newly created workout from NSManagedObject class to Workout class.
                item = (Item *)new;
                [item copyFromDict:dict];
                NSLog(@"New managed object is created: %@", item.id);
            }
            [groceryArray addObject: item];
            [Item saveContext];
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:KEY_TIME ascending:NO];
        [groceryArray sortUsingDescriptors:@[sort]];
        NSLog(@"%@", groceryArray);
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
        return groceryArray;
    }
    return nil;
}

+ (void) exportAllItems {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Item *item in [Item allItems]) {
        [array addObject: [item dictionaryRepresentation]];
    }
    NSURL *fileURL = [NSURL URLWithString:@"Grocery" relativeToURL:[self XMLDataRecordsDirectory]];
    [array writeToFile:[fileURL path] atomically:YES];
}

@end
