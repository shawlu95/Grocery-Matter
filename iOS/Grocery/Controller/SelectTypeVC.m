//
//  SelectTypeVC.m
//  Grocery
//
//  Created by Shaw on 8/1/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "SelectTypeVC.h"
#import "Item.h"

@interface SelectTypeVC ()

@end

@implementation SelectTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Item typeArr].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [[Item localizedTypes] objectForKey:[Item typeArr][indexPath.row]];
    if ([self.selectedType isEqualToString:cell.detailTextLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedType = [Item typeArr][indexPath.row];
    [self performSegueWithIdentifier:@"unwindtoItemDetail" sender:self];
}


@end
