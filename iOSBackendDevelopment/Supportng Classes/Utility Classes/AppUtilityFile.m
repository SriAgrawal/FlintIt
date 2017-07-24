//
//  AppUtilityFile.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 01/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "AppUtilityFile.h"
#import "AppDateFormatter.h"
#import "MacroFile.h"

@implementation AppUtilityFile

 +(AppUtilityFile *)sharedInstance {
   static AppUtilityFile *appUtility = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        appUtility = [[AppUtilityFile alloc]init];
    });
    return appUtility;
}

//Image from Color
UIImage* imageFromColor(UIColor* color) {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//Index Related
void setHintFor (id elemnt, NSIndexPath *index) {
    [elemnt setAccessibilityLabel:[NSString stringWithFormat:@"%ld,%ld",(long)index.row,(long)index.section]];
}

NSIndexPath * getIndexPathFor (id elemnt) {
    NSArray *accessibilityArray = [[elemnt accessibilityLabel] componentsSeparatedByString:@","];
    return (([accessibilityArray count] == 2 ) ? [NSIndexPath indexPathForRow:[[accessibilityArray firstObject] integerValue] inSection:[[accessibilityArray lastObject] integerValue]] : [NSIndexPath indexPathForRow:-1 inSection:-1]);
}

//Round Value
double roundValue(double value, int places) {
    
    //default value is 2
    places = (places ? places : 2);
    long factor = (long) pow(10, places);
    value = value * factor;
    long tmp = round(value);
    return (double) tmp / factor;
}

//Taking snap shot
UIImage *takeSnapshot(UIView *snapView ){
    
    UIGraphicsBeginImageContextWithOptions(snapView.frame.size, NO, [UIScreen mainScreen].scale);
    [snapView drawViewHierarchyInRect:snapView.bounds afterScreenUpdates:YES];
    
    // old style [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//Animate text view method
void animateTextView(id field,BOOL up,UIView *controllerView,int distanceUp) {
    const int movementDistance = -distanceUp; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? movementDistance : -movementDistance);
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    controllerView.frame = CGRectOffset(controllerView.frame, 0, movement);
    [UIView commitAnimations];
}

+(NSMutableArray *)getSubstringInArrayFromString:(NSString *)str {
    
   NSArray *arraySepratorBySpace = [str componentsSeparatedByString:@" "];
    
    NSMutableArray *substrings = [NSMutableArray new];
    
    for (NSString *subString in arraySepratorBySpace) {
        NSScanner *scanner = [NSScanner scannerWithString:subString];
        [scanner scanUpToString:@"#" intoString:nil]; // Scan all characters before #
        while(![scanner isAtEnd]) {
            NSString *substring = nil;
            [scanner scanString:@"#" intoString:nil]; // Scan the # character
            if([scanner scanUpToString:@"#" intoString:&substring]) {
                if ([TRIM_SPACE(substring) length]) {
                    [substrings addObject:substring];
                }
                // If the space immediately followed the #, this will be skipped
            }
            [scanner scanUpToString:@"#" intoString:nil]; // Scan all characters before next #
        }

    }
        return substrings;
}

+(NSMutableArray *)getSubstringBeforeAndAfterTheFirstComma:(NSString *)str {
    
    NSRange lastComma = [str rangeOfString:@"," options:NSCaseInsensitiveSearch];    
    NSString *kept = [str substringWithRange:NSMakeRange(0, lastComma.location)];
    NSString *remaining = [str substringWithRange:NSMakeRange(lastComma.location + 1, [str length]- lastComma.location - 1)];
    
    NSMutableArray *subStringArray;
    if ([TRIM_SPACE(kept)  length] && [TRIM_SPACE(remaining)  length]) {
        subStringArray = [NSMutableArray arrayWithObjects:TRIM_SPACE(kept),TRIM_SPACE(remaining), nil];
    }else if ([TRIM_SPACE(kept) length]){
        subStringArray = [NSMutableArray arrayWithObjects:TRIM_SPACE(kept), nil];
    }else  if ([TRIM_SPACE(remaining) length]){
        subStringArray = [NSMutableArray arrayWithObjects:TRIM_SPACE(remaining), nil];
    }else {
        subStringArray = [NSMutableArray array];
    }
    
    return subStringArray;
}

//Get Color
UIColor *getColor (float r,float g,float b,float a) {
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
}

+ (NSAttributedString *)getSimpleMultiAttributedString:(NSString *)completeStr firstStr:(NSString *)firstStr withColor :(UIColor *)firstStrColor withFont :(UIFont *)firstStrFont secondStr:(NSString *)secondStr withColor:(UIColor *)secondStrColor withFont :(UIFont *)secondStrFont {
    
    NSString *effectedStr1 = [NSString stringWithFormat:@"(%@)",firstStr];
    NSString *effectedStr2 = [NSString stringWithFormat:@"(%@)",secondStr ];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:completeStr];
    
    //add alignment
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, mutableAttributedString.length)];
    
    [mutableAttributedString addAttribute:NSFontAttributeName value:firstStrFont range:NSMakeRange(0, mutableAttributedString.length)];
    
    //add color
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mutableAttributedString.length)];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:effectedStr1 options:kNilOptions error:nil];
    NSRange range = NSMakeRange(0,completeStr.length);
    [regex enumerateMatchesInString:completeStr options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:firstStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:firstStrColor range:subStringRange];
    }];
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:effectedStr2 options:kNilOptions error:nil];
    NSRange range1 = NSMakeRange(0,completeStr.length);
    [regex1 enumerateMatchesInString:completeStr options:kNilOptions range:range1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:1];
        [mutableAttributedString addAttribute:NSFontAttributeName value:secondStrFont range:subStringRange];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:secondStrColor range:subStringRange];
    }];
    return mutableAttributedString;
}

