//
//  NSLocale+CurrencyExtension.m
//  CurrencyExchange
//
//  Created by Milo Gosnell on 7/1/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "NSLocale+CurrencyExtension.h"

@implementation NSLocale (CurrencyExtension)


-(NSString *)currencyCode {
    return [self objectForKey:NSLocaleCurrencyCode];
}

-(NSString *)currencyNameForCurrencyCode:(NSString *)currencyCode {
    return [self displayNameForKey:NSLocaleCurrencyCode
                        value:currencyCode];
}

-(NSString *)currencySymbol {
    return [self objectForKey:NSLocaleCurrencySymbol];
}

+(NSLocale *)localeFromCountryName:(NSString *)countryName {
    
    return [NSLocale localeWithLocaleIdentifier:countryName];
}

+(NSLocale *)localeFromCurrencyCode:(NSString *)currencyCode {

    NSArray *locales = [NSLocale availableLocaleIdentifiers];
    NSLocale *locale = nil;
    NSString *localeId;
    
    for (localeId in locales) {
        locale = [NSLocale localeWithLocaleIdentifier:localeId];
        NSString *code = [locale objectForKey:NSLocaleCurrencyCode];
        if ([code isEqualToString:currencyCode])
            break;
        else
            locale = nil;
    }
    
    /* For some codes that locale cannot be found, init it different way. */
    if (locale == nil) {
        localeId = [NSLocale localeIdentifierFromComponents:@{NSLocaleCurrencyCode: currencyCode}];
        locale = [NSLocale localeWithLocaleIdentifier:localeId];
    }
    return locale;
}

@end
