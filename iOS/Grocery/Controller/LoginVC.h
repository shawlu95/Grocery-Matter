//
//  LoginVC.h
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkUtilities.h"
#import "SubViewController.h"

@interface LoginVC : SubViewController <UITableViewDataSource, UITableViewDelegate, LoginDelegate, UITextFieldDelegate>

@end