+(NSMutableAttributedString *)getAttributedToAdjustLineSpacingWithAllignment:(NSString *)str withSpacing :(CGFloat)spaceValue{
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc ]initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    [style setLineSpacing:spaceValue];
    
    [style setAlignment:NSTextAlignmentCenter];
    
    [attrString addAttribute:NSParagraphStyleAttributeName
     
                       value:style
     
                       range:NSMakeRange(0, str.length)];
    
    return attrString;
}

void addPading(UITextField *field) {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    field.leftView = paddingView;
    field.leftViewMode = UITextFieldViewModeAlways;
}

void addRightPading(UITextField *field) {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    field.rightView = paddingView;
    field.rightViewMode = UITextFieldViewModeAlways;
}

+(NSAttributedString *)attachImageWithText :(NSString *)strImageName withText:(NSString *)strText withIndex :(NSInteger)rangeIndex {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strText];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:strImageName];
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(rangeIndex, 1) withAttributedString:attrStringWithImage];
    return attributedString;
}

UIToolbar* toolBarForNumberPad(id controller, NSString *titleDoneOrNext){
    //NSString *doneOrNext;
    
    UIToolbar *numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:titleDoneOrNext style:UIBarButtonItemStyleDone target:controller action:@selector(doneWithNumberPad:)];
    
    UIBarButtonItem *flexibleSpace =   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [numberToolbar setItems: [NSArray arrayWithObjects:flexibleSpace,doneBtn, nil] animated:NO];
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender {
    
}

#pragma mark - Navigation Bar Method

