//
//  NSString+Validate.h
//  LokiApp
//
//  Created by Chandrakant Goyal on 7/21/15.
//  Copyright (c) 2015 Mobiloitte Technologies. All rights reserved.
//

#import "HeaderFile.h"

@interface NSString (Validate)

- (CGFloat)getEstimatedHeightWithFont:(UIFont*)font withWidth:(CGFloat)width withExtraHeight:(CGFloat)ht;
- (NSUInteger)wordCount;

- (BOOL)isBlank;
- (BOOL)isValid;
- (NSString *)removeWhiteSpacesFromString;
- (NSString *)trimWhitespace;

- (NSUInteger)countNumberOfWords;
- (BOOL)containsString:(NSString *)subString;
- (BOOL)isBeginsWith:(NSString *)string;
- (BOOL)isEndssWith:(NSString *)string;

- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar;
- (NSString*)getSubstringFrom:(NSInteger)begin to:(NSInteger)end;
- (NSString *)addString:(NSString *)string;
- (NSString *)removeSubString:(NSString *)subString;

- (BOOL)containsOnlyLetters;
- (BOOL)containsOnlyNumbers;
- (BOOL)containsOnlyNumbersAndPlusSign;
- (BOOL)containsOnlyNumbersAndComma;
- (BOOL)containsOnlyNumbersAndLetters;
- (BOOL)isInThisarray:(NSArray*)array;

+ (NSString *)getStringFromArray:(NSArray *)array;
- (NSArray *)getArray;

+ (NSString *)getMyApplicationVersion;
+ (NSString *)getMyApplicationName;

- (NSData *)convertToData;
+ (NSString *)getStringFromData:(NSData *)data;

- (BOOL)isValidEmail;
- (BOOL)isVAlidPhoneNumber;
- (BOOL)isValidUrl;
- (BOOL)isValidPassword;
-(BOOL)isValidName;
- (BOOL)textIsValidEmailFormat:(NSString *)text;
+(NSAttributedString *)customAttributeString:(NSString *)stringText withAlignment:(NSTextAlignment)align withLineSpacing:(int)space withFont:(UIFont*)font;
@end
