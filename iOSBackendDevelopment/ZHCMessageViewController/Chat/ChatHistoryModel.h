//
//  ChatHistoryModel.h
//  iOSBackendDevelopment
//
//  Created by Anand Yadav on 09/11/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatHistoryModel : NSObject


@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *receiverId;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *flag;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *messsageId;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

+(NSMutableArray*)getChatHistory:(NSArray*)chatArray;

@end
