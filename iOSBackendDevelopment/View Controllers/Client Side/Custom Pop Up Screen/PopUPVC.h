//
//  PopUPVC.h
//  IdeaPlayInterface
//
//  Created by Abhishek Agarwal on 19/04/16.
//  Copyright © 2016 Mobiloitte Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RowDataModal;
@class ServiceTrackingModal;

@protocol DelegateAfterRequestSend <NSObject>

-(void)comingFromRequest;
-(void)comingFromSendRequestWithJobId:(NSString*)jobId;

@end

@interface PopUPVC : UIViewController

@property (assign,nonatomic) BOOL isCancelRequest;
@property (strong, nonatomic) RowDataModal *particularServiceProviderDetailInSendRequest;
@property (strong,nonatomic) id delegate;

@end
