//
//  SocialHelper.m
//  Mit Up App
//
//  Created by Mahak  Mittal on 15/04/16.
//  Copyright (c) 2014 Mobiloitte Technologies. All rights reserved.
//

#import "SocialHelper.h"

static SocialHelper *socialHelperInstance;

@interface SocialHelper()<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

//@property (nonatomic, strong) socialCompletionBlock completionBlock;

@end

@implementation SocialHelper

+(SocialHelper *)sharedInstance{
    
    static dispatch_once_t ounce;
    dispatch_once(&ounce, ^{
        socialHelperInstance = [[SocialHelper alloc] init];
    });
    return socialHelperInstance;
}

SocialHelper *socialVC;
+ (SocialHelper*)sharedManager {
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        socialVC = [[SocialHelper alloc] init];
        //        socialVC.accountStore = [[ACAccountStore alloc] init];
    });
    return socialVC;
}


#pragma mark - Facebook methods

// This method will handle ALL the session state changes in the app

-(void)getFacebookInfoWithCompletionHandler:(socialCompletionBlock)handler{
    self.completionBlock = handler;
    
    if (![APPDELEGATE isReachable]){
        self.completionBlock(nil,@"Internet connection appears to be offline, try again.");
        return ;
    }
    
    [self callFacebookLoginWithCompletionBlock:^(NSDictionary *dict,NSString *error) {
        self.completionBlock(dict,error);
    }];
}

-(void)callFacebookLoginWithCompletionBlock:(socialCompletionBlock)block{
    socialCompletionBlock handler = block;
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    [self addHud];

    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"id,name,first_name,last_name,birthday,gender,email,picture.width(800).height(800),albums,cover" forKey:@"fields"]]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 handler(result,[error localizedDescription]);
             }
         }];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        [self removeHud];

        [login
         logInWithReadPermissions: @[@"email",@"public_profile",@"user_birthday"]
         fromViewController:[APPDELEGATE navController]
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 handler(nil,[error localizedDescription]);
                 NSLog(@"Cancelled");
             } else {
                 [self addHud];

         [FBSDKAccessToken setCurrentAccessToken:result.token];
         if ([FBSDKAccessToken currentAccessToken]) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"id,name,first_name,birthday,gender,last_name,email,picture.width(800).height(800),albums,cover" forKey:@"fields"]]
            startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
           if (!error) {
               [self removeHud];
                                 handler(result,[error localizedDescription]);
                                          }
                                      }];
                                 }
                             }
                         }];

             }
    }

-(void)addHud {
    //add HUD to the passed view controller's view
    [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] animated:YES];
    
  
}

-(void)removeHud {
    
    [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
}

-(void)getAlbumInfoWithCompletionHandler:(socialCompletionBlock)handler{
    socialCompletionBlock handlerAlbum = handler;
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/albums" parameters:[NSDictionary dictionaryWithObject:@"photos" forKey:@"fields"]]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             handlerAlbum(result,[error localizedDescription]);         }
     }];
}

@end
