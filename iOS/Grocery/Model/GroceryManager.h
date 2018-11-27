//
//  GroceryManager.h
//  Grocery
//
//  Created by Xiao on 3/23/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkUtilities.h"
#import <CoreData/CoreData.h>

@interface GroceryManager : NSObject
+ (GroceryManager *)sharedManager;
+ (NSMutableArray *)read;
+ (void) exportAllItems;
+ (void) logXMLFilePath;
@end
