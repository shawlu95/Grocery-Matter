//
//  Item.m
//  Grocery
//
//  Created by Xiao on 7/15/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "DateUtilities.h"
#import "Item.h"
#import "GroceryManager.h"
#import "AppDelegate.h"
#import "MGCurrencyExchanger.h"

@implementation Item

+ (NSNumberFormatter *)chineseFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:locale];
    NSString *currencySymbol = [locale currencySymbol];
    [formatter setCurrencySymbol:currencySymbol];
    return formatter;
}

+ (Item *)findByID:(NSNumber *)id {
    NSManagedObjectContext *managedObjectContext = [Item managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Item" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", id];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects.count == 1) {
        return objects[0];
    } else if (objects.count > 1) {
        Item *first = objects[0];
        for (Item *item in objects) {
            [managedObjectContext deleteObject:item];
            NSLog(@"Deleted duplicate: %@ id %@", item.name, item.id);
        }
        [Item saveContext];
        return first;
    }
    return nil;
}

+ (NSArray *)typeArr {
//    return [[self localizedTypes] allKeys];
    return @[
             KEY_INV,
             KEY_LOV,
             KEY_EDU,
             KEY_BOO,
             KEY_STA,
             KEY_PEN,
             KEY_FOO,
             KEY_CLO,
             KEY_SAR,
             KEY_SHO,
             KEY_ACC,
             KEY_HYG,
             KEY_FUR,
             KEY_ELE,
             KEY_COM,
             KEY_SOC,
             KEY_TRA,
             KEY_HOU,
             KEY_AUT,
             KEY_ENT,
             KEY_SOF,
             KEY_LEG,
             KEY_TAX,
             KEY_INS,
             KEY_MIS
             ];
}


+ (NSDictionary *)localizedTypes {
    return @{
             KEY_INV : TYPE_INV,
             KEY_LOV : TYPE_LOV,
             KEY_EDU : TYPE_EDU,
             KEY_FOO : TYPE_FOO,
             KEY_CLO : TYPE_CLO,
             KEY_SAR : TYPE_SAR,
             KEY_SHO : TYPE_SHO,
             KEY_ACC : TYPE_ACC,
             KEY_STA : TYPE_STA,
             KEY_PEN : TYPE_PEN,
             KEY_HYG : TYPE_HYG,
             KEY_BOO : TYPE_BOO,
             KEY_FUR : TYPE_FUR,
             KEY_ELE : TYPE_ELE,
             KEY_COM : TYPE_COM,
             KEY_SOC : TYPE_SOC,
             KEY_TRA : TYPE_TRA,
             KEY_ENT : TYPE_ENT,
             KEY_HOU : TYPE_HOU,
             KEY_AUT : TYPE_AUT,
             KEY_LEG : TYPE_LEG,
             KEY_TAX : TYPE_TAX,
             KEY_INS : TYPE_INS,
             KEY_SOF : TYPE_SOF,
             KEY_MIS : TYPE_MIS
             };
}

+(Item *)findByName:(NSString *)name time:(nonnull NSDate *)time {
    NSManagedObjectContext *managedObjectContext = [Item managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Item" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ && time == %@", name, time];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects.count == 1) {
        return objects[0];
    } else if (objects.count > 1) {
        Item *first = objects[0];
        for (Item *item in objects) {
            [managedObjectContext deleteObject:item];
            NSLog(@"Deleted duplicate: %@ id %@", item.name, item.id);
        }
        [Item saveContext];
        return first;
    }
    return nil;
}

- (NSNumber*) totalPrice {
    double totalPrice = self.count.integerValue * self.price.doubleValue;
    return [NSNumber numberWithDouble:totalPrice];
}

- (NSNumber *)totalPriceCNY {
    double totalPrice = self.count.integerValue * self.priceCNY.doubleValue;
    return [NSNumber numberWithDouble:totalPrice];
}

- (void)setTotalPrice:(NSNumber *)totaallItemslPrice {
}

- (void)setTotalPriceCNY:(NSNumber *)totalPriceCNY {
    
}

- (NSMutableDictionary*) dictionaryRepresentation {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.name) [dict setValue:self.name forKey:KEY_NAME];
    if (self.type) [dict setValue:self.type forKey:KEY_TYPE];
    if (self.count) [dict setValue:self.count forKey:KEY_COUNT];
    if (self.price) [dict setValue:self.price forKey:KEY_PRICE];
    if (self.currency) [dict setValue:self.currency forKey:KEY_CURRENCY];
    if (self.priceCNY) [dict setValue:self.priceCNY forKey:KEY_PRICECNY];
    if (self.time) [dict setValue:self.time forKey:KEY_TIME];
    if (self.id) [dict setValue:self.id forKey:KEY_ID];
    return dict;
}

-(void)copyFromDict:(NSDictionary *)dict {
    if (dict[KEY_NAME]) self.name = dict[KEY_NAME];
    if (dict[KEY_TYPE]) self.type = dict[KEY_TYPE];
    if (dict[KEY_PRICE]) self.price = dict[KEY_PRICE];
    if (dict[KEY_CURRENCY]) self.currency = dict[KEY_CURRENCY];
    if (dict[KEY_PRICECNY]) self.priceCNY = dict[KEY_PRICECNY];
    if (dict[KEY_TIME]) self.time = dict[KEY_TIME];
    if (dict[KEY_COUNT]) self.count = dict[KEY_COUNT];
    if (dict[KEY_ID]) self.id = dict[KEY_ID];
    self.lastModified = [NSDate date];
    if (!self.created) {
        self.created = [NSDate date];
    }
}

- (NSMutableDictionary*) JSONdictionaryRepresentation {
    NSMutableDictionary *dict = [self dictionaryRepresentation];
    if (self.time) [dict setValue:[DateUtilities mySQLDateTimeForDate:self.time] forKey:KEY_TIME];
    if (self.lastModified) [dict setValue:[DateUtilities mySQLDateTimeForDate:self.lastModified] forKey:KEY_LAST_MODIFIED];
    if (self.created) [dict setValue:[DateUtilities mySQLDateTimeForDate:self.created] forKey:KEY_CREATED];
    return dict;
}

- (void)updateFromServer:(NSDictionary *)dict {
    if (dict[KEY_ID])               self.id = [NSNumber numberWithDouble:[[dict valueForKey:KEY_ID] doubleValue]];
    if (dict[KEY_NAME])             self.name = dict[KEY_NAME];
    if (dict[KEY_TYPE])             self.type = dict[KEY_TYPE];
    if (dict[KEY_LAST_MODIFIED])    self.lastModified = [DateUtilities dateTimeUsingStringFromAPI:dict[KEY_LAST_MODIFIED]];
    if (dict[KEY_CREATED])          self.created = [DateUtilities dateTimeUsingStringFromAPI:dict[KEY_CREATED]];
    if (dict[KEY_TIME])             self.time = [DateUtilities dateTimeUsingStringFromAPI:dict[KEY_TIME]];
    if (dict[KEY_COUNT])            self.count = [NSNumber numberWithDouble:[[dict valueForKey:KEY_COUNT] doubleValue]];
    if (dict[KEY_PRICE])            self.price = [NSNumber numberWithDouble:[[dict valueForKey:KEY_PRICE] doubleValue]];
    if (dict[KEY_CURRENCY])         self.currency = dict[KEY_CURRENCY];
    if (dict[KEY_PRICECNY])         self.priceCNY = [NSNumber numberWithDouble:[[dict valueForKey:KEY_PRICECNY] doubleValue]];
}

- (void) serverInsert {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"create" data:[self JSONdictionaryRepresentation]];
}

- (void) serverUpdate {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"update" data:[self JSONdictionaryRepresentation]];
}

- (void)serverDelete {
    [[NetworkUtilities sharedEngine] postAPIwithCommand:@"delete" data:[@{KEY_ID : self.id} mutableCopy]];
}

-(NSComparisonResult)compare:(Item*)otherItem{
    return [otherItem.time compare:self.time];
}

