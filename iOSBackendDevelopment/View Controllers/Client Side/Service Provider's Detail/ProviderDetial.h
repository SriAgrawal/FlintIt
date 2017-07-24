//
//  ProviderDetia.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 08/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RowDataModal.h"

@protocol DelegateAfterChangeTheServiceProviderStatus <NSObject>

-(void)changeInTheServiceProviderDetail:(RowDataModal *)serviceProviderDetail;

@end

@interface ProviderDetial : UIViewController

@property (strong, nonatomic) RowDataModal *particularServiceProviderDetail;
@property (assign, nonatomic) BOOL isComingFromMenuServiceTracking;
@property (assign, nonatomic) BOOL isFromNotificationScreen;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) id delegate;


@property (strong, nonatomic) NSString *block_status;

//Bool to check the notification flow and manage navigation
@property (assign, nonatomic) BOOL isRemoteNotificationFlow;
@end

