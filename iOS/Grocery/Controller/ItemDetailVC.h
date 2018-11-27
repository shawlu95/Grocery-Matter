//
//  ItemDetailVC.h
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

typedef NS_ENUM(NSInteger, EditingState) {
    CREATE,
    UPDATE
};

#import <UIKit/UIKit.h>
#import "Item.h"
#import "SubViewController.h"

@interface ItemDetailVC : SubViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) Item *groceryItem;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSString *unwindSegue;
@property (nonatomic, assign) EditingState editingState;
@end
