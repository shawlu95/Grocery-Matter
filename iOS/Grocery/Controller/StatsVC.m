//
//  StatsVC.m
//  Grocery
//
//  Created by Shaw on 8/1/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "StatsVC.h"
#import "Item.h"
#import "GroveryListVC.h"
#import "DateUtilities.h"

@interface StatsVC ()
@property (nonatomic, strong) NSArray *fetchedItems;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDictionary *net;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unitButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) double total;
@end

@implementation StatsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self executeFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated {
    double lov = 0;
    double edu = 0;
    double foo = 0;
    double clo = 0;
    double sar = 0;
    double sho = 0;
    double acc = 0;
    double hyg = 0;
    double boo = 0;
    double sta = 0;
    double pen = 0;
    double fur = 0;
    double ele = 0;
    double com = 0;
    double soc = 0;
    double tra = 0;
    double ent = 0;
    double hou = 0;
    double aut = 0;
    double leg = 0;
    double tax = 0;
    double ins = 0;
    double sof = 0;
    double mis = 0;
    double inv = 0;
    self.total = 0;
    
    for (Item *item in self.fetchedItems) {
        if ([item.type isEqualToString:KEY_LOV]) {
            lov += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_EDU]) {
            edu += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_FOO]) {
            foo += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_CLO]) {
            clo += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_SAR]) {
            sar += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_SHO]) {
            sho += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_ACC]) {
            acc += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_HYG]) {
            hyg += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_BOO]) {
            boo += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_STA]) {
            sta += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_PEN]) {
            pen += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_FUR]) {
            fur += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_ELE]) {
            ele += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_COM]) {
            com += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_SOC]) {
            soc += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_TRA]) {
            tra += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_ENT]) {
            ent += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_HOU]) {
            hou += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_AUT]) {
            aut += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_LEG]) {
            leg += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_TAX]) {
            tax += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_INS]) {
            ins += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_SOF]) {
            sof += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_MIS]) {
            mis += item.totalPriceCNY.doubleValue;
        } else if ([item.type isEqualToString:KEY_INV]) {
            inv += item.totalPriceCNY.doubleValue;
        }
        self.total += item.totalPriceCNY.doubleValue;
    }
    
    self.net = @{
                 KEY_LOV : [NSNumber numberWithFloat:lov],
                 KEY_EDU : [NSNumber numberWithFloat:edu],
                 KEY_FOO : [NSNumber numberWithFloat:foo],
                 KEY_CLO : [NSNumber numberWithFloat:clo],
                 KEY_SAR : [NSNumber numberWithFloat:sar],
                 KEY_SHO : [NSNumber numberWithFloat:sho],
                 KEY_ACC : [NSNumber numberWithFloat:acc],
                 KEY_HYG : [NSNumber numberWithFloat:hyg],
                 KEY_BOO : [NSNumber numberWithFloat:boo],
                 KEY_STA : [NSNumber numberWithFloat:sta],
                 KEY_PEN : [NSNumber numberWithFloat:pen],
                 KEY_FUR : [NSNumber numberWithFloat:fur],
                 KEY_ELE : [NSNumber numberWithFloat:ele],
                 KEY_COM : [NSNumber numberWithFloat:com],
                 KEY_SOC : [NSNumber numberWithFloat:soc],
                 KEY_TRA : [NSNumber numberWithFloat:tra],
                 KEY_ENT : [NSNumber numberWithFloat:ent],
                 KEY_HOU : [NSNumber numberWithFloat:hou],
                 KEY_AUT : [NSNumber numberWithFloat:aut],
                 KEY_LEG : [NSNumber numberWithFloat:leg],
                 KEY_TAX : [NSNumber numberWithFloat:tax],
                 KEY_INS : [NSNumber numberWithFloat:ins],
                 KEY_SOF : [NSNumber numberWithFloat:sof],
                 KEY_MIS : [NSNumber numberWithFloat:mis],
                 KEY_INV : [NSNumber numberWithFloat:inv],
                 };
    
    [self.tableView reloadData];
}

- (NSArray *)fetchedItems {
    if (!_fetchedItems) {
        _fetchedItems = [_fetchedResultsController fetchedObjects];
    }
    return _fetchedItems;
}

-(void) executeFetchedResultsController {
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch: &error]) {
        NSLog(@"Error! %@", error);
        abort();
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
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", KEY_TIME, self.startDate, KEY_TIME, self.endDate];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TIME ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [Item typeArr].count;
            break;
            
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = [[Item localizedTypes] objectForKey:[Item typeArr][indexPath.row]];
            NSNumber *sum =  [self.net objectForKey:[Item typeArr][indexPath.row]];
            double sumDouble = sum.doubleValue;
            if (sumDouble == 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"-"];
            } else {
                if ([self.unitButton.title isEqualToString:@"¥"]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.3f %%", 100*sumDouble/self.total];
                } else if ([self.unitButton.title isEqualToString:@"%"]) {
                    cell.detailTextLabel.text = [[Item chineseFormatter] stringFromNumber:[NSNumber numberWithFloat:sumDouble]];
                }
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1: {
            
            NSNumber *total = [NSNumber numberWithFloat:self.total];
            cell.textLabel.text = TOTAL_CELL_TITLE;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[Item chineseFormatter] stringFromNumber:total]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"toAll" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toAll"]) {
        GroveryListVC *dsvc = segue.destinationViewController;
        dsvc.startDate = self.startDate;
        dsvc.endDate = self.endDate;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        dsvc.selectedType = [Item typeArr][indexPath.row];
    }
}

- (IBAction)didFlipUnit:(id)sender {
    if ([self.unitButton.title isEqualToString:@"%"]) {
        self.unitButton.title = @"¥";
    } else {
        self.unitButton.title = @"%";
    }
    [self.tableView reloadData];
}

// Developer's Log
//- [x] Create database structure
//* Food(FOO)
//* Hygiene (HYG)
//* Book (BOO)
//* Furniture (FUR)
//* Communication (COM)
//* Transportation (TRA)
//* Entertainment (ENT)
//* Housing (HOU)
//* Auto (AUT)
//* Miscellany (MIS)
//- [x] create table view for selections
//- [x] Update save function
//- [x] Create localized string
//- [x] Create tableview selecting start and end date
//- [x] Create table view for summary
//- [x] create function calculating percentage
//- [x] Display calculation results

@end
