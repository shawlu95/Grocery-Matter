//
//  AppDelegate.m
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"
#import "Macros.h"
#import "MGCurrencyExchanger.h"
#import "NetworkUtilities.h"
#import "Reachability.h"
#import "JNKeychain.h"
#import "GroceryManager.h"
@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (DEVELOPMENT) {
        NSLog(@"%@", ServerApiURL);
        [GroceryManager logXMLFilePath];
        [GroceryManager exportAllItems];
    }
    if (![JNKeychain loadValueForKey:KEY_CACHED_IP]) {
        [JNKeychain saveValue:@"192.168.0.104" forKey:KEY_CACHED_IP];
    }
    if (TESTAPI) {
        NSError *error;
        NSLocale *chinaLocale = [NSLocale localeFromCountryName:MGCountryChina];
        NSLocale *currencyLocale = [NSLocale localeFromCountryName:[MGCurrencyExchanger countryNameForCurrency:@"USD"]];
        double d = [MGCurrencyExchanger exchangeAmountOnline:1 fromCurrency:currencyLocale toCurrency:chinaLocale withError: &error];
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"enter" data:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"exit" data:nil];
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Grocery" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                            nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FitData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.absoluteString error:&error];
        
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) return _managedObjectContext;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) return nil;
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        }
    }
}

@end
