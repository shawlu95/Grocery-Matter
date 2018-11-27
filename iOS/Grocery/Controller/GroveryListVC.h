//
//  ViewController.h
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryManager.h"
#import "SubViewController.h"

@interface GroveryListVC : SubViewController <PushSyncDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) NSCalendarUnit scopeUnit;
@property (nonatomic, strong) NSDate *scope;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *selectedType;
@end

