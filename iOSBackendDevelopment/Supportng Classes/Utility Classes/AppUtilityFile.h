//
//  AppUtilityFile.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 01/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppUtilityFile : NSObject

typedef NS_ENUM( NSInteger,SocialMenu) {
    Social = 1,
    Menu = 2,
};

@property(assign,nonatomic) SocialMenu comingFrom;

+(AppUtilityFile *)sharedInstance ;

//App Related required methods
UIImage *imageFromColor(UIColor* color);
void setHintFor(id elemnt, NSIndexPath *index);
NSIndexPath *getIndexPathFor (id elemnt);
double roundValue(double value, int places);
UIImage *takeSnapshot(UIView *snapView );
UIColor *getColor (float r,float g,float b,float a);
void animateTextView(id field,BOOL up,UIView *controllerView,int distanceUp);
+ (NSAttributedString *)getSimpleMultiAttributedString:(NSString *)completeStr firstStr:(NSString *)firstStr withColor :(UIColor *)firstStrColor withFont :(UIFont *)firstStrFont secondStr:(NSString *)secondStr withColor:(UIColor *)secondStrColor withFont :(UIFont *)secondStrFont;
+(NSMutableAttributedString *)getAttributedToAdjustLineSpacingWithAllignment:(NSString *)str withSpacing :(CGFloat)spaceValue;
+(NSAttributedString *)attachImageWithText :(NSString *)strImageName withText:(NSString *)strText withIndex :(NSInteger)rangeIndex;
void addPading(UITextField *field);
void addRightPading(UITextField *field);
UIToolbar* toolBarForNumberPad(id controller, NSString *titleDoneOrNext);

//Getting all # till space string in main String
+(NSMutableArray *)getSubstringInArrayFromString:(NSString *)str;
+(NSMutableArray *)getSubstringBeforeAndAfterTheFirstComma:(NSString *)str;

//Navigation BarButtons
UIBarButtonItem* backButtonForController (id controller, NSString *imgStr);
UIBarButtonItem* revealButtonForController (id controller, NSString *imgStr);
UIBarButtonItem* rightBarButtonForController(id controller, NSString *imgStr);

//Corner And Rounded and Border
UIButton *setCornerForButton (UIButton *btn);
UIView *setCornerForView (UIView *view);
UIImageView *getRoundedImage (UIImageView *imgView);
void setBorderOfFourButton (UIImageView *selectedImg,UIImageView *otherFirstImg,UIImageView *otherSecondImg,UIImageView *otherThirdImg,UIImageView *otherFourthBtn);


+(NSString *)getTimeZone;

//Date and Time Formate
+(NSString *)getTimeFromDate:(NSDate *)date;
+(NSString *)getDateFromNSDate:(NSDate *)date;
+(NSDate *)getDateFromString:(NSString *)dateStr;
NSDate* convertToDate(NSString* dateString, NSString* format);
NSString* convertToString(NSDate* date, NSString* format);
+(NSString *)convertingTimeStampIntoTime:(NSString *)timeStampString;
+(NSString *)convertTimeStampIntoDate:(NSString *)timeStampString;

@end
