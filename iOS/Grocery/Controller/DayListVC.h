//
//  DayListVC.h
//  Grocery
//
//  Created by Xiao on 7/14/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryManager.h"
#import "SubViewController.h"
@interface DayListVC : SubViewController  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dayListTableView;
@property (nonatomic, assign) NSCalendarUnit scopeUnit;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *selectedDay;
@property (nonatomic, strong) NSDate *selectedMon;
@property (nonatomic, strong) NSMutableDictionary *dataSource;
@end
