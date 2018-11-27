//
//  PasswordVC.m
//  GPACalculator
//
//  Created by Xiao on 8/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "PasswordVC.h"
#import "TextFieldCell.h"
#import "Macros.h"
#import "JNKeychain.h"
#import "MBProgressHUD.h"
#import "ValidateUtilities.h"

@interface PasswordVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) TextFieldCell *passOldCell;
@property (nonatomic, weak) TextFieldCell *passNewCell;
@property (nonatomic, weak) TextFieldCell *passNew2Cell;
@property (nonatomic, strong) NSString *passOld;
@property (nonatomic, strong) NSString *passNew;
@property (nonatomic, strong) NSString *passNew2;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end

@implementation PasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = CHANGE_PASSWORD_CELL_TITLE;
    [NetworkUtilities sharedEngine].passwordDelegate = self;
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

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    TextFieldCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textField.placeholder = NEW_PASSWORD_PLACEHOLDER;
        } else {
            cell.textField.placeholder = NEW_PASSWORD_PLACEHOLDER;
        }
    } else {
        cell.textField.placeholder = OLD_PASSWORD_PLACEHOLDER;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didTapSubmit:(id)sender {
    [self.view endEditing:YES];
    if ([self.passOld isEqualToString:@""]) {
        [self presentViewController:[self noPassOldAlert] animated:YES completion:nil];
    } else if([self.passNew isEqualToString:@""]) {
        [self presentViewController:[self noPassNewAlert] animated:YES completion:nil];
    } else if([self.passNew2 isEqualToString:@""]) {
        [self presentViewController:[self noPassNew2Alert] animated:YES completion:nil];
    } else if (![[JNKeychain loadValueForKey:KEY_CACHED_PASSWORD] isEqualToString:self.passOld]) {
        if (DEVELOPMENT) NSLog(@"Wrong password");
        [self presentViewController:[self wrongPasswordAlert] animated:YES completion:nil];
    } else if (![self.passNew isEqualToString:self.passNew2]) {
        if (DEVELOPMENT) NSLog(@"Mismatch");
        [self presentViewController:[self passwordMismatchAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isPasswordValid:self.passNew]) {
        if (DEVELOPMENT) NSLog(@"Invalid");
        [self presentViewController:[self passwordInvalidAlert] animated:YES completion:nil];
    } else if (![ValidateUtilities isPasswordLengthValid:self.passNew]) {
        if (DEVELOPMENT) NSLog(@"Length invalid");
        [self presentViewController:[self passwordLengthInvalidAlert] animated:YES completion:nil];
    } else {
        [[NetworkUtilities sharedEngine] postAPIwithCommand:@"cPass" data:[@{@"passOld" : self.passOld,
                                                                             @"passNew" : self.passNew
                                                                             } mutableCopy]];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - PasswordDelegate
- (void)didChangePassword {
    [JNKeychain saveValue:self.passNew forKey:KEY_CACHED_PASSWORD];
    [self performSegueWithIdentifier:@"unwindtoAccount" sender:self];
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

#pragma mark - Utilities
- (NSString *)passOld {
    return self.passOldCell.textField.text;
}

- (NSString *)passNew {
    return self.passNewCell.textField.text;
}

- (NSString *)passNew2 {
    return self.passNew2Cell.textField.text;
}

- (TextFieldCell *)passOldCell {
    return [self cellForRow:0 section:0];
}

-(TextFieldCell *)passNewCell {
    return [self cellForRow:0 section:1];
}

- (TextFieldCell *)passNew2Cell {
    return [self cellForRow:1 section:1];
}

- (TextFieldCell *) cellForRow: (NSInteger) row section: (NSInteger) section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - Alert
- (UIAlertController *) passwordInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_INVALID_USER_ID
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         self.passNewCell.textField.text = @"";
                                                         self.passNew2Cell.textField.text = @"";
                                                         [self.passNewCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) noPassOldAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:MISSING_INPUT
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passOldCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) noPassNewAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:MISSING_INPUT
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passNewCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) noPassNew2Alert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:MISSING_INPUT
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         [self.passNew2Cell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) passwordLengthInvalidAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_PASSWORD_LENGTH_INVALID
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         self.passNewCell.textField.text = @"";
                                                         self.passNew2Cell.textField.text = @"";
                                                         [self.passNewCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) wrongPasswordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:ALERT_LOGIN_FAILED_SUBTEXT_INCORRECT_CREDENTIALS
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         self.passOldCell.textField.text = @"";
                                                         [self.passOldCell.textField becomeFirstResponder];}];
    [alert addAction:action];
    return alert;
}

- (UIAlertController *) passwordMismatchAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT
                                                                   message:REGISTER_FAILED_PASSWORD_MISMATCH
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:DISMISS_ALERT_ACTION_DEFAULT
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                         self.passNewCell.textField.text = @"";
                                                         self.passNew2Cell.textField.text = @"";
                                                         [self.passNewCell.textField becomeFirstResponder];}];
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
