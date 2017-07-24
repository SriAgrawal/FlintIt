//
//  AppDateFormatter.m
//  SocialMedia
//
//  Created by Krishna Kant Kaira on 02/06/15.
//  Copyright (c) 2015 Mobiloitte Inc. All rights reserved.
//

#import "AppDateFormatter.h"

static AppDateFormatter *dateFormatterSingleton;

@implementation AppDateFormatter

+ (id)sharedManager {
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        dateFormatterSingleton = [[AppDateFormatter alloc] init];
    });
    return dateFormatterSingleton;
}

-(id)init{
    self =  [super init];
    if (self) {
        [self setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return self;
}

@end