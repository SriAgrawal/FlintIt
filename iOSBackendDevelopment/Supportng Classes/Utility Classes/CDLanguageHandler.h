//
//  CDLanguageHandler.h
//  Culture Dock App
//
//  Created by Ratneshwar Singh on 5/19/16.
//  Copyright © 2016 Ratneshwar Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroFile.h"
#import "HeaderFile.h"

#undef NSLocalizedString

//KNSLOCALIZEDSTRING
// Use "LocalizedString(key)" the same way you would use "NSLocalizedString(key,comment)"
//#define NSLocalizedString(key) [[CDLanguageHandler sharedLocalSystem] localizedStringForKey:(key)]

#define KNSLOCALIZEDSTRING(key) [[CDLanguageHandler sharedLocalSystem] localizedStringForKey:(key)]

// "language" can be (for american english): "en", "en-US", "english". Analogous for other languages.
#define LocalizationSetLanguage(language) [[CDLanguageHandler sharedLocalSystem] setLanguage:(language)]

@interface CDLanguageHandler : NSObject

// a singleton:
+ (CDLanguageHandler *) sharedLocalSystem;

// this gets the string localized:
- (NSString*) localizedStringForKey:(NSString*) key;

//set a new language:
- (void) setLanguage:(NSString*) lang;
-(NSString *)getCurretLanguage;

@end
