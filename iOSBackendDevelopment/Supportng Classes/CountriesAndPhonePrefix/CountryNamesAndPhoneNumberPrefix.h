//
//  CountryNamesAndPhoneNumberPrefix.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 05/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CountryNameAndPhonePrefixDelegate <NSObject>

@optional
- (void)didGetPhonePrefix:(NSString *)phonePrefix forCountry:(NSString *)countryCode;

@required
- (void)failedToGetPhonePrefix;

@end

@interface CountryNamesAndPhoneNumberPrefix : NSObject

- (id)initWithDelegate:(id<CountryNameAndPhonePrefixDelegate>)delegate;

- (void)getPhonePrefixForCountry:(NSString *)countryName;

@property (nonatomic, assign) id<CountryNameAndPhonePrefixDelegate> delegate;
@property (nonatomic, strong) NSArray *countriesList;
@end
