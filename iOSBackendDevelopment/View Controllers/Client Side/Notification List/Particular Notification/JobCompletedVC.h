//
//  CancelledJobNotificationVC.h
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationRelatedData.h"
#import "RowDataModal.h"

@interface JobCompletedVC : UIViewController

@property (strong, nonatomic) NotificationRelatedData *particularNotificationDetail;
@property (strong,nonatomic)  RowDataModal *particularServiceIdDetail;
@property (strong, nonatomic) id delegate;


//dict to manage from Notification tap
@property (strong, nonatomic) NSDictionary *dictNotificationInfo;


@end
