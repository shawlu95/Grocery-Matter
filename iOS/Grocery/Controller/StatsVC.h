//
//  StatsVC.h
//  Grocery
//
//  Created by Shaw on 8/1/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryManager.h"
#import "SubViewController.h"

@interface StatsVC : SubViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@end
