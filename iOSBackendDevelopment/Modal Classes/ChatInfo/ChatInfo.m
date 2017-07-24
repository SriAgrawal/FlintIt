//
//  ChatInfo.m
//  iOSBackendDevelopment
//
//  Created by Neha Chhabra on 19/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ChatInfo.h"
#import <UIKit/UIKit.h>
@implementation ChatInfo

+(NSMutableArray *)getChatInfo:(NSDictionary*)response {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dict in [response objectForKey:@"chatArray"]) {
        ChatInfo *chatInfo = [[ChatInfo alloc]init];
        chatInfo.isImage = [[dict objectForKey:@"isImage"] boolValue];
        chatInfo.isAudio = [[dict objectForKey:@"isAudio"] boolValue];
        chatInfo.message = [dict objectForKey:@"message"];
        if (chatInfo.isImage) {
            chatInfo.image =[UIImage imageWithData:[NSData dataWithContentsOfFile:[dict objectForKey:@"image"]]];
        } else if (chatInfo.isAudio) {
            chatInfo.audio = [dict objectForKey:@"audio"];
            chatInfo.image = [UIImage imageNamed:@"play"];
        }

        [tempArray addObject:chatInfo];
    }
    return tempArray;
}

@end
