//
//  NotificationRelatedData.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 10/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "NotificationRelatedData.h"
#import "NSDictionary+NullChecker.h"
#import "DTConstants.h"

@implementation NotificationRelatedData

+(NotificationRelatedData *)parseNotificationList:(NSDictionary *)NotificationList {
    NotificationRelatedData *notificationRowData = [[NotificationRelatedData alloc]init];
    
    notificationRowData.jobID = [NotificationList objectForKeyNotNull:pJobId expectedObj:@""];
    notificationRowData.notificationText = [NotificationList objectForKeyNotNull:pText expectedObj:@""];
    notificationRowData.senderID = [NotificationList objectForKeyNotNull:pSender expectedObj:@""];
    notificationRowData.receiverID = [NotificationList objectForKeyNotNull:pReceiver expectedObj:@""];
    notificationRowData.approvedSt = [NotificationList objectForKeyNotNull:pApprovedSt expectedObj:@""];
    notificationRowData.type = [NotificationList objectForKeyNotNull:pType expectedObj:@""];
    notificationRowData.createdAt = [NotificationList objectForKeyNotNull:pCreatedAt expectedObj:@""];
    notificationRowData.userType = [NotificationList objectForKeyNotNull:pUserTYpe expectedObj:@""];
    
    notificationRowData.block_status = [NotificationList objectForKeyNotNull:pblock_status expectedObj:@""];

    return notificationRowData;
}

@end
