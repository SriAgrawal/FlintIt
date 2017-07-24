//
//  ProviderLocationViewController.h
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 19/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RowDataModal.h"


@protocol DelegateAfterRequestCancel <NSObject>

-(void)delegateAfterComingFromRequest : (RowDataModal *)rowDataModalObj;

@end

@interface ProviderLocationViewController : UIViewController

//@property (strong, nonatomic) RowDataModal *particularDetail;
@property (strong, nonatomic) NSString *block_status;

@property (strong, nonatomic) RowDataModal *particularDetail;
@property (strong, nonatomic) RowDataModal *userDetail;

@property (strong,nonatomic)NSString * providerJobStatus;
@property (strong, nonnull) NSString *jobId;
@property (strong, nonnull) NSString *userId;
@property (assign, nonatomic) BOOL isFromNotificationScreen;
@property (assign, nonatomic) BOOL isHideCancelButton;
@property (assign, nonatomic) BOOL isFromNotificationList;


@property (assign, nonatomic) id <DelegateAfterRequestCancel> delegate;

@end
