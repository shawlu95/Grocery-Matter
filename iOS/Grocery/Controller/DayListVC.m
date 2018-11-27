//
//  DayListVC.m
//  Grocery
//
//  Created by Xiao on 7/14/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "Item.h"
#import "ItemDetailVC.h"
#import "DayListVC.h"
#import "GroceryCell.h"
#import "Macros.h"
#import "GroveryListVC.h"

@implementation DayListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTabBarItem];
}

- (NSMutableDictionary *)dataSource {
    if (!_dataSource) {
        if (self.selectedMon) {
            _dataSource = [Item allItemsSortedByDayInMon:self.selectedMon];
        } else {
            _dataSource = [Item allItemsSortedByDay];
        }
    }
    return _dataSource;
}

- (void)viewWillAppear:(BOOL)animated {
    [self makeTabBarHidden:NO];
    [self.dayListTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self makeTabBarHidden:NO];
    self.dataSource = nil;
    [self.dayListTableView reloadData];
}

- (void)makeTabBarHidden:(BOOL)hide {
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
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:1];
    UIImage* selectedImage = [[UIImage imageNamed:@"dayFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    tabBarItem0.selectedImage = selectedImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroceryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *dateLabel = [self sortedKeys][indexPath.row];
    cell.titleLabel.text = dateLabel;
    NSMutableArray *arr = [self.dataSource objectForKey:dateLabel];
    float expense = 0;
    for (Item *item in arr) {
        expense += item.totalPriceCNY.floatValue;
    }
    cell.dateLabel.text = [[Item chineseFormatter] stringFromNumber:[NSNumber numberWithFloat:expense]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dateLabel = [self sortedKeys][indexPath.row];
    self.selectedDay = dateLabel;
    [self performSegueWithIdentifier:TO_CHECK_DAY_SEUGUE sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *) sortedKeys {
    NSMutableDictionary *dict = [self dataSource];
    NSArray *sortedKey = [dict.allKeys  sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
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
//        NSArray *items = [self dataSource][dateLabel];
//        for (Item *item in items) {
//            [[Item managedObjectContext] deleteObject:item];
//        }
//        [Item saveContext];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        
//        if ([NetworkUtilities reachableViaWiFi]) {
//            [[NetworkUtilities sharedEngine] postAPIwithCommand:@"sync" data:[[Item serverDump] mutableCopy]];
//        }
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:TO_CHECK_DAY_SEUGUE]) {
        GroveryListVC *dsvc = segue.destinationViewController;
        dsvc.scopeUnit = NSCalendarUnitDay;
        NSMutableArray *arr = self.dataSource[self.selectedDay];
        Item *item = arr[0];
        dsvc.scope = item.time;
        dsvc.title = self.selectedDay;
    } else if ([segue.identifier isEqualToString:TO_ADD_ITEM_SEGUE]) {
        ItemDetailVC *dsvc = segue.destinationViewController;
        dsvc.editingState = CREATE;
        dsvc.groceryItem = nil;
        [self makeTabBarHidden:YES];
    }
}

- (IBAction)unwindtoDayList:(UIStoryboardSegue *)unwindSegue{
}

@end
