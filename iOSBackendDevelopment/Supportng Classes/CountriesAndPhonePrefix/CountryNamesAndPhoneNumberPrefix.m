//
//  CountryNamesAndPhoneNumberPrefix.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 05/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "CountryNamesAndPhoneNumberPrefix.h"

#define kCountryName        @"name"
#define kCountryCallingCode @"dial_code"
#define kCountryCode        @"code"
#define TRIM_SPACE(str)  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@interface CountryNamesAndPhoneNumberPrefix () {
//    NSArray *countriesList;
}

@end

@implementation CountryNamesAndPhoneNumberPrefix

- (id)initWithDelegate:(id<CountryNameAndPhonePrefixDelegate>)delegate {
    self.delegate  = delegate;
    
    return [self init];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        
        if (localError != nil) {
            NSLog(@"%@", [localError userInfo]);
        }
        _countriesList = (NSArray *)parsedObject;
        
    }
    return self;
}

- (void)getPhonePrefixForCountry:(NSString *)countryName {
    
    NSString *phonePrefix = [NSString string];
    
    for (NSDictionary *dict in _countriesList) {
        if ([[dict valueForKey:kCountryName] isEqualToString:countryName]) {
            phonePrefix  = [dict valueForKey:kCountryCallingCode];
        }
    }
    
    if (phonePrefix && [TRIM_SPACE(phonePrefix) length] > 0) {
        if ([self.delegate respondsToSelector:@selector(didGetPhonePrefix:forCountry:)])
            [self.delegate didGetPhonePrefix:phonePrefix forCountry:countryName];
    } else {
        if ([self.delegate respondsToSelector:@selector(failedToGetPhonePrefix)])
            [self.delegate failedToGetPhonePrefix];
    }
}


@end
