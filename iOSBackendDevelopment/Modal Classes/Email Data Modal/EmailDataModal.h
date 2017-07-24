//
//  EmailDataModal.h
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 09/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailDataModal : NSObject

@property (strong,nonatomic) NSString *emailID;
@property (strong,nonatomic) NSString *conversationID;
@property (strong,nonatomic) NSString *senderID;
@property (strong,nonatomic) NSString *receiverID;
@property (strong,nonatomic) NSString *emailMessage;
@property (strong,nonatomic) NSString *emailSubject;
@property (strong,nonatomic) NSString *profileImage;
@property (strong,nonatomic) NSURL  *userProfileImageURL;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *createdDate;
@property (strong,nonatomic) NSString *serviceStartTime;
@property (strong,nonatomic) NSString *serviceDate;
@property (strong,nonatomic) NSString *serviceTime;
@property (strong,nonatomic) NSString *blockStatus;

+(EmailDataModal *)parseEmailList:(NSDictionary *)EmailList;

@end

@interface EmailListModal : NSObject

@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *userLastMessage;
@property (strong,nonatomic) NSString *sendingMessageDate;
@property (strong,nonatomic) NSString *userImage;

@end
