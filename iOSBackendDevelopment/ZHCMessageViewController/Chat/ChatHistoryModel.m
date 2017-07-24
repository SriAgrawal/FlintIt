//
//  ChatHistoryModel.m
//  iOSBackendDevelopment
//
//  Created by Anand Yadav on 09/11/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ChatHistoryModel.h"
#import "MacroFile.h"
#import "HeaderFile.h"
@implementation ChatHistoryModel


+(NSMutableArray*)getChatHistory:(NSArray*)chatArray{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dictTemp in chatArray) {
        ChatHistoryModel *tempModel = [[ChatHistoryModel alloc] init];
        tempModel.message = [dictTemp objectForKeyNotNull:@"message" expectedObj:@""];
        tempModel.messsageId = [dictTemp objectForKeyNotNull:@"_id" expectedObj:@""];
        tempModel.flag = [dictTemp objectForKeyNotNull:@"flag" expectedObj:@""];
        tempModel.time = [dictTemp objectForKeyNotNull:@"punchDttm" expectedObj:@""];
        tempModel.receiverId = [dictTemp objectForKeyNotNull:@"receiverId" expectedObj:@""];
        tempModel.senderId = [dictTemp objectForKeyNotNull:@"senderId" expectedObj:@""];
        tempModel.messageType = [dictTemp objectForKeyNotNull:@"type" expectedObj:@""];
        tempModel.fileUrl = [dictTemp objectForKeyNotNull:@"fileUrl" expectedObj:@""];
        if ([[dictTemp objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"location"]) {
            tempModel.latitude = [dictTemp objectForKeyNotNull:@"lat" expectedObj:@""];
            tempModel.longitude = [dictTemp objectForKeyNotNull:@"long" expectedObj:@""];
        }

        [tempArray insertObject:tempModel atIndex:0];

    }
    
    return  tempArray;
}


@end
