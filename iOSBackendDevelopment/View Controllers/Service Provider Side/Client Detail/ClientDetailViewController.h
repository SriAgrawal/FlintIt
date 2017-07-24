//
//  ClientDetailViewController.h
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RowDataModal.h"

@protocol DelegateForListAfterAcceptAndDecline <NSObject>

-(void)methodForListAfterAcceptAndDecline:(RowDataModal *)particularClientDetail;

@end

@interface ClientDetailViewController : UIViewController

@property (strong, nonatomic) RowDataModal *particularClientDetail;
@property (assign, nonatomic) BOOL isFromNotificationScreen;
@property (assign, nonatomic) BOOL isHideAcceptCancelButton;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) id delegate;

@property (assign, nonatomic) BOOL isfromRemoteNotification;

@property (strong, nonatomic) NSString *block_status;

@end
