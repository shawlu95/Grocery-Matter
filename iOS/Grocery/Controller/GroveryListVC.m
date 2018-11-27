//
//  ViewController.m
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "Macros.h"
#import "DateUtilities.h"
#import "GroveryListVC.h"
#import "ItemDetailVC.h"
#import "GroceryCell.h"
#import "JNKeychain.h"
#import "MBProgressHUD.h"
#import "Item.h"

@interface GroveryListVC ()
@property (weak, nonatomic) IBOutlet UITableView *groceryListTableView;
@property (nonatomic, strong) Item *selectedGroceryItem;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, strong) NSMutableArray *filteredContentList;
@property (nonatomic, strong) NSArray *fetchedObjects;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, assign) BOOL shouldScroll;
@end

@implementation GroveryListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTabBarItem];
    [NetworkUtilities sharedEngine].pushSyncDelegate = self;
    [self configureSearchController];
    if ([JNKeychain loadValueForKey:KEY_CACHED_USER_ID]) {
        self.navigationItem.title = [JNKeychain loadValueForKey:KEY_CACHED_USER_ID];
    }
    self.shouldScroll = YES;
}

-(void)dealloc {
    [self.searchController.view removeFromSuperview]; // It works!
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.fetchedResultsController = nil;
    [self executeFetchedResultsController];
    [self.groceryListTableView reloadData];
    if (self.shouldScroll) {
        [self scrollToCurrentTime];
        self.shouldScroll = NO;
    }
}