// Left bar Back button on navigation bar
UIBarButtonItem* backButtonForController(id controller, NSString *imgStr) {
    
    UIImage *buttonImage = [UIImage imageNamed:imgStr];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    [backButton setImage:buttonImage forState:UIControlStateNormal];
    [backButton setImage:buttonImage forState:UIControlStateSelected];
    [backButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    [backButton addTarget:controller action: @selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backBarButtonItem;
}

//Left bar Menu button on navigation bar
UIBarButtonItem* revealButtonForController(id controller, NSString *imgStr) {
    
    UIImage *buttonImage = [UIImage imageNamed:imgStr];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    [backButton setImage:buttonImage forState:UIControlStateNormal];
    [backButton setImage:buttonImage forState:UIControlStateSelected];
    [backButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    [backButton addTarget:controller action: @selector(revealButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backBarButtonItem;
}

//Right bar button on navigation bar
UIBarButtonItem* rightBarButtonForController(id controller, NSString *imgStr ) {
    
    UIImage *buttonImage = [UIImage imageNamed:imgStr];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,buttonImage.size.height);
    [barButton setImage:buttonImage forState:UIControlStateNormal];
    [barButton setImage:buttonImage forState:UIControlStateSelected];
    [barButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    
    [barButton addTarget:controller action: @selector(rightBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barButton];
    return barButtonItem;
}

#pragma mark - Corner Radius of Button,Label and Image,View

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Setting corner of button <<<<<<<<<<<<<<<<<<<<<<<<*/

UIButton *setCornerForButton (UIButton *btn) {
    
    btn.layer.cornerRadius = 3.0f;
    //btn.layer.borderWidth = 1.0f;
    // btn.layer.borderColor =  getColor(3, 175, 108, 1).CGColor;
    return btn;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Setting corner of view <<<<<<<<<<<<<<<<<<<<<<<<*/

UIView *setCornerForView (UIView *view) {
    
    [view.layer setBorderColor:[[[UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0]colorWithAlphaComponent:0.5]CGColor]];
    [view.layer setBorderWidth:2.0];
    view.layer.cornerRadius=5.0;
    view.clipsToBounds=YES;
    
    return view;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Setting rounded image <<<<<<<<<<<<<<<<<<<<<<<<*/

UIImageView *getRoundedImage (UIImageView *imgView) {
    
    imgView.layer.cornerRadius =  imgView.frame.size.height /2;
    imgView.layer.masksToBounds = YES;
    imgView.clipsToBounds = YES;
    
    return imgView;
}

void setBorderOfFourButton (UIImageView *selectedImg,UIImageView *otherFirstImg,UIImageView *otherSecondImg,UIImageView *otherThirdImg,UIImageView *otherFourthBtn){
    
    [selectedImg.layer setBorderWidth:4];
    [selectedImg.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [otherFirstImg.layer setBorderWidth:0];
    [otherFirstImg.layer setBorderColor:[UIColor clearColor].CGColor];
    [otherSecondImg.layer setBorderWidth:0];
    [otherSecondImg.layer setBorderColor:[UIColor clearColor].CGColor];
    [otherThirdImg.layer setBorderWidth:0];
    [otherThirdImg.layer setBorderColor:[UIColor clearColor].CGColor];
    [otherFourthBtn.layer setBorderWidth:0];
    [otherFourthBtn.layer setBorderColor:[UIColor clearColor].CGColor];
}



#pragma mark - Date and Time Related

NSDate* convertToDate(NSString* dateString, NSString* format) {
    
    AppDateFormatter *dateFormatter = [AppDateFormatter sharedManager];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:dateString];
}

NSString* convertToString(NSDate* date, NSString* format) {
    
    AppDateFormatter *dateFormatter = [AppDateFormatter sharedManager];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+(NSString *)getTimeFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[AppUtilityFile enUSPosixlocal]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *)getDateFromNSDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[AppUtilityFile enUSPosixlocal]];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    
    return [dateFormatter stringFromDate:date];
}

+(NSDate *)getDateFromString:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[AppUtilityFile enUSPosixlocal]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormatter dateFromString:dateStr];
}

+(NSString *)convertTimeStampIntoDate:(NSString *)timeStampString {
    NSDate *comingDate = [NSDate dateWithTimeIntervalSince1970:[timeStampString integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[AppUtilityFile enUSPosixlocal]];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    
    return [dateFormatter stringFromDate:comingDate];
}

+(NSString *)convertingTimeStampIntoTime:(NSString *)timeStampString {
    NSDate *comingDate = [NSDate dateWithTimeIntervalSince1970:[timeStampString integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[AppUtilityFile enUSPosixlocal]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    return [dateFormatter stringFromDate:comingDate];
}

+(NSLocale *)enUSPosixlocal {
    return  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
}

+(NSString *)getTimeZone{
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    return destinationTimeZone.name;
}

-(void) backButtonAction:(id)sender {
    
}
- (void) rightBarButtonAction:(id)sender {
    
}
- (void) revealButtonAction:(id)sender {
    
}

@end
