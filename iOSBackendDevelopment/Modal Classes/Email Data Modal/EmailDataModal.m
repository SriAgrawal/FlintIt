//
//  EmailDataModal.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 09/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "EmailDataModal.h"
#import "NSDictionary+NullChecker.h"
#import "DTConstants.h"
#import "HeaderFile.h"

@implementation EmailDataModal

+(EmailDataModal *)parseEmailList:(NSDictionary *)EmailList {
    EmailDataModal *emailRowData = [[EmailDataModal alloc]init];
    
    emailRowData.emailID = [EmailList objectForKeyNotNull:pID expectedObj:@""];
    emailRowData.conversationID = [EmailList objectForKeyNotNull:pConversation expectedObj:@""];
    emailRowData.senderID = [EmailList objectForKeyNotNull:pSender expectedObj:@""];
    emailRowData.receiverID = [EmailList objectForKeyNotNull:pReceiver expectedObj:@""];
    emailRowData.emailMessage = [EmailList objectForKeyNotNull:pMessage expectedObj:@""];
    emailRowData.emailSubject = [EmailList objectForKeyNotNull:pSubject expectedObj:@""];
    emailRowData.userName = [EmailList objectForKeyNotNull:pUserName expectedObj:@""];
    emailRowData.createdDate = [EmailList objectForKeyNotNull:pCreatedOn expectedObj:@""];
    emailRowData.profileImage = [EmailList objectForKeyNotNull:pProfileImage expectedObj:@""];
    emailRowData.userProfileImageURL = [NSURL URLWithString:emailRowData.profileImage];
    emailRowData.serviceStartTime = [EmailList objectForKeyNotNull:pCreatedOn expectedObj:@""];
    
    emailRowData.blockStatus = [EmailList objectForKeyNotNull:@"block_status"expectedObj:@""];
    
    emailRowData.serviceDate = [AppUtilityFile convertTimeStampIntoDate:emailRowData.serviceStartTime];
    emailRowData.serviceTime = [AppUtilityFile convertingTimeStampIntoTime:emailRowData.serviceStartTime];

    return emailRowData;
}

@end

@implementation EmailListModal

@end
