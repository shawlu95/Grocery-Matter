//
//  ValidateUtilities.m
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "ValidateUtilities.h"
#import "Macros.h"

@implementation ValidateUtilities
+ (BOOL) isPasswordValid: (NSString *) password {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
    set = [set invertedSet];
    NSRange r = [password rangeOfCharacterFromSet:set];
    if (r.location != NSNotFound) {
        if (DEVELOPMENT) NSLog(@"the password string contains illegal characters");
        return NO;
    }
    return YES;
}

+ (BOOL) isPasswordLengthValid: (NSString *) password {
    if (password.length > 20 || password.length < 8) {
        return NO;
    }
    return YES;
}

+ (BOOL) isUsernameValid: (NSString *) userID {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890"];
    set = [set invertedSet];
    NSRange r = [userID rangeOfCharacterFromSet:set];
    if (r.location != NSNotFound) {
        if (DEVELOPMENT) NSLog(@"the user_id string contains illegal characters");
        return NO;
    }
    return YES;
}

+ (BOOL)isUsernameLengthValid:(NSString *)userID {
    if (userID.length < 5 || userID.length > 20) {
        return NO;
    }
    return YES;
}

@end
