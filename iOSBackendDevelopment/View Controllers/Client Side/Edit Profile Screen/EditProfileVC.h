//
//  EditProfileVC.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@protocol DelegateForUpdateClientProfile <NSObject>

-(void)methodForUpdateClientDetail:(UserInfo *)userDetail;

@end

@interface EditProfileVC : UIViewController

@property (strong, nonatomic) UserInfo *editModalObject;
@property (assign, nonatomic) BOOL isComingFromSocialLogin;

@property(strong,nonatomic) id delegate;

@end

