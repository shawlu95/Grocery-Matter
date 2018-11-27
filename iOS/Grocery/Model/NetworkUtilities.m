//
//  NetworkUtilities.m
//  Grocery
//
//  Created by Xiao on 8/4/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "ALToastView.h"
#import "AppDelegate.h"
#import "NetworkUtilities.h"
#import "Macros.h"
#import "Item.h"
#import "JNKeychain.h"
#import "DateUtilities.h"
#import "Reachability.h"

@interface NetworkUtilities ()
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation NetworkUtilities

+ (BOOL)notReachable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    return status == NotReachable;
}

+ (BOOL)reachableViaWiFi {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    return status == ReachableViaWiFi;
}

+ (BOOL)ReachableViaWWAN {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    return status == ReachableViaWWAN;
}

+ (NetworkUtilities *)sharedEngine {
    static NetworkUtilities *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[NetworkUtilities alloc] init];
    });
    return sharedEngine;
}

- (void) postAPIwithCommand: (NSString*) cmd data: (NSMutableDictionary*) data {
    self.data = nil;
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    data ? [post setObject:data forKey:@"data"] : [post setObject:@{} forKey:@"data"];
    [post setObject:cmd forKey:@"cmd"];
    
    if ([JNKeychain loadValueForKey:KEY_CACHED_PASSWORD] && [JNKeychain loadValueForKey:KEY_CACHED_USER_ID]) {
        [post setObject:[JNKeychain loadValueForKey:KEY_CACHED_USER_ID] forKey:@"userID"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:KEY_INSTALLATION_ID]) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey: KEY_INSTALLATION_ID];
    }
    [post setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_INSTALLATION_ID] forKey:KEY_INSTALLATION_ID];
    
    NSError *error = nil;
     if (DEVELOPMENT) NSLog(@"Will send HTTP request: %@", post);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:ServerApiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:15];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if (!theConnection){
        NSLog(@"Connection Failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)response {
    if (DEVELOPMENT) {
        NSString * DataResult = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"Raw Response from server with size: %@", DataResult);
    }
    
    if (!self.data) self.data = [[NSMutableData alloc] init];
    [self.data appendData:response];
    
    NSError* localError;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&localError];
    
    if (json) {
        NSInteger err = -1;
        if (json[@"err"]) {
            err = [json[@"err"] integerValue];
        }
        self.data = nil;
        NSString *cmd = json[@"cmd"];
        if ([cmd isEqualToString:@"signup"]) {
            if (err == 0) {
                [self.loginDelegate didSignup];
                [Item clears];
                NSArray *items = json[@"data"];
                [self syncCoreData:items];
            } else if (err == 1) {
                [self.loginDelegate userExists];
            }
        } else if ([cmd isEqualToString:@"login"]) {
            if (err == 0) {
                NSArray *items = json[@"data"];
                [Item clears];
                [self syncCoreData:items];
                [self.loginDelegate didLogin];
            } else if (err == 1) {
                [self.loginDelegate wrongPassword];
            } else if (err == 2) {
                [self.loginDelegate userNotExists];
            }
        } else if ([cmd isEqualToString:@"cPass"]) {
            [self.passwordDelegate didChangePassword];
        } else if ([cmd isEqualToString:@"sync"]) {
            NSArray *items = json[@"data"];
            [self syncCoreData:items];
            if ([self.pushSyncDelegate respondsToSelector:@selector(didFinishPushing)]) {
                [self.pushSyncDelegate didFinishPushing];
            }
        } else if ([cmd isEqualToString:@"create"]) {
            NSArray *items = json[@"data"];
            Item *item = [Item findByID:[NSNumber numberWithInt:0]];
            [[Item managedObjectContext] deleteObject:item];
            [self syncCoreData:items];
        }
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [ALToastView toastInView:app.window withText:@"OK"];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.loginDelegate respondsToSelector:@selector(sessionFailed)]) {
        [self.loginDelegate sessionFailed];
    }
    
    if ([self.passwordDelegate respondsToSelector:@selector(sessionFailed)]) {
        [self.passwordDelegate sessionFailed];
    }
}

- (void) syncCoreData: (NSArray*) items {
    if (items) {
        for (NSDictionary *dict in items) {
            NSNumber *index = [NSNumber numberWithInteger:[dict[KEY_ID] integerValue]];
            Item *item = [Item findByID:index];
            if (dict[@"deleted"]) {
                NSNumber *deleted = [NSNumber numberWithInteger:[dict[@"deleted"] integerValue]];
                if (item && deleted.integerValue == 1) {
                    [[Item managedObjectContext] deleteObject:item];
                } else if ( item && deleted.integerValue == 0){
                    [item updateFromServer:dict];
                } else if ( !item && deleted.integerValue == 0){
                    NSEntityDescription *entityWorkout = [NSEntityDescription entityForName:@"Item"
                                                                     inManagedObjectContext:[Item managedObjectContext]];
                    NSManagedObject *new = [[NSManagedObject alloc] initWithEntity:entityWorkout
                                                    insertIntoManagedObjectContext:[Item managedObjectContext]];
                    item = (Item *)new;
                    [item updateFromServer:dict];
                }
            }
        }
    }
    [Item saveContext];
}

@end
