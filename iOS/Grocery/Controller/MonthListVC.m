//
//  MonthListVC.m
//  Grocery
//
//  Created by Xiao on 7/14/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "Item.h"
#import "ItemDetailVC.h"
#import "MonthListVC.h"
#import "DateUtilities.h"
#import "GroceryCell.h"
#import "DayListVC.h"
#import "Macros.h"

@implementation MonthListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTabBarItem];
}

- (NSMutableDictionary *)dataSource {
    if (!_dataSource) {
        _dataSource = [Item allItemsSortedByMon];
    }
    return _dataSource;
}

- (void)viewWillAppear:(BOOL)animated {
    [self makeTabBarHidden:NO];
    self.dataSource = nil;
    [self.monthListTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self makeTabBarHidden:NO];
}

- (void) makeTabBarHidden:(BOOL)hide {
    if ( [self.tabBarController.view.subviews count] < 2 ) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] ) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    if (hide) {
        contentView.frame = self.tabBarController.view.bounds;
    } else {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
    self.tabBarController.tabBar.hidden = hide;
}

- (void) configureTabBarItem {
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:2];
    UIImage* selectedImage = [[UIImage imageNamed:@"monFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    tabBarItem0.selectedImage = selectedImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroceryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.titleLabel.text = [self sortedKeys][indexPath.row];
    NSMutableArray *mon = [self.dataSource objectForKey:cell.titleLabel.text];
    float expense = 0;
    for (Item *item in mon) {
        expense += item.totalPriceCNY.floatValue;
    }
    cell.dateLabel.text = [[Item chineseFormatter] stringFromNumber: [NSNumber numberWithFloat:expense]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedMonthKey = [self sortedKeys][indexPath.row];
    Item *item = self.dataSource[selectedMonthKey][0];
    self.selectedMon = item.time;
    [self performSegueWithIdentifier:TO_CHECK_MONTH_SEUGUE sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *) sortedKeys {
    NSArray *sortedKey = [self.dataSource.allKeys  sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        if ([a compare:b] == NSOrderedAscending) {
            return NSOrderedDescending;
        } else if ([a compare:b] == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    return sortedKey;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSString *dateLabel = [self sortedKeys][indexPath.row];
//        NSMutableArray *mon = [self.dataSource objectForKey:dateLabel];
//        for (Item *item in mon) {
//            [[Item managedObjectContext] deleteObject:item];
//        }
//        [Item saveContext];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TO_CHECK_MONTH_SEUGUE]) {
        DayListVC *dsvc = segue.destinationViewController;
        dsvc.scopeUnit = NSCalendarUnitMonth;
        dsvc.selectedMon = self.selectedMon;
        dsvc.title = [DateUtilities monStringForDate:self.selectedMon];
    }
}

@end
