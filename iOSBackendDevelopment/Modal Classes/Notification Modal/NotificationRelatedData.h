//
//  NotificationRelatedData.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 10/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationRelatedData : NSObject

@property (strong,nonatomic) NSString *jobID;
@property (strong,nonatomic) NSString *notificationText;
@property (strong,nonatomic) NSString *senderID;
@property (strong,nonatomic) NSString *receiverID;
@property (strong,nonatomic) NSString *approvedSt;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *createdAt;
@property (strong,nonatomic) NSString *userType;

@property (strong,nonatomic) NSString *block_status;


+(NotificationRelatedData *)parseNotificationList:(NSDictionary *)NotificationList;

@end
