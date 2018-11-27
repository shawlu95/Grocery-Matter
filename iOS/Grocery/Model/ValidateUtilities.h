//
//  ValidateUtilities.h
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidateUtilities : NSObject
+ (BOOL) isPasswordValid: (NSString *) password;
+ (BOOL) isPasswordLengthValid: (NSString *) password;
+ (BOOL) isUsernameValid: (NSString *) userID;
+ (BOOL) isUsernameLengthValid:(NSString *)userID;
@end
