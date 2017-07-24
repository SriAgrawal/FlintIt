//
//  ChatInfo.h
//  iOSBackendDevelopment
//
//  Created by Neha Chhabra on 19/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFile.h"
@interface ChatInfo : NSObject

@property (nonatomic, strong)NSString *message;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, assign) BOOL isAudio;
@property (nonatomic, strong) NSString *audio;

+(NSMutableArray *)getChatInfo:(NSDictionary*)response;
@end
