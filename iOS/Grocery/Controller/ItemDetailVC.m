//
//  ItemDetailVC.m
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//
#import "Item.h"
#import "ItemDetailVC.h"
#import "DateUtilities.h"
#import "MGCurrencyExchanger.h"
#import "TextFieldCell.h"
#import "Macros.h"
#import "GroceryManager.h"
#import "PickerCell.h"
#import "SelectCurrencyVC.h"
#import "SelectTypeVC.h"

@interface ItemDetailVC ()
@property (nonatomic, weak) TextFieldCell *item;
@property (nonatomic, weak) TextFieldCell *count;
@property (nonatomic, weak) TextFieldCell *price;
@property (nonatomic, weak) TextFieldCell *currency;
@property (nonatomic, weak) TextFieldCell *priceCNY;
@property (nonatomic, weak) TextFieldCell *type;
@property (nonatomic, weak) PickerCell *pickerCell;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) NSArray *currencyList;
@property (nonatomic, strong) NSDictionary *currencyCode;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSString *selectedType;
@end

@implementation ItemDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeGroceryState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 7) {
        return 200;
    }
    return 44;
}

- (IBAction)didTapSave:(id)sender {
    [self.view endEditing:YES];
    if ([self.item.textField.text isEqualToString:@""]) {
        [self presentViewController:[self noItemNameAlert] animated:YES completion:nil];
    } else if (![self.price.textField.text doubleValue] || ![self.count.textField.text integerValue]) {
        [self presentViewController:[self invalidNumberAlert] animated:YES completion:nil];
    } else {
        Item *itemToSave;
        if (self.groceryItem) {
            itemToSave = self.groceryItem;
        } else {
            NSEntityDescription *entityWorkout = [NSEntityDescription entityForName:@"Item"
                                                             inManagedObjectContext:[Item managedObjectContext]];
            NSManagedObject *new = [[NSManagedObject alloc] initWithEntity:entityWorkout
                                            insertIntoManagedObjectContext:[Item managedObjectContext]];
            
            // Casting the newly created workout from NSManagedObject class to Workout class.
            itemToSave= (Item *)new;
            itemToSave.created = [NSDate date];
        }
        itemToSave.time = self.selectedDate;
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedDate forKey:@"lastSelectedTime"];
        itemToSave.name = self.item.textField.text;
        itemToSave.price = [NSNumber numberWithDouble:[self.price.textField.text doubleValue]];
        itemToSave.currency = self.currency.textField.text;
        
        itemToSave.type = self.selectedType;
        
        [[NSUserDefaults standardUserDefaults] setObject:itemToSave.currency forKey:@"lastSelectedCurrency"];
        [[NSUserDefaults standardUserDefaults] setObject:itemToSave.type forKey:@"lastSelectedType"];
        
        itemToSave.priceCNY = [NSNumber numberWithDouble:[self.priceCNY.textField.text doubleValue]];
        itemToSave.count = [NSNumber numberWithInteger:[self.count.textField.text integerValue]];
        itemToSave.lastModified = [NSDate date];
        self.groceryItem = itemToSave;
        
        if (![NetworkUtilities notReachable]) {
            if (self.editingState == UPDATE) {
                [itemToSave serverUpdate];
            } else if (self.editingState == CREATE){
                [itemToSave serverInsert];
            }
        }
        
        [Item saveContext];
        if ([self.unwindSegue isEqualToString:UNWIND_TO_GROCERY_LIST]) {
            [self performSegueWithIdentifier:UNWIND_TO_GROCERY_LIST sender:self];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (IBAction)didSelectDate:(id)sender {
    UIDatePicker *picer = (UIDatePicker*) sender;
    self.selectedDate = picer.date;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    switch (indexPath.row) {
        case 0:
            cell.textField.placeholder =ITEM_CELL_PLACEHOLDER;
            cell.titleLabel.text = ITEM_CELL_TITLE;
            if (self.groceryItem) cell.textField.text = self.groceryItem.name;
            break;
        case 1:
            cell.textField.placeholder = COUNT_CELL_PLACEHOLDER;
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.titleLabel.text = COUNT_CELL_TITLE;
            if (self.groceryItem)
                cell.textField.text = [self.groceryItem.count stringValue];
            else
                cell.textField.text = @"1";
            break;
        case 2:
            cell.textField.placeholder = PRICE_CELL_PLACEHOLDER;
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            cell.titleLabel.text = PRICE_CELL_TITLE;
            if (self.groceryItem) cell.textField.text = [NSString stringWithFormat:@"%.2f", self.groceryItem.price.doubleValue];
            break;
        case 3:
            cell.titleLabel.text = CURRENCY_CELL_TITLE;
            cell.textField.userInteractionEnabled = NO;
            if (self.groceryItem)
                cell.textField.text = self.groceryItem.currency;
            else if ([cell.textField.text isEqualToString:@""] &&
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedCurrency"])
                cell.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedCurrency"];
            else
                cell.textField.text = @"CNY";
            break;
        case 4:
            cell.titleLabel.text = PRICECNY_CELL_TITLE;
            cell.textField.userInteractionEnabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.groceryItem) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                [formatter setLocale:locale];
                NSString *currencySymbol = [locale currencySymbol];
                [formatter setCurrencySymbol:currencySymbol];
                cell.textField.text = [NSString stringWithFormat:@"%.2f", self.groceryItem.priceCNY.doubleValue];
            }
            break;
        case 5:
            cell.titleLabel.text = TYPE_CELL_TITLE;
            cell.textField.userInteractionEnabled = NO;
            if (self.groceryItem) {
                cell.textField.text = [[Item localizedTypes] objectForKey:self.groceryItem.type];
            } else if ([cell.textField.text isEqualToString:@""] &&
                       [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedType"]) {
                self.selectedType = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedType"];
                cell.textField.text = [[Item localizedTypes] objectForKey: self.selectedType];
            } else {
                cell.textField.text = [[Item localizedTypes] objectForKey:@"MIS"];
            }
            break;
        case 6:
            cell.titleLabel.text = PRICE_CELL_DATE;
            cell.textField.userInteractionEnabled = NO;
            cell.textField.text = [DateUtilities dayStringForDate:self.selectedDate];
            break;
        case 7: {
            PickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
            cell.picker.date = self.selectedDate;
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
    if (indexPath.row == 6) {
        [self.view endEditing:YES];
        self.pickerCell.picker.alpha = 1;
    } else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"toSelectCurrency" sender:self];
    } else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:@"toSelectType" sender:self];
    } else if (indexPath.row != 4 && indexPath.row != 7){
        TextFieldCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
        if (indexPath.row == 1 && !self.groceryItem && [cell.textField.text isEqualToString:@"1"]) {
            cell.textField.text = @"";
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (TextFieldCell *)item {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (TextFieldCell *)count {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
}

-(TextFieldCell *)price {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
}

-(TextFieldCell *)currency {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
}

-(TextFieldCell *)priceCNY {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
}

- (TextFieldCell *)type {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
}

-(PickerCell *)pickerCell {
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.count.textField] && [textField.text isEqualToString:@"1"] && !self.groceryItem) {
        textField.text = @"";
    }
    self.pickerCell.picker.alpha = 0;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.price.textField] || [textField isEqual:self.currency.textField] || [textField isEqual:self.count.textField] ) {
        [self updatePriceCNY];
    }
}

