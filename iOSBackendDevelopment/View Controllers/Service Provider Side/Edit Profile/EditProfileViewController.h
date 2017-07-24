//
//  EditProfileViewController.h
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 12/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@protocol DelegateForUpdateProfile <NSObject>

-(void)methodForUpdateDetail:(UserInfo *)userDetail;

@end

@interface EditProfileViewController : UIViewController

@property (strong,nonatomic) UserInfo *modalObject;
@property(strong,nonatomic) id delegate;
@property (assign, nonatomic) BOOL isComingFromSocialLogin;

@end
