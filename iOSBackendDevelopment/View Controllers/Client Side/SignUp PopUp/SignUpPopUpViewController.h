//
//  SignUpPopUpViewController.h
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 12/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DelegateForSign <NSObject>

-(void)callSignUpServiceAgain:(BOOL)isComingFromSocialLogin;

@end

@interface SignUpPopUpViewController : UIViewController

@property (strong, nonatomic) id delegate;
@property (assign, nonatomic) BOOL isComingFromSocial;

@end
