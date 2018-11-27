//
//  RangeVC.h
//  Grocery
//
//  Created by Shaw on 8/1/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewController.h"

@interface RangeVC : SubViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@end
