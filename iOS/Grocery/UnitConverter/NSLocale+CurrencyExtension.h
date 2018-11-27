//
//  NSLocale+CurrencyExtension.h
//  CurrencyExchange
//
//  Created by Milo Gosnell on 7/1/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSLocale (CurrencyExtension)

-(NSString *)currencyCode;

-(NSString *)currencyNameForCurrencyCode:(NSString *)currencyCode;

-(NSString *)currencySymbol;

+(NSLocale *)localeFromCountryName:(NSString *)countryName;

+(NSLocale *)localeFromCurrencyCode:(NSString *)currencyCode;

@end
