//
//  NSString+CC.m
//  CocoonApp
//
//  Created by Abhishek Agarwal on 02/04/15.
//  Copyright (c) 2015 Mobiloitte. All rights reserved.
//

#import "NSString+CC.h"

@implementation NSString (CC)

-(UIImage *)getImageFromURI{
    
    NSURL *url = [NSURL URLWithString:self];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
    
}

-(NSString *)getBase64StringFromURI {
    
    NSURL *url = [NSURL URLWithString:self];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
