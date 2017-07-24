//
//  MacroFiles.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 01/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#ifndef MacroFiles_h
#define MacroFiles_h

#define APPDELEGATE             (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//******************Calender Related data *****************************//
#define CURRENT_CALENDAR [NSCalendar currentCalendar]
#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)


//******************String Related in the application *****************************//
#define TRIM_SPACE(str)  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define concat(a,b)   [NSString stringWithFormat:@"%@%@",a,b]

#define THREEOPTIONSCOMINGFROM   [AppUtilityFile sharedInstance].comingFrom

//******************Used through the application *****************************//
#define NSUSERDEFAULT      [NSUserDefaults standardUserDefaults]
#define Color(R,G,B,a)    [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:a]

//******************View tags in application *****************************//
#define APPBUTTON(tag)                (UIButton*)[self.view viewWithTag:(tag)]
#define APPTEXTFIELD(tag)            (UITextField*)[self.view viewWithTag:(tag)]

//******************Font used in application *****************************//
#define APPFONTITALIC(X)            [UIFont fontWithName:@"Candara-Italic" size:X]
#define APPFONTREGULAR(X)       [UIFont fontWithName:@"Candara" size:X]
#define APPFONTBOLD(X)             [UIFont fontWithName:@"Candara-Bold" size:X]
#define APPFONTBOLDITALIC(X)    [UIFont fontWithName:@"Candara-BoldItalic" size:X]

/****************Defining device dimension**************/
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IOS_7    (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#import "CDLanguageHandler.h"



#if TARGET_IPHONE_SIMULATOR
#define  LOG_LEVEL   0
#else
#define  LOG_LEVEL   0
#endif

#define NSLogInfo(frmt, ...)     if(LOG_LEVEL >= 1) NSLog((@"%s" frmt), __PRETTY_FUNCTION__, ## __VA_ARGS__);


//#define KNSLOCALIZEDSTRING(key)       NSLocalizedString(key, nil)

#endif /* MacroFiles_h */
