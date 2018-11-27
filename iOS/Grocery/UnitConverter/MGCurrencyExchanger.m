//
//  MGCurrencyExchanger.m
//  CurrencyExchange
//
//  Created by Milo Gosnell on 7/2/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "MGCurrencyExchanger.h"

@implementation MGCurrencyExchanger

+(double)exchangeAmountOnline:(double)amount fromCurrency:(NSLocale *)fromLocale toCurrency:(NSLocale *)toLocale withError:(NSError **)error {
    @autoreleasepool {
        
        NSAssert(fromLocale, @"From Currency can't be nil");
        NSAssert(toLocale, @"To Currency can't be nil");
        
        NSString *fromCurrencyCode = [fromLocale currencyCode];
        NSString *toCurrencyCode = [toLocale currencyCode];
        
        if (!fromCurrencyCode) {
            NSDictionary *details = @{NSLocalizedDescriptionKey: @"Could not get currency code from fromCurrency"};
            NSError *fromError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
            if (error)
                *error = fromError;
            return 0.0;
        }
        
        if (!toCurrencyCode) {
            NSDictionary *details = @{NSLocalizedDescriptionKey: @"Could not get currency code from toCurrency"};
            NSError *toError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
            if (error)
                *error = toError;
            return 0.0;
        }
        
        
        NSError *URLError;
        NSString *yahooURL = [NSString stringWithFormat:@"https://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.xchange where pair in (\"%@%@\")&format=json&diagnostics=false&env=store://datatables.org/alltableswithkeys&callback=", fromCurrencyCode, toCurrencyCode];
        
        yahooURL = [yahooURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:yahooURL]] returningResponse:nil error:&URLError];
        
        if (URLError && error) {
            *error = URLError;
            return 0.0;
        }
        
        NSError *JSONError;
        
        NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&JSONError];
        
        if (JSONError && error) {
            *error = JSONError;
            return 0.0;
        }
        
        @try {
            double exchangeRate = [JSONResponse[@"query"][@"results"][@"rate"][@"Rate"] doubleValue];
            if (exchangeRate == 0.0) {
                NSDictionary *details = @{NSLocalizedDescriptionKey: @"Exchange rate could not be found"};
                NSError *fromError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
                if (error)
                    *error = fromError;
            }
            return amount * exchangeRate;
        }
        
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            return 0.0;
        }
        
        @finally {}
    }
}

+(double)exchangeAmountOffline:(double)amount fromCurrency:(NSLocale *)fromLocale toCurrency:(NSLocale *)toLocale fromFile:(NSArray *)csvFile withError:(NSError **)error {
    
    NSAssert(fromLocale, @"From Currency can't be nil");
    NSAssert(toLocale, @"To Currency can't be nil");
    NSAssert(csvFile, @"File can't be nil");
    
    NSString *fromCurrencyCode = [fromLocale currencyCode];
    NSString *toCurrencyCode = [toLocale currencyCode];
    
    if (!fromCurrencyCode) {
        NSDictionary *details = @{NSLocalizedDescriptionKey: @"Could not get currency code from fromCurrency"};
        NSError *fromError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
        if (error)
            *error = fromError;
        return 0.0;
    }
    
    if (!toCurrencyCode) {
        NSDictionary *details = @{NSLocalizedDescriptionKey: @"Could not get currency code from toCurrency"};
        NSError *toError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
        if (error)
            *error = toError;
        return 0.0;
    }

    
    NSString *exchangeString = [NSString stringWithFormat:@"%@%@", fromCurrencyCode, toCurrencyCode];
    
    if ([csvFile indexOfObject:exchangeString] != NSNotFound) {
        
        NSString *rateString = csvFile[[csvFile indexOfObject:exchangeString] + 1];
        double exchangeRate = [rateString doubleValue];
        
        return amount * exchangeRate;
    } else {
        NSDictionary *details = @{NSLocalizedDescriptionKey: @"Could not find currency exchange rate"};
        NSError *notFoundError = [NSError errorWithDomain:@"Currency" code:404 userInfo:details];
        if (error)
            *error = notFoundError;
        return 0.0;
    }
    
}

+(NSString *)formattedCurrencyWithAmount:(double)amount currency:(NSLocale *)currencyLocale symbol:(BOOL)symbolBool {
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterCurrencyStyle];
    [f setLocale:currencyLocale];
//    [f setLocalizesFormat:YES];
    NSString *currencySymbol = [currencyLocale currencySymbol];
    [f setCurrencySymbol:symbolBool ? currencySymbol : @""];
    
    return [f stringFromNumber:@(amount)];
}

+ (NSArray *)currencyCodes {
    return @[@"CNY",
             @"AED",
             @"USD",
             @"CHF",
             @"IRR",
             @"INR"
             ];
}

+ (NSString *)countryNameForCurrency:(NSString *)currency {
    NSString *country = MGCountryChina;
    switch ([[MGCurrencyExchanger currencyCodes] indexOfObject:currency]) {
        case 0:
            country = MGCountryChina;
            break;
        case 1:
            country = MGCountryUnitedArabEmirates;
            break;
        case 2:
            country = MGCountryUnitedStates;
            break;
        case 3:
            country = MGCountrySwitzerland;
            break;
        case 4:
            country = MGCountryIran;
            break;
        case 5:
            country = MGCountryIndia;
            break;
        default:
            break;
    }
    return country;
}

@end
