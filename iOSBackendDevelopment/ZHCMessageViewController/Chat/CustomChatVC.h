//
//  CustomChatVC.h
//  iOSBackendDevelopment

//  Created by Anand Yadav on 16/10/23.
//  Copyright © 2016 Mobiloitte. All rights reserved.

#import "ZHCMessages.h"
#import "ZHCModelData.h"
#import "SCAvatarBrowser.h"

@class RowDataModal;

@interface CustomChatVC : ZHCMessagesViewController

@property (strong, nonatomic) ZHCModelData *demoData;
@property (assign, nonatomic) BOOL presentBool;
@property (strong, nonatomic) RowDataModal *userProfileDetail;
@end
