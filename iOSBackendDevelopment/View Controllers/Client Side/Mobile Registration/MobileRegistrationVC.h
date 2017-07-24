//
//  MobileRegistrationVC.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
@protocol DegeateForNavigateFurther <NSObject>

-(void)methodForNavigateToHome;

@end

@interface MobileRegistrationVC : UIViewController

@property(assign,nonatomic) BOOL isComingFromLogin;
@property(strong,nonatomic) NSString *otpNumber;
@property (strong, nonatomic) UserInfo *modalObject;
@property(strong,nonatomic) id delegate;

@end