- (void) scrollToCurrentTime {
    if (self.fetchedObjects.count > 0) {
        
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDate *now = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
        
        int row = 0;
        for (Item *item in self.fetchedObjects) {
            if ([item.time compare:now] == NSOrderedAscending) {
                break;
            }
            row = row + 1;
        }
        if (row < [self.groceryListTableView numberOfRowsInSection:0]) {
            [self.groceryListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self makeTabBarHidden:NO];
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
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:0];
    UIImage* selectedImage = [[UIImage imageNamed:@"allFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    tabBarItem0.selectedImage = selectedImage;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.filteredContentList.count;
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroceryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Item *item;
    if (self.searchController.active) {
        item = (Item *) [self.filteredContentList objectAtIndex:indexPath.row];
    } else {
        item = (Item *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.titleLabel.text = item.name;
    NSString *locKey = LOCALIZED_NUM_ITEMS_TIMES_PRICE_EQUAL_NET;
    cell.detailLabel.text = [NSString stringWithFormat:locKey, item.count, [self.currencyFormatter stringFromNumber:item.price], item.currency, [self.currencyFormatter stringFromNumber:item.totalPriceCNY]];
    
    if (item.id.integerValue == 0) {
        cell.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    } else {
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    if (item.time) cell.dateLabel.text = [self.formatter stringFromDate:item.time];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item;
    if (self.searchController.active) {
        item = (Item *) [self.filteredContentList objectAtIndex:indexPath.row];
    } else {
        item = (Item *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    self.selectedGroceryItem = item;
    [self performSegueWithIdentifier:TO_UPDATE_ITEM_SEGUE sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *item;
        if (self.searchController.active) {
            item = (Item *) [self.filteredContentList objectAtIndex:indexPath.row];
        } else {
            item = (Item *) [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        [item serverDelete];
        [[Item managedObjectContext] deleteObject:item];
        [Item saveContext];
    }
}

- (NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [Item managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (self.scope) {
        NSDate *start = [DateUtilities startOfDay:self.scope];
        NSDate *endDate = [DateUtilities endOfDay:self.scope];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", KEY_TIME, start, KEY_TIME, endDate];
        [fetchRequest setPredicate:predicate];
    } else if (self.startDate && self.endDate && self.selectedType) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@) AND type = %@", KEY_TIME, self.startDate, KEY_TIME, self.endDate, self.selectedType];
        [fetchRequest setPredicate:predicate];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TIME ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    self.fetchedObjects = results;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

-(void) executeFetchedResultsController {
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch: &error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
}

#pragma mark Fetched Results Controller delegate
- (void) controllerWillChangeContent:(nonnull NSFetchedResultsController *)controller {
    [self.groceryListTableView beginUpdates];
}

- (void) controllerDidChangeContent:(nonnull NSFetchedResultsController *)controller {
    [self.groceryListTableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.groceryListTableView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeUpdate: {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

#pragma mark - UpdateGroceryDelegate
- (void)dismissUpdateItemVC {
    [self.groceryListTableView deselectRowAtIndexPath:[self.groceryListTableView indexPathForSelectedRow] animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UpdateGroceryDelegate
- (void)didFinishPushing {
    for (Item *item in self.fetchedObjects) {
        if (item.id.integerValue == 0) {
            if (DEVELOPMENT) NSLog(@"Will delete object %@", item.name);
            [[Item managedObjectContext] deleteObject:item];
        }
    }
    [self.HUD hideAnimated:YES];
}

#pragma mark - Utilities
- (NSDateFormatter *)formatter {
    if (_formatter) {
        return _formatter;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MM/dd" options:0 locale:[NSLocale currentLocale]];
    formatter.dateFormat = format;
    _formatter = formatter;
    return _formatter;
}

- (NSNumberFormatter *)currencyFormatter {
    if (_currencyFormatter) {
        return _currencyFormatter;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencySymbol:@""];
    _currencyFormatter = formatter;
    return _currencyFormatter;
}
- (IBAction)didTapAdd:(id)sender {
    [self performSegueWithIdentifier:TO_ADD_ITEM_SEGUE sender:self];
}

- (IBAction)didTapPush:(id)sender {
    [self.HUD showAnimated:YES];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Item *item in [self.fetchedResultsController fetchedObjects]) {
        [array addObject: [item JSONdictionaryRepresentation]];
    }
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"sync" data:array];
}

- (IBAction)didTapPull:(id)sender {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"login" data:[@{KEY_USER_ID : [JNKeychain loadValueForKey:KEY_CACHED_USER_ID],
                                                                         KEY_PASSWORD : [JNKeychain loadValueForKey:KEY_CACHED_PASSWORD],
                                                                         @"items"   : [Item serverDump]} mutableCopy]];
}

#pragma mark - UISearchResultsUpdating
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self.filteredContentList removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", searchString];
    NSArray *tempArray = [self.fetchedObjects filteredArrayUsingPredicate:predicate];
    self.filteredContentList = [NSMutableArray arrayWithArray:tempArray];
    [self.groceryListTableView reloadData];
}

- (void) configureSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.showsCancelButton = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    
    self.definesPresentationContext = YES;
    [self.groceryListTableView setContentOffset:CGPointMake(0, self.searchController.searchBar.frame.size.height)];
    
    if ([self.navigationItem respondsToSelector:@selector(setSearchController:)]) {
        // For iOS 11 and later, we place the search bar in the navigation bar.
        self.navigationItem.searchController = self.searchController;
        
        // We want the search bar visible all the time.
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        // For iOS 10 and earlier, we place the search bar in the table view's header.
        self.groceryListTableView.tableHeaderView = self.searchController.searchBar;
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
}

- (void) configureHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.bezelView.backgroundColor = [UIColor blackColor];
    self.HUD.label.textColor = [UIColor whiteColor];
    self.HUD.contentColor = [UIColor whiteColor];
    self.HUD.detailsLabel.textColor = [UIColor whiteColor];
}

#pragma mark - Navigation
- (IBAction)unwindtoGroceryList:(UIStoryboardSegue *)unwindSegue{
//    [self viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemDetailVC *dsvc = segue.destinationViewController;
    dsvc.unwindSegue = @"unwindtoGroceryList";
    [self makeTabBarHidden:YES];
    if ([segue.identifier isEqualToString:TO_UPDATE_ITEM_SEGUE]) {
        dsvc.groceryItem = self.selectedGroceryItem;
        dsvc.editingState = UPDATE;
    } else if ([segue.identifier isEqualToString:TO_ADD_ITEM_SEGUE]) {
        dsvc.editingState = CREATE;
        dsvc.groceryItem = nil;
        self.selectedGroceryItem = nil;
    }
}

@end
