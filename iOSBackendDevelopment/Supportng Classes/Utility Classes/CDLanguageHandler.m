//
//  CDLanguageHandler.m
//  Culture Dock App
//
//  Created by Ratneshwar Singh on 5/19/16.
//  Copyright © 2016 Ratneshwar Singh. All rights reserved.
//

#import "CDLanguageHandler.h"

// Singleton
static CDLanguageHandler *SingleLocalSystem = nil;

// my Bundle (not the main bundle!)
static NSBundle* myBundle = nil;

@implementation CDLanguageHandler

//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (CDLanguageHandler *) sharedLocalSystem {
    // lazy instantiation
    if (SingleLocalSystem == nil) {
        SingleLocalSystem = [[CDLanguageHandler alloc] init];
    }
    return SingleLocalSystem;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
        myBundle = [NSBundle mainBundle];
    }
    return self;
}


//-------------------------------------------------------------
// translate a string
//-------------------------------------------------------------
// you can use this macro:
// LocalizedString(@"Text");
- (NSString*) localizedStringForKey:(NSString*) key {
    // this is almost exactly what is done when calling the macro NSLocalizedString(@"Text",@"comment")
    // the difference is: here we do not use the systems main bundle, but a bundle
    // we selected manually before (see "setLanguage")
    return [myBundle localizedStringForKey:key value:@"" table:nil];
}

//-------------------------------------------------------------
// set a new language
//-------------------------------------------------------------
// you can use this macro:
// LocalizationSetLanguage(@"German") or LocalizationSetLanguage(@"de");
- (void) setLanguage:(NSString*) lang {
    
    // path to this languages bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj" ];
    if (path == nil) {
        // there is no bundle for that language
        // use main bundle instead
        myBundle = [NSBundle mainBundle];
    } else {
        
        // use this bundle as my bundle from now on:
        myBundle = [NSBundle bundleWithPath:path];
        
        // to be absolutely shure (this is probably unnecessary):
        if (myBundle == nil) {
            myBundle = [NSBundle mainBundle];
        }
    }
}

-(NSString *)getCurretLanguage
{

NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
if ([language isEqualToString:@"ar"]) {
    return  @"arabic";
}else if ([language isEqualToString:@"es"])
{
    return @"spanish";
}else
{
    return @"english";
}
    
}

@end
