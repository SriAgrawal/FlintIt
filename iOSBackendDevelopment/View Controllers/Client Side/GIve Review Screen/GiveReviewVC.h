//
//  GiveReviewVC.h
//  iOSBackendDevelopment
//
//  Created by admin on 09/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationRelatedData.h"
#import "RowDataModal.h"

@interface GiveReviewVC : UIViewController

@property (strong, nonatomic) NotificationRelatedData *particularReviewDetail;
@property (strong, nonatomic) RowDataModal *reviewDetail;
@property (strong, nonatomic) id delegate;


@end
