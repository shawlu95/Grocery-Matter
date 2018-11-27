//
//  RangeVC.m
//  Grocery
//
//  Created by Shaw on 8/1/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "RangeVC.h"
#import "TextFieldCell.h"
#import "DateUtilities.h"
#import "PickerCell.h"
#import "StatsVC.h"

@interface RangeVC ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) UIDatePicker *datePicker;
@end

@implementation RangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = START_DATE;
            cell.textField.userInteractionEnabled = NO;
            cell.textField.text = [DateUtilities dayStringForDate:self.startDate];
            break;
        case 1:
            cell.titleLabel.text = END_DATE;
            cell.textField.userInteractionEnabled = NO;
            cell.textField.text = [DateUtilities dayStringForDate:self.endDate];
            break;
        case 2: {
            PickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
            cell.picker.date = self.startDate;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.datePicker.date = self.startDate;
    } else if (indexPath.row == 1) {
        self.datePicker.date = self.endDate;
    }
}

- (NSDate *)startDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!_startDate) {
        if ([defaults objectForKey:START_DATE]) {
            _startDate = [defaults objectForKey:START_DATE];
        } else {
            _startDate = [[NSDate date] dateByAddingTimeInterval:-864000];
        }
    }
    return _startDate;
}

- (NSDate *)endDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!_endDate) {
        if ([defaults objectForKey:END_DATE]) {
            _endDate = [defaults objectForKey:END_DATE];
        } else {
            _endDate = [NSDate date];
        }
    }
    return _endDate;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return 200;
    }
    return 44;
}

- (UIDatePicker *)datePicker {
    PickerCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    return cell.picker;
}

- (IBAction)didSelectDate:(id)sender {
    UIDatePicker *picker = (UIDatePicker*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row) {
        case 0:
            self.startDate = picker.date;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [defaults setObject:self.startDate forKey:START_DATE];
            break;
        case 1:
            self.endDate = picker.date;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [defaults setObject:self.endDate forKey:END_DATE];
            break;
        default:
            break;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    StatsVC *dsvc = segue.destinationViewController;
    dsvc.startDate = self.startDate;
    dsvc.endDate = self.endDate;
}

@end
