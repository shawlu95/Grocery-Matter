//
//  MGCurrencyExchanger.h
//  CurrencyExchange
//
//  Created by Milo Gosnell on 7/2/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSLocale+CurrencyExtension.h"
#import "MGCountryNames.h"

@interface MGCurrencyExchanger : NSObject

+(double)exchangeAmountOnline:(double)amount fromCurrency:(NSLocale *)fromLocale toCurrency:(NSLocale *)toLocale withError:(NSError **)error;
+(double)exchangeAmountOffline:(double)amount fromCurrency:(NSLocale *)fromLocale toCurrency:(NSLocale *)toLocale fromFile:(NSArray *)csvFile withError:(NSError **)error;
+(NSString *)formattedCurrencyWithAmount:(double)amount currency:(NSLocale *)currencyLocale symbol:(BOOL)symbolBool;
+ (NSArray *) currencyCodes;
+ (NSString *) countryNameForCurrency: (NSString*) currency;
@end
