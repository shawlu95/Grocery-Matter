//
//  Item.h
//  Grocery
//
//  Created by Xiao on 7/15/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

@property (nonatomic, strong) NSNumber *totalPrice;
@property (nonatomic, strong) NSNumber *totalPriceCNY;

+ (NSNumberFormatter *) chineseFormatter;
+ (Item*) findByID: (NSNumber *) id;
+ (Item*) findByName: (NSString *) name time: (NSDate *) time;
+ (void) clears;
- (NSMutableDictionary*) dictionaryRepresentation;
- (NSMutableDictionary*) JSONdictionaryRepresentation;
- (void) copyFromDict: (NSDictionary *) dict;
+ (NSArray *) allItems;
+ (NSMutableDictionary *) allItemsSortedByDay;
+ (NSArray *) allItemsInMon: (NSDate *) date;
+ (NSMutableDictionary *)allItemsSortedByMon;
+ (NSMutableDictionary *)allItemsSortedByDayInMon: (NSDate *) date;
+ (NSManagedObjectContext *) managedObjectContext;
+ (NSNumber *) priceCNYForItemPaidInCurrency: (NSString *) currency inAmount: (NSNumber*) amount;
+ (void)saveContext;
-(NSComparisonResult)compare:(Item*)otherItem;
+ (NSArray *) typeArr;
+ (NSDictionary *) localizedTypes;
- (void) updateFromServer: (NSDictionary *) dict;
- (void) serverInsert;
- (void) serverUpdate;
- (void) serverDelete;

+ (NSArray *) serverDump;
@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"
