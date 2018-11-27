//
//  LoginVC.m
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "LoginVC.h"
#import "TextFieldCell.h"
#import "Macros.h"
#import "JNKeychain.h"
#import "ValidateUtilities.h"
#import "MBProgressHUD.h"
#import "Item.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) TextFieldCell *userIDCell;
@property (nonatomic, weak) TextFieldCell *passwordCell;
@property (nonatomic, weak) TextFieldCell *ipCell;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [NetworkUtilities sharedEngine].loginDelegate = self;
    if (!DEVELOPMENT) [self configureHUD];
}

- (void) configureHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    self.HUD.bezelView.backgroundColor = [UIColor blackColor];
    self.HUD.label.textColor = [UIColor whiteColor];
    self.HUD.contentColor = [UIColor whiteColor];
    self.HUD.detailsLabel.textColor = [UIColor whiteColor];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:YES];
//    if ([JNKeychain loadValueForKey:KEY_CACHED_USER_ID]) {
//        [self.passwordCell.textField becomeFirstResponder];
//    } else {
//        [self.userIDCell.textField becomeFirstResponder];
//    }
//}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textField.placeholder = USER_ID_CELL_TITLE;
            if ([JNKeychain loadValueForKey:KEY_CACHED_USER_ID]) {
                cell.textField.text = [JNKeychain loadValueForKey:KEY_CACHED_USER_ID];
            }
        } else if (indexPath.row == 1) {
            cell.textField.placeholder = PASSWORD_CELL_TITLE;
            if ([JNKeychain loadValueForKey:KEY_CACHED_PASSWORD]) {
                cell.textField.text = [JNKeychain loadValueForKey:KEY_CACHED_PASSWORD];
            }
            cell.textField.secureTextEntry = YES;
        } else {
            cell.textField.placeholder = @"Server IP";
            if ([JNKeychain loadValueForKey:KEY_CACHED_IP]) {
                cell.textField.text = [JNKeychain loadValueForKey:KEY_CACHED_IP];
            }
        }
    } else if (indexPath.section == 1) {
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
        if (indexPath.row == 0) {
            cell.titleLabel.text = LOGIN_CELL_TITLE;
        } else {
            cell.titleLabel.text = SIGNUP_CELL_TITLE;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TextFieldCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self didTapLogin];
        } else if (indexPath.row == 1) {
            [self didTapSignup];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - LoginDelegate
- (void)didLogin {
    [self.HUD hideAnimated:YES];
    if (DEVELOPMENT) NSLog(@"didLogin");
    [self updateCache];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_DID_LOG_IN];
    [self performSegueWithIdentifier:@"unwindtoAccount" sender:self];
}

- (void)userExists {
    [self.HUD hideAnimated:YES];
    if (DEVELOPMENT) NSLog(@"userExists");
    [self presentViewController:[self userExistsAlert] animated:YES completion:nil];
}

- (void)userNotExists {
    [self.HUD hideAnimated:YES];
    if (DEVELOPMENT) NSLog(@"userNotExists");
    [self presentViewController:[self userNotExistsAlert] animated:YES completion:nil];
}

- (void)didSignup {
    [self.HUD hideAnimated:YES];
    if (DEVELOPMENT) NSLog(@"didSignup");
    [self updateCache];
    [self performSegueWithIdentifier:@"unwindtoAccount" sender:self];
}

- (void)wrongPassword {
    [self.HUD hideAnimated:YES];
    if (DEVELOPMENT) NSLog(@"wrongPassword");
    [self presentViewController:[self wrongPasswordAlert] animated:YES completion:nil];
}

- (void)sessionFailed {
    [self.HUD hideAnimated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECTION_FAILED
                                                        message:CONNECTION_FAILED_NO_INTERNET
                                                       delegate:self
                                              cancelButtonTitle:DISMISS_ALERT_ACTION_DEFAULT
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - IBAction
- (void)didTapLogin {
    [self.view endEditing:YES];
    if ([self.userID isEqualToString:@""]) {
        [self presentViewController:[self noUsernameAlert] animated:YES completion:nil];
    } else if([self.password isEqualToString:@""]) {
        [self presentViewController:[self noPasswordAlert] animated:YES completion:nil];
    } else if([self.ip isEqualToString:@""]) {
        [self presentViewController:[self noPasswordAlert] animated:YES completion:nil];
    } else {
        [JNKeychain saveValue:self.ip forKey:KEY_CACHED_IP];
        [self.HUD showAnimated:YES];
        [[NetworkUtilities sharedEngine] postAPIwithCommand:@"login" data:[@{KEY_USER_ID : self.userID,
                                                                             KEY_PASSWORD : self.password,
                                                                             @"items"   : [Item serverDump]} mutableCopy]];
    }
}

- (void)didTapSignup {
    [self.view endEditing:YES];
    if ([self.userID isEqualToString:@""]) {
        [self presentViewController:[self noUsernameAlert] animated:YES completion:nil];
    } else if([self.password isEqualToString:@""]) {
        [self presentViewController:[self noPasswordAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isUsernameValid:self.userID]) {
        if (DEVELOPMENT) NSLog(@"userID invalid");
        [self presentViewController:[self userIDInvalidAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isUsernameLengthValid:self.userID]) {
        if (DEVELOPMENT) NSLog(@"userID length invalid");
        [self presentViewController:[self userIDLengthInvalidAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isPasswordValid:self.password]) {
        if (DEVELOPMENT) NSLog(@"password invalid");
        [self presentViewController:[self passwordInvalidAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isPasswordLengthValid:self.password]) {
        if (DEVELOPMENT) NSLog(@"password length invalid");
        [self presentViewController:[self passwordLengthInvalidAlert] animated:YES completion:nil];
    } else {
        [self.HUD showAnimated:YES];
        [[NetworkUtilities sharedEngine] postAPIwithCommand:@"signup" data:[@{KEY_USER_ID : self.userID,
                                                                              KEY_PASSWORD : self.password,
                                                                              @"items"    : [Item serverDump]} mutableCopy]];
    }
}

#pragma mark - Utilities
- (void) updateCache {
    [JNKeychain saveValue:self.userID forKey:KEY_CACHED_USER_ID];
    [JNKeychain saveValue:self.password forKey:KEY_CACHED_PASSWORD];
}

- (TextFieldCell *)userIDCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)userID {
    return self.userIDCell.textField.text;
}

- (TextFieldCell *)passwordCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)password {
    return self.passwordCell.textField.text;
}

- (TextFieldCell *)ipCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)ip {
    return self.ipCell.textField.text;
}

#pragma mark - Alert
- (UIAlertController *) noPasswordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:MISSING_INPUT
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passwordCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) noUsernameAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:ALERT_LOGIN_FAILED_SUBTEXT_NO_ACCOUNT_INPUT
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.userIDCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) userIDInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_INVALID_USER_ID
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.userIDCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) userIDLengthInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_ID_LENGTH_INVALID
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.userIDCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) passwordInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_INVALID_PASSWORD
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passwordCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) passwordLengthInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_PASSWORD_LENGTH_INVALID
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passwordCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) userExistsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_USER_EXISTS
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.userIDCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) wrongPasswordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:ALERT_LOGIN_FAILED_SUBTEXT_INCORRECT_CREDENTIALS
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passwordCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) userNotExistsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:ALERT_LOGIN_FAILED_SUBTEXT_ACCOUNT_DOES_NOT_EXIST
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.userIDCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
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
