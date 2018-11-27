//
//  SelectCurrencyVC.m
//  Grocery
//
//  Created by Shaw Lu on 1/21/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "SelectCurrencyVC.h"
#import "MGCurrencyExchanger.h"

@interface SelectCurrencyVC ()

@end

@implementation SelectCurrencyVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MGCurrencyExchanger currencyCodes].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [MGCurrencyExchanger currencyCodes][indexPath.row];
    if ([self.selectedCurrency isEqualToString:cell.detailTextLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCurrency = [MGCurrencyExchanger currencyCodes][indexPath.row];
    [self performSegueWithIdentifier:@"unwindtoItemDetail" sender:self];
}

@end