+ (NSArray *)allItems {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [Item managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TIME ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error;
    NSArray *results = [[Item managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return results;
}

+ (void) clears {
    for (Item *item  in [Item allItems]) {
        [[Item managedObjectContext] deleteObject:item];
    }
    [Item saveContext];
}

+ (NSMutableDictionary *)allItemsSortedByDay {
    NSArray *list = [Item allItems];
    NSMutableDictionary *dayList = [[NSMutableDictionary alloc] init];
    for (Item *item in list) {
        NSMutableArray *day;
        if ([dayList valueForKey:[DateUtilities dayStringForDate:item.time]]) {
            day = [dayList valueForKey:[DateUtilities dayStringForDate:item.time]];
        } else {
            day = [[NSMutableArray alloc] init];
        }
        [day addObject:item];
        [dayList setObject:day forKey:[DateUtilities dayStringForDate:item.time]];
    }
    return dayList;
}

+ (NSMutableDictionary *)allItemsSortedByMon {
    NSArray *list = [Item allItems];
    NSMutableDictionary *allItemsSortedByMon = [[NSMutableDictionary alloc] init];
    for (Item *item in list) {
        NSMutableArray *day;
        if ([allItemsSortedByMon valueForKey:[DateUtilities monStringForDate:item.time]]) {
            day = [allItemsSortedByMon valueForKey:[DateUtilities monStringForDate:item.time]];
        } else {
            day = [[NSMutableArray alloc] init];
        }
        [day addObject:item];
        [allItemsSortedByMon setObject:day forKey:[DateUtilities monStringForDate:item.time]];
    }
    return allItemsSortedByMon;
}

+ (NSArray *) allItemsInMon: (NSDate *) date {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [Item managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSDate *start = [DateUtilities startOfMonth:date];
    NSDate *endDate = [DateUtilities endOfMonth:date];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", KEY_TIME, start, KEY_TIME, endDate];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:KEY_TIME ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error;
    NSArray *results = [[Item managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return results;
}

+ (NSMutableDictionary *)allItemsSortedByDayInMon: (NSDate *) date  {
    NSArray *list = [Item allItemsInMon:date];
    NSMutableDictionary *dayList = [[NSMutableDictionary alloc] init];
    for (Item *item in list) {
        NSMutableArray *day;
        if ([dayList valueForKey:[DateUtilities dayStringForDate:item.time]]) {
            day = [dayList valueForKey:[DateUtilities dayStringForDate:item.time]];
        } else {
            day = [[NSMutableArray alloc] init];
        }
        [day addObject:item];
        [dayList setObject:day forKey:[DateUtilities dayStringForDate:item.time]];
    }
    return dayList;
}

+ (NSArray *) serverDump {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Item *item in [Item allItems]) {
        [array addObject: [item JSONdictionaryRepresentation]];
    }
    return array;
}

+ (NSNumber *)priceCNYForItemPaidInCurrency:(NSString *)currency inAmount:(NSNumber *)amount {
    NSLocale *currencyLocale = [NSLocale localeFromCountryName:[MGCurrencyExchanger countryNameForCurrency:currency]];
    NSLocale *chinaLocale = [NSLocale localeFromCountryName:MGCountryChina];
    NSLocale *usaLocale = [NSLocale localeFromCountryName:MGCountryUnitedStates];
    NSError *error;
    
    double exchangedAmount;
    if ([currencyLocale isEqual:chinaLocale]) {
        exchangedAmount = amount.doubleValue;
    } else if ([currencyLocale isEqual:usaLocale]) {
        exchangedAmount = amount.doubleValue * 6.87220;
    } else {
        exchangedAmount = [MGCurrencyExchanger exchangeAmountOnline:amount.doubleValue fromCurrency:currencyLocale toCurrency:chinaLocale withError:&error];
    }
    return [NSNumber numberWithDouble:exchangedAmount];
}

+ (NSManagedObjectContext *) managedObjectContext {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (void) saveContext {
    NSManagedObjectContext *managedObjectContext = [Item managedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
