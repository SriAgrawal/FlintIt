//
//  NSString+Validate.m
//  LokiApp
//
//  Created by Chandrakant Goyal on 7/21/15.
//  Copyright (c) 2015 Mobiloitte Technologies. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)


- (NSUInteger)wordCount {
    
    __block int words = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0,self.length)
                             options:NSStringEnumerationByWords
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {words++;}];
    return words;
}


- (CGFloat)getEstimatedHeightWithFont:(UIFont*)font withWidth:(CGFloat)width withExtraHeight:(CGFloat)ht{
    
    if (!self || !self.length)
        return 0;
    
    CGFloat labelSize;
    
    CGRect rect = [self boundingRectWithSize : (CGSize){width, CGFLOAT_MAX}
                                     options : NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes : @{ NSFontAttributeName: font }
                                     context : nil];
    labelSize = rect.size.height;
    
    return labelSize + ht;
}

// method to remove white spaces
- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}


// Checking if String is Empty
-(BOOL)isBlank {
    
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""]) ? YES : NO;
}

//Checking if String is empty or nil
-(BOOL)isValid {
    
    return ([[self removeWhiteSpacesFromString] isEqualToString:@""] || self == nil || [self isEqualToString:@"(null)"]) ? NO :YES;
}


// remove white spaces from String
- (NSString *)removeWhiteSpacesFromString {
    
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

// Counts number of Words in String
- (NSUInteger)countNumberOfWords {
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSUInteger count = 0;
    while ([scanner scanUpToCharactersFromSet: whiteSpace  intoString: nil])
        count++;
    
    return count;
}

// If string contains substring
- (BOOL)containsString:(NSString *)subString {
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

// If my string starts with given string
- (BOOL)isBeginsWith:(NSString *)string {
    return ([self hasPrefix:string]) ? YES : NO;
}

// If my string ends with given string
- (BOOL)isEndssWith:(NSString *)string {
    return ([self hasSuffix:string]) ? YES : NO;
}


// Replace particular characters in my string with new character
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar {
    return  [self stringByReplacingOccurrencesOfString:olderChar withString:newerChar];
}

// Get Substring from particular location to given lenght
- (NSString*)getSubstringFrom:(NSInteger)begin to:(NSInteger)end {
    
    NSRange r;
    r.location = begin;
    r.length = end - begin;
    return [self substringWithRange:r];
}

// Add substring to main String
- (NSString *)addString:(NSString *)string {
    
    if(!string || string.length == 0)
        return self;
    
    return [self stringByAppendingString:string];
}

// Remove particular sub string from main string
-(NSString *)removeSubString:(NSString *)subString {
    
    if ([self containsString:subString]) {
        NSRange range = [self rangeOfString:subString];
        return  [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

// If my string contains ony letters
- (BOOL)containsOnlyLetters {
    
    NSCharacterSet *letterCharacterset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:letterCharacterset].location == NSNotFound);
}

// If my string contains only numbers
- (BOOL)containsOnlyNumbers {
    
    NSCharacterSet *numbersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbersCharacterSet].location == NSNotFound);
}

// If my string contains only numbers and Plus sign
- (BOOL)containsOnlyNumbersAndPlusSign {
    
    NSCharacterSet *numbersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbersCharacterSet].location == NSNotFound);
}
- (BOOL)containsOnlyNumbersAndComma {
    NSString *regex = @"^(?=.*[0-9])(?=.*[,])[0-9,]{0,}$";
    NSPredicate *emailTestPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTestPredicate evaluateWithObject:self];
    
}

// If my string contains letters and numbers
- (BOOL)containsOnlyNumbersAndLetters {
    
    NSCharacterSet *numAndLetterCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:numAndLetterCharSet].location == NSNotFound);
}

// If my string is available in particular array
- (BOOL)isInThisarray:(NSArray*)array {
    
    for(NSString *string in array) {
        if([self isEqualToString:string])
            return YES;
    }
    return NO;
}

// Get String from array
+ (NSString *)getStringFromArray:(NSArray *)array {
    return [array componentsJoinedByString:@" "];
}

// Convert Array from my String
- (NSArray *)getArray {
    return [self componentsSeparatedByString:@" "];
}

// Get My Application Version number
+ (NSString *)getMyApplicationVersion {
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleVersion"];
    return version;
}

// Get My Application name
+ (NSString *)getMyApplicationName {
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleDisplayName"];
    return name;
}

// Convert string to NSData
- (NSData *)convertToData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

// Get String from NSData
+ (NSString *)getStringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
}
// Is Valid Name
- (BOOL)isValidName {
    
   // NSString *regex = @"\\+?[a-zA-Z]{10,13}";
    
    NSString *regex =@"^[a-zA-Z\u0600-\u06FF\\s]+$";

    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [namePredicate evaluateWithObject:self];
}

// Is Valid Email
- (BOOL)isValidEmail {
    
       NSString *regex = @"^[A-Za-z\u0600-\u06FF ][A-Z0-9a-z\u0600-\u06FF \\._%+-]+@([A-Za-z\u0600-\u06FF 0-9-]+\\.)+[A-Za-z\u0600-\u06FF ]{2,4}$";
    
//    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTestPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTestPredicate evaluateWithObject:self];
}

// Is Valid Phone
- (BOOL)isVAlidPhoneNumber {
    
    NSString *regex = @"\\+?[0-9]{10,13}";
    
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

// Is Valid URL
- (BOOL)isValidUrl {
    
    NSString *regex =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

// Is Valid Password
- (BOOL)isValidPassword{
    NSString *regex =@"^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$!%*#?&])[A-Za-z0-9$@$!%*#?&]{8,}$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [passwordTest evaluateWithObject:self];
}


- (BOOL)textIsValidEmailFormat:(NSString *)text {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"; NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:text];
}

+(NSAttributedString *)customAttributeString:(NSString *)stringText withAlignment:(NSTextAlignment)align withLineSpacing:(int)space withFont:(UIFont*)font{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:stringText];
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.alignment = align;
    [pStyle setLineSpacing:space];
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [stringText length])];
    [string addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, [stringText length])];
    return string;
}
@end
