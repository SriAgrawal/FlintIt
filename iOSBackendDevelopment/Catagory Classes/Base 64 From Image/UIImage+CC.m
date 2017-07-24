//
//  UIImage+CC.m
//  CocoonApp
//
//  Created by Abhishek Agarwal on 02/04/15.
//  Copyright (c) 2015 Mobiloitte. All rights reserved.
//

#import "UIImage+CC.h"

@implementation UIImage (CC)

-(NSString *)getBase64String {
    
    //NSData *imageData = UIImageJPEGRepresentation(self ,1.0);
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(self, compression);
    }
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
