//
//  AccountVC.m
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "AccountVC.h"
#import "TextFieldCell.h"
#import "Macros.h"
#import "JNKeychain.h"
#import "Item.h"

@interface AccountVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTabBarItem];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.tableView reloadData];
}

- (void) configureTabBarItem {
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:3];
    UIImage* selectedImage = [[UIImage imageNamed:@"accountFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    tabBarItem0.selectedImage = selectedImage;
}

- (BOOL) didLogIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_DID_LOG_IN];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (![self didLogIn]) {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (![self didLogIn]) {
            return 1;
        }
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = USER_ID_CELL_TITLE;
            if (![self didLogIn]) {
                cell.textField.text = NO_ACCOUNT;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.trailing.constant = 12;
            } else {
                cell.textField.text = [JNKeychain loadValueForKey:KEY_CACHED_USER_ID];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.trailing.constant = -8;
            }
        } else if (indexPath.row == 1) {
            cell.titleLabel.text = CHANGE_PASSWORD_CELL_TITLE;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 2) {
            cell.titleLabel.text = STATS;
            cell.textField.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"IP";
            cell.textField.text = ServerIP;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.trailing.constant = -8;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            return cell;
        }
    } else {
        cell.titleLabel.text = LOGOUT_CELL_TITLE;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textField.userInteractionEnabled = NO;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (![self didLogIn]) [self performSegueWithIdentifier:@"LoginVC" sender:self];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"PasswordVC" sender:self];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [self performSegueWithIdentifier:@"RangeVC" sender:self];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"IPVC" sender:self];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self didLogout];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) didLogout {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"logout" data:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_DID_LOG_IN];
    
    [Item clears];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (IBAction)didChangeReserve:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
            NSLog(@"CNY");
            [[NSUserDefaults standardUserDefaults] setObject:@"CNY" forKey:@"Reserve"];
            break;
        }
        case 1: {
            NSLog(@"USD");
            [[NSUserDefaults standardUserDefaults] setObject:@"USD" forKey:@"Reserve"];
            break;
        }
        default:
                break;
    }
}

#pragma mark - Navigation
- (IBAction)unwindtoAccount:(UIStoryboardSegue *)unwindSegue{
    [self.tableView reloadData];
}

#pragma mark Device Orientation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate {
    return NO;
}

@end
