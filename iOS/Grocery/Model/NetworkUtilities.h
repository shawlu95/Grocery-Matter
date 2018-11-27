//
//  NetworkUtilities.h
//  Grocery
//
//  Created by Xiao on 8/4/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import <UIKit/UIKit.h>

@protocol LoginDelegate <NSObject>
- (void) userExists;
- (void) didSignup;
- (void) didLogin;
- (void) wrongPassword;
- (void) userNotExists;
- (void) sessionFailed;
@end

@protocol PasswordDelegate <NSObject>
- (void) didChangePassword;
- (void) sessionFailed;
@end

@protocol PushSyncDelegate <NSObject>
- (void) didFinishPushing;
@end

@interface NetworkUtilities : NSObject <NSURLSessionDelegate>
@property (nonatomic, weak) id<LoginDelegate> loginDelegate;
@property (nonatomic, weak) id<PasswordDelegate> passwordDelegate;
@property (nonatomic, weak) id<PushSyncDelegate> pushSyncDelegate;
+ (BOOL) notReachable;
+ (BOOL) reachableViaWiFi;
+ (BOOL) ReachableViaWWAN;
+ (NetworkUtilities *)sharedEngine;
- (void) postAPIwithCommand: (NSString*) cmd data: (NSMutableDictionary*) data;
@end
