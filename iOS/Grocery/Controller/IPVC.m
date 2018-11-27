//
//  IPVC.m
//  Grocery
//
//  Created by Work on 8/12/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "IPVC.h"
#import "TextFieldCell.h"
#import "JNKeychain.h"
#import "Macros.h"

@interface IPVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) TextFieldCell *ipCell;
@property (nonatomic, strong) NSString *ip;
@end

@implementation IPVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.ipCell.textField becomeFirstResponder];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    if ([JNKeychain loadValueForKey:KEY_CACHED_IP]) {
        cell.textField.text = [JNKeychain loadValueForKey:KEY_CACHED_IP];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (TextFieldCell *)ipCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)ip {
    return self.ipCell.textField.text;
}

- (IBAction)didTapSubmit:(id)sender {
    [JNKeychain saveValue:self.ip forKey:KEY_CACHED_IP];
    [self performSegueWithIdentifier:@"unwindtoAccount" sender:self];
}

@end