- (void) updatePriceCNY {
    NSNumber *price = [NSNumber numberWithDouble:[self.price.textField.text doubleValue]];
    NSNumber *priceCNY = [Item priceCNYForItemPaidInCurrency:self.currency.textField.text inAmount:price];
    NSString* s = [self.currencyFormatter stringFromNumber: priceCNY];
    self.priceCNY.textField.text = s;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.pickerCell.picker.alpha = 1;
    return YES;
}

- (UIAlertController *) invalidNumberAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:INVALID_NUM_ALERT_TITLE
                                                                   message:INVALID_NUM_ALERT_MESSAGE
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act = [UIAlertAction actionWithTitle:ALERT_DISMISS style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![self.count.textField.text integerValue]) {
            [self.count.textField becomeFirstResponder];
        } else if (![self.price.textField.text doubleValue]) {
            [self.price.textField becomeFirstResponder];
        }
    }];
    [alert addAction:act];
    return alert;
}

- (UIAlertController *) noItemNameAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NO_ITEM_NAME_ALERT_TITLE
                                                                   message:NO_ITEM_NAME_ALERT_MESSAGE
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act = [UIAlertAction actionWithTitle:ALERT_DISMISS style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.item.textField becomeFirstResponder];
    }];
    [alert addAction:act];
    return alert;
}

- (void) initializeGroceryState {
    if (self.groceryItem) {
        self.selectedDate = self.groceryItem.time;
        self.selectedType = self.groceryItem.type;
    } else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedTime"]){
        self.selectedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedTime"];
        self.selectedType = KEY_MIS;
    } else {
        self.selectedDate = [NSDate date];
    }
}
    
- (NSNumberFormatter *)currencyFormatter {
    if (!_currencyFormatter) {
    NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
    nf.positiveFormat = @"0.##";
        _currencyFormatter = nf;
    }
    return _currencyFormatter;
}

- (IBAction)unwindtoItemDetail:(UIStoryboardSegue *)unwindSegue{
    if ([unwindSegue.sourceViewController isKindOfClass: [SelectCurrencyVC class]]) {
        SelectCurrencyVC *svc = unwindSegue.sourceViewController;
        self.currency.textField.text = svc.selectedCurrency;
        [self updatePriceCNY];
    } else if ([unwindSegue.sourceViewController isKindOfClass:[SelectTypeVC class]]) {
        SelectTypeVC *svc = unwindSegue.sourceViewController;
        self.selectedType = svc.selectedType;
        self.type.textField.text = [[Item localizedTypes] objectForKey:svc.selectedType];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toSelectCurrency"]) {
        SelectCurrencyVC *dsvc = (SelectCurrencyVC*) segue.destinationViewController;
        dsvc.selectedCurrency = self.currency.textField.text;
    }
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
