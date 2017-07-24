//
//  AppDelegate.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 21/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/SignIn.h>
#import <UserNotifications/UserNotifications.h>
#import "CustomChatVC.h"
#import "Reachability.h"
@import GoogleMaps;

@interface AppDelegate ()<CLLocationManagerDelegate, UNUserNotificationCenterDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [GMSServices provideAPIKey:@"AIzaSyDUzk-L3_RXcw6uj8dHSckSalbmQjy1DvY"];
    [GIDSignIn sharedInstance].clientID = @"529318143244-n0b78v8mke9scvsqe6me77v3urrodcue.apps.googleusercontent.com";
    

    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [self checkReachability];
    
    //register For Notification
    [self setupNotification];
    
    //Initail SetUp
    [self setupForApplicationLaunch];
    [self initializeSocketObject];
    [self.window makeKeyAndVisible];
    /**********Print Font Family *******************************
     
     NSArray *fontFamilies = [UIFont familyNames];
     
     for (int i = 0; i < [fontFamilies count]; i++)
     
     {
     
     NSString *fontFamily = [fontFamilies objectAtIndex:i];
     
     NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
     
     NSLog (@"fontFamily === >> %@: fontNames ===>> %@", fontFamily, fontNames);
     
     }****************************************************************/
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    //Manage location
    [self manageUserLocation];
    
    //QB
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    self.countryCode = nil;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //    [self checkLocationStatus];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helper Method
-(void)initializeSocketObject{
    
    NSURL* url = [[NSURL alloc] initWithString:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/"];
    self.socket = [[SocketIOClient alloc] initWithSocketURL:url config:nil];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)setupForApplicationLaunch {
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // [NSThread sleepForTimeInterval:2];
    // set app language as 'en'
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    //  self.navController = [[UINavigationController alloc] initWithRootViewController:[[MapScreenVC alloc] initWithNibName:@"MapScreenVC" bundle:nil]];
    NSMutableDictionary *dict ;
    
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dict = [NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"];
    }else {
        dict = [NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"];
    }
    
    if ([[dict valueForKey:@"isOTPVerified"] isEqualToString:@"YES"] || dict == nil) {
        if (dict == nil) {
            self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil]];
        }else{
            self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil]];
            
            [self.navController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:NO];
        }
    }else {
        self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil]];
    }
    
    [self.navController setHidesBarsWhenKeyboardAppears:YES];
    [self.navController setNavigationBarHidden:YES];
    [self.window setRootViewController:self.navController] ;
    
}

// logout when user is deleted from database
-(void)navigateToLoginWhenSessionOut:(NSString *)message
{
    [self performSelector:@selector(performWithDelay:) withObject:message afterDelay:0.5];

}

-(void)performWithDelay:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        LoginVC *loginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
        // logout from mongo DB
        [self requestDictToLogoutFromMongoDB];
        if (self.navController) {
            [self.navController setViewControllers:@[loginVC] animated:NO];
            
        }else{
            self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil]];
        }
        [NSUSERDEFAULT removeObjectForKey:@"userID"];
        // [NSUSERDEFAULT synchronize];
        [NSUSERDEFAULT removeObjectForKey:@"ClientUserInfoDictionary"];
        [NSUSERDEFAULT removeObjectForKey:@"ServiceUserInfoDictionary"];
        [NSUSERDEFAULT synchronize];
        [self.window setRootViewController:self.navController];
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:message andButtonsWithTitle:@[@"OK"] onController:[[APPDELEGATE window] rootViewController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            
        }];
    });
}
// logout when user is login in another device
-(void)navigateToLoginWhenSessionOutDevice:(NSString *)message
{
    [self performSelector:@selector(performWithDelayLogout:) withObject:message afterDelay:0.5];
    
}

-(void)performWithDelayLogout:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        LoginVC *loginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
        // logout from mongo DB commented so that notification doe's not stop on another device
        // [self requestDictToLogoutFromMongoDB];
        if (self.navController) {
            [self.navController setViewControllers:@[loginVC] animated:NO];
            
        }else{
            self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil]];
        }
        [NSUSERDEFAULT removeObjectForKey:@"userID"];
        // [NSUSERDEFAULT synchronize];
        [NSUSERDEFAULT removeObjectForKey:@"ClientUserInfoDictionary"];
        [NSUSERDEFAULT removeObjectForKey:@"ServiceUserInfoDictionary"];
        [NSUSERDEFAULT synchronize];
        [self.window setRootViewController:self.navController];
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:message andButtonsWithTitle:@[@"OK"] onController:[[APPDELEGATE window] rootViewController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            
        }];
    });
}


// logout from mongo DB
-(void)requestDictToLogoutFromMongoDB{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"removeToken" WithComptionBlock:^(id result, NSError *error) {
        NSLog(@"hello user logout %@",result);
    }];
}

#pragma mark - Methods For Device Token



-(void)setupNotification {
    
    //-- Set Notification
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |UIUserNotificationTypeBadge |UIUserNotificationTypeSound);
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    NSString *mytoken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *myTokenString = [mytoken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setValue:myTokenString forKey:pDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"0dcf2baf8925fc8901293a92545681f886e634830ec61b913b69715af05b159a" forKey:pDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSDictionary *notificationDict;
    
    
    if(userInfo[@"aps"][@"server"])
         notificationDict = userInfo[@"aps"][@"server"];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        
        if ([notificationDict[@"type"] isEqualToString:@"request"]) {
            [self handleNotificationForRequestJob:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"approved"]) {
            [self handleNotificationForApproved:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"accept"]) {
            [self handleNotificationForAccept:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"complete"]) {
            [self handleNotificationForComplete:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"cancel"]) {
            [self handleNotificationForCancel:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        if ([notificationDict[@"type"] isEqualToString:@"request"]) {
            [self handleNotificationForRequestJob:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"approved"]) {
            [self handleNotificationForApproved:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"accept"]) {
            [self handleNotificationForAccept:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"complete"]) {
            [self handleNotificationForComplete:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }else if ([notificationDict[@"type"] isEqualToString:@"cancel"]) {
            [self handleNotificationForCancel:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
        }
    }
    
    NSString *strUserID = userInfo[@"otheruserid"];
    NSString *strType = userInfo[@"type"];
    NSString *strUserName = userInfo[@"userName"];
    NSString *strUserImage = userInfo[@"receiverImage"];

    if(!notificationDict) {
        notificationDict = [[NSDictionary alloc]initWithObjectsAndKeys: strUserID,@"senderId",strType,@"type", strUserName,@"username", strUserImage, @"userImage", nil];
    }
    if([strType isEqualToString:@"message"] || [strType isEqualToString:@"media"] || [strType isEqualToString:@"audio"] || [strType isEqualToString:@"location"]){
        [self handleNotificationForChat:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController]isFromDidReceiveRemote:YES];
    }
 
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //completionHandler(UNNotificationPresentationOptionAlert);
    NSDictionary *notificationDict;
    
    
    if(notification.request.content.userInfo[@"aps"][@"server"])
        notificationDict = notification.request.content.userInfo[@"aps"][@"server"];

    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    //    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:[NSString stringWithFormat:@"%@",notification.request.content.userInfo[@"type"]] onController:[[APPDELEGATE window] rootViewController]];
    
    if ([notificationDict[@"type"] isEqualToString:@"complete"]) {
        [self handleNotificationForComplete:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:YES];
    } else {
        completionHandler(UNNotificationPresentationOptionAlert);
    }
    // [self handlePushNotification:notification.request.content.userInfo];
    //   completionHandler(UNNotificationPresentationOptionAlert);
    
    // Fire notification to update all list.
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateData" object:nil];
    
}


#pragma mark - UNUserNotificationCenterDelegate method

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSDictionary *notificationDict;
    
    if(response.notification.request.content.userInfo[@"aps"][@"server"])
        notificationDict = response.notification.request.content.userInfo[@"aps"][@"server"];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        
        if ([notificationDict[@"type"] isEqualToString:@"request"]) {
            [self handleNotificationForRequestJob:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"approved"]) {
            [self handleNotificationForApproved:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"accept"]) {
            [self handleNotificationForAccept:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"complete"]) {
            [self handleNotificationForComplete:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"cancel"]) {
            [self handleNotificationForCancel:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"email"]){
         [self handleNotificationForEmail:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        if ([notificationDict[@"type"] isEqualToString:@"request"]) {
            [self handleNotificationForRequestJob:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"approved"]) {
            [self handleNotificationForApproved:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"accept"]) {
            [self handleNotificationForAccept:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"complete"]) {
            [self handleNotificationForComplete:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }else if ([notificationDict[@"type"] isEqualToString:@"cancel"]) {
            [self handleNotificationForCancel:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }
        else if ([notificationDict[@"type"] isEqualToString:@"email"]){
            [self handleNotificationForEmail:notificationDict andIsActiveOrInactive:NO andController:[APPDELEGATE navController] isFromDidReceiveRemote:NO];
        }
    }
    NSString *strUserID = response.notification.request.content.userInfo[@"otheruserid"];
    NSString *strType = response.notification.request.content.userInfo[@"type"];
    NSString *strUserName = response.notification.request.content.userInfo[@"userName"];
    NSString *strUserImage = response.notification.request.content.userInfo[@"receiverImage"];
//    if (!strUserName) {
//        strUserName = @"lalit";
//    }
    
    if(!notificationDict) {
        notificationDict = [[NSDictionary alloc]initWithObjectsAndKeys: strUserID,@"senderId",strType,@"type", strUserName,@"username",strUserImage, @"userImage", nil];
    }
    if([strType isEqualToString:@"message"] || [strType isEqualToString:@"media"] || [strType isEqualToString:@"audio"] || [strType isEqualToString:@"location"]){
        
        [self handleNotificationForChat:notificationDict andIsActiveOrInactive:YES andController:[APPDELEGATE navController]isFromDidReceiveRemote:YES];
    }
}

// Request job***********

-(void)handleNotificationForRequestJob:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive{
    
//    [[AlertView sharedManager]displayInformativeAlertwithTitle:@"" andMessage:@"handleNotificationForRequestJob" onController:[APPDELEGATE navController]];
    
    if (isActive) {
        if ([dict[@"user_type"] isEqualToString:@"client"]) {
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[AcceptedJobVC class]]) {
                
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }else {
                if(isFromDidReceive) {
                    // Asking user before Navigate
                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                        if(index == 0) {
                            // You are in different controller and now you push to chat controller
                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                            acceptJobVC.userDict = dict;
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                    }];
                }else {
                    // You are in different controller and now you push to chat controller
                    AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                    acceptJobVC.userDict = dict;
                    [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                }
            }
        }
    }
    else {
        if ([dict[@"user_type"] isEqualToString:@"client"]) {
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[AcceptedJobVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }else {
                
                    // You are in different controller and now you push to chat controller
                    AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                    acceptJobVC.userDict = dict;
                    [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
            }
        }
    }
}

// Approve job***********
-(void)handleNotificationForApproved:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive{
    if (isActive) {
        if ([dict[@"user_type"] isEqualToString:@"client"]) {
            
            NSString *strAlert = [dict valueForKey:@"text"];
            if(isFromDidReceive)
                [[AlertView sharedManager]displayInformativeAlertwithTitle:@"" andMessage:strAlert onController:[APPDELEGATE navController]];
            
               }
         }
  }


// Accept job***********
-(void)handleNotificationForAccept:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive{
    
    if (isActive) {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[AcceptedJobVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }
            else {
                
                [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Service Tracking"), KNSLOCALIZEDSTRING(@"View later"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                    switch (index) {
                        case 0:{
                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                            acceptJobVC.userDict = dict;
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
                        case 1:{
                            ServiceTrackingVC *acceptJobVC = [[ServiceTrackingVC alloc] initWithNibName:@"ServiceTrackingVC" bundle:nil];
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
                        default:
                            break;
                    }
                }];
//                if(isFromDidReceive) {
//                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//                        if(index == 0) {
//                            // You are in different controller and now you push to chat controller
//                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
//                            acceptJobVC.userDict = dict;
//                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                        }
//                    }];
//                }
//                else {
//                    
//                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View later"), KNSLOCALIZEDSTRING(@"View profile"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//                        if(index) {
//                            // You are in different controller and now you push to chat controller
//                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
//                            acceptJobVC.userDict = dict;
//                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                        }
//                    }];
//                    // You are in different controller and now you push to chat controller
////                    AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
////                    acceptJobVC.userDict = dict;
////                    [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                }
            }
        }
    }
    else {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[AcceptedJobVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }
            else {
                
                [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Service Tracking"), KNSLOCALIZEDSTRING(@"View later"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                    
                    switch (index) {
                        case 0:{
                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                            acceptJobVC.userDict = dict;
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
                        case 1:{
                            
                            ServiceTrackingVC *acceptJobVC = [[ServiceTrackingVC alloc] initWithNibName:@"ServiceTrackingVC" bundle:nil];
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
        }
    }
}

// Complete job***********
-(void)handleNotificationForComplete:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive{
    
    NSDictionary *userInfo = dict;
    
    if (isActive) {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[JobCompletedVC class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }
            else {
                if(isFromDidReceive) {
                    
                    JobCompletedVC *completedJobVC = [[JobCompletedVC alloc] initWithNibName:@"JobCompletedVC" bundle:nil];
                    [completedJobVC setDictNotificationInfo:userInfo];
                    [[APPDELEGATE navController] pushViewController:completedJobVC animated:YES];
                    
                    // commenting for a testing 15Mar17
//                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//                        if(index == 0) {
//                            // You are in different controller and now you push to chat controller
//                            JobCompletedVC *completedJobVC = [[JobCompletedVC alloc] initWithNibName:@"JobCompletedVC" bundle:nil];
//                            [completedJobVC setDictNotificationInfo:userInfo];
//                            [[APPDELEGATE navController] pushViewController:completedJobVC animated:YES];
//                        }
//                    }];
                }
                else {
                    // You are in different controller and now you push to chat controller
                    JobCompletedVC *completedJobVC = [[JobCompletedVC alloc] initWithNibName:@"JobCompletedVC" bundle:nil];
                    [completedJobVC setDictNotificationInfo:userInfo];
                    [[APPDELEGATE navController] pushViewController:completedJobVC animated:YES];
                }
            }
        }
    }
    else {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[JobCompletedVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }else {
                
                if(isFromDidReceive) {
                    // You are in different controller and now you push to chat controller
                    JobCompletedVC *completedJobVC = [[JobCompletedVC alloc] initWithNibName:@"JobCompletedVC" bundle:nil];
                    [completedJobVC setDictNotificationInfo:userInfo];
                    [[APPDELEGATE navController] pushViewController:completedJobVC animated:YES];
                }
                else {
                    // You are in different controller and now you push to chat controller
                    JobCompletedVC *completedJobVC = [[JobCompletedVC alloc] initWithNibName:@"JobCompletedVC" bundle:nil];
                    [completedJobVC setDictNotificationInfo:userInfo];
                    [[APPDELEGATE navController] pushViewController:completedJobVC animated:YES];
                }
            }
        }
    }
}

// Cancel job***********
-(void)handleNotificationForCancel:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive{
    
    if (isActive) {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[JobCancelledVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
                return;
            }
            else {
                // working fine
                [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                    
                    switch (index) {
                        case 0:{
                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                            acceptJobVC.isJobCanceled = YES;
                            acceptJobVC.userDict = dict;
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
//                        case 1:{
//                            ServiceTrackingViewController *acceptJobVC = [[ServiceTrackingViewController alloc] initWithNibName:@"ServiceTrackingViewController" bundle:nil];
//                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                        }
//                            break;
                        default:
                            break;
                    }
                }];
//                if(isFromDidReceive) {
//                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"OK"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//                        if(index == 0) {
////                            // You are in different controller and now you push to chat controller
////                            JobCancelledVC *cancelJobVC = [[JobCancelledVC alloc] initWithNibName:@"JobCancelledVC" bundle:nil];
////                            cancelJobVC.userDict = dict;
////                            [[APPDELEGATE navController] pushViewController:cancelJobVC animated:YES];
//                        }
//                    }];
//                }
//                else {
//                    // You are in different controller and now you push to chat controller
////                    JobCancelledVC *cancelJobVC = [[JobCancelledVC alloc] initWithNibName:@"JobCancelledVC" bundle:nil];
////                    cancelJobVC.userDict = dict;
////                    [[APPDELEGATE navController] pushViewController:cancelJobVC animated:YES];
//                }
            }
        }
        else if ([dict[@"user_type"] isEqualToString:@"client"]) {
           // addded
            //in case client cancel the job provider will get a notification and this method will be called
            // working fine
            [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                
                switch (index) {
                    case 0:
                    {
                        AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                        acceptJobVC.isJobCanceled = YES;
                        acceptJobVC.userDict = dict;
                        [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                    }
                        break;
                        
//                    case 1:
//                    {
//                        ServiceTrackingVC *acceptJobVC = [[ServiceTrackingVC alloc] initWithNibName:@"ServiceTrackingVC" bundle:nil];
//                        [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                    }
//                        break;
                        
                    default:
                        break;
                }
            }];
        }
    }else {
        if ([dict[@"user_type"] isEqualToString:@"provider"]) {
            if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[JobCancelledVC class]]) {
                NSDictionary *userInfo = dict;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"refreshProviderDetails" object:nil userInfo:userInfo];
            }
            else {
                // working fine
                [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                    switch (index) {
                        case 0:
                        {
                            AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                            acceptJobVC.isJobCanceled = YES;
                            acceptJobVC.userDict = dict;
                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                        }
                            break;
                            
//                        case 1:
//                        {
//                            ServiceTrackingViewController *acceptJobVC = [[ServiceTrackingViewController alloc] initWithNibName:@"ServiceTrackingViewController" bundle:nil];
//                            [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                        }
//                            break;
                            
                        default:
                            break;
                    }
                }];
//                if(isFromDidReceive) {
//                    
//                    [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"OK"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//                        if(index == 0) {
//                            // You are in different controller and now you push to chat controller
////                            JobCancelledVC *cancelJobVC = [[JobCancelledVC alloc] initWithNibName:@"JobCancelledVC" bundle:nil];
////                            cancelJobVC.userDict = dict;
////                            [[APPDELEGATE navController] pushViewController:cancelJobVC animated:YES];
//                        }
//                    }];
//                }
//                else {
//                    // You are in different controller and now you push to chat controller
////                    JobCancelledVC *cancelJobVC = [[JobCancelledVC alloc] initWithNibName:@"JobCancelledVC" bundle:nil];
////                    cancelJobVC.userDict = dict;
////                    [[APPDELEGATE navController] pushViewController:cancelJobVC animated:YES];
//                }
            }
        }
        else if ([dict[@"user_type"] isEqualToString:@"client"]) {
            [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@", dict[@"text"]] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View profile"), KNSLOCALIZEDSTRING(@"Cancel"),nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                switch (index) {
                    case 0:
                    {
                        AcceptedJobVC *acceptJobVC = [[AcceptedJobVC alloc] initWithNibName:@"AcceptedJobVC" bundle:nil];
                        acceptJobVC.isJobCanceled = YES;
                        acceptJobVC.userDict = dict;
                        [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
                    }
                        break;
                        
//                    case 1:
//                    {
//                        ServiceTrackingVC *acceptJobVC = [[ServiceTrackingVC alloc] initWithNibName:@"ServiceTrackingVC" bundle:nil];
//                        [[APPDELEGATE navController] pushViewController:acceptJobVC animated:YES];
//                    }
//                        break;
                        
                    default:
                        break;
                }
            }];
        }
    }
}

//For Email
- (void) handleNotificationForEmail:(NSDictionary *)dict andIsActiveOrInactive:(BOOL) isActive andController:(UINavigationController *)navController  isFromDidReceiveRemote:(BOOL)isFromDidReceive {
    NSString *strAlert = [dict valueForKey:@"text"];
      [[AlertView sharedManager]displayInformativeAlertwithTitle:@"" andMessage:strAlert onController:[APPDELEGATE navController]];
}

//for Chat Message
-(void)handleNotificationForChat:(NSDictionary *)dict andIsActiveOrInactive:(BOOL)isActive andController:(UINavigationController *)controller isFromDidReceiveRemote: (BOOL)isFromDidReceive {

    if(isFromDidReceive) {
        if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[CustomChatVC class]]) {
            NSDictionary *userInfo = dict;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"PushData" object:nil userInfo:userInfo];
        }else {
            
            CustomChatVC *chatVC = [[CustomChatVC alloc]init];
            chatVC.presentBool = NO;
            RowDataModal *data = [[RowDataModal alloc] init];
            data.userID = [dict objectForKeyNotNull:@"senderId" expectedObj:@""];
            data.userName = [dict objectForKeyNotNull:@"username" expectedObj:@""];
            
            //Other user image to be added
            data.userImage = [dict objectForKeyNotNull:@"userImage" expectedObj:@""];
            chatVC.userProfileDetail = data;
            [[APPDELEGATE navController] pushViewController:chatVC animated:YES];
        }
        
        
        //        [[AlertView sharedManager] presentAlertWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@", [dict valueForKey:@"username"], KNSLOCALIZEDSTRING(@"has sent a message to you.")] andButtonsWithTitle:[NSArray arrayWithObjects:KNSLOCALIZEDSTRING(@"View"), KNSLOCALIZEDSTRING(@"Cancel") ,nil] onController:[APPDELEGATE navController] dismissedWith:^(NSInteger index, NSString *buttonTitle) {
        //            if(index == 0) {
        //                CustomChatVC *chatVC = [[CustomChatVC alloc]init];
        //                chatVC.presentBool = NO;
        //                RowDataModal *data = [[RowDataModal alloc] init];
        //                data.userID = [dict valueForKey:@"senderId"];
        //                data.userName = [dict valueForKey:@"username"];
        //                chatVC.userProfileDetail = data;
        //                [[APPDELEGATE navController] pushViewController:chatVC animated:YES];
        //            }
        //        }];
    }
    else {
        if ([[[APPDELEGATE navController] topViewController] isKindOfClass:[CustomChatVC class]]) {
            NSDictionary *userInfo = dict;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"PushData" object:nil userInfo:userInfo];
        }else {
        CustomChatVC *chatVC = [[CustomChatVC alloc]init];
        chatVC.presentBool = NO;
        RowDataModal *data = [[RowDataModal alloc] init];
        data.userID = [dict objectForKeyNotNull:@"senderId" expectedObj:@""];
        data.userName = [dict objectForKeyNotNull:@"username" expectedObj:@""];
        
        //other user image to be added
        data.userImage = [dict objectForKeyNotNull:@"userImage" expectedObj:@""];
        chatVC.userProfileDetail = data;
        [[APPDELEGATE navController] pushViewController:chatVC animated:YES];
        }
    }

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.absoluteString containsString:@"fb"])
        
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    else {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
        
    }
}

#pragma mark - Handle Location
-(void)manageUserLocation {
    
   // UIAlertView * alert;
   // We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" onController:[APPDELEGATE navController]];
        
//        alert = [[UIAlertView alloc]initWithTitle:@""
//                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
//                                         delegate:nil
//                                cancelButtonTitle:@"Ok"
//                                otherButtonTitles:nil, nil];
//
//        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        NSLog(@"App in background==============");
    } else{
        
        //Handling user  location via LocationTracker helful class.
//        LocationTracker * locationTracker = [[LocationTracker alloc] init];
//        [locationTracker startLocationTracking];
//        //Update location initially.
//        [self updateLocation];
        //Updating Location after each 1 minute.
        
        // CURRETLY ITS 60 BUT CHANGING IT TO 15 AND DURING PRODUCTION IT WIIL BE 5
        // NSTimeInterval time = 60;
//        NSTimeInterval time = 15;
//
//        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//
//        self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:time
//                                         target:self
//                                       selector:@selector(updateLocation)
//                                       userInfo:nil
//                                        repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:self.locationUpdateTimer forMode:NSRunLoopCommonModes];
        
        
        [self createLocationManager];

        
        
        
        
    }
}
// New way to handle location update.

#pragma mark - CLLocation manager Delegate Methods

-(void)createLocationManager {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager setAllowsBackgroundLocationUpdates:YES];
    [locationManager setPausesLocationUpdatesAutomatically:NO];

    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [locationManager requestAlwaysAuthorization];
    
    [locationManager startUpdatingLocation];
}

-(void)startLocationManager {
    [locationManager startUpdatingLocation];
}

-(void)stopLocationManager {
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    if (locations.count) {
        self.location = [locations lastObject];

        [APPDELEGATE setLatitude:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude]];
        [APPDELEGATE setLongitude:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude]];
    }
    if ([[NSUSERDEFAULT valueForKey:@"userID"] integerValue]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getUnreadCount" object:nil];
        NSLog(@"getting count");
    }
    if (!self.countryCode) {
         [self getCountryCode];
    }
   
    if (self.locationUpdateTimer) {
        return;
    }

    NSTimeInterval time = 15;
    self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                                target:self
                                                              selector:@selector(callAPIToUpdateUserLocation)
                                                              userInfo:nil
                                                               repeats:NO];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"Enable Location Service" andMessage:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" onController:[APPDELEGATE navController]];
        }
    }
}
#pragma mark - Service Implementation Methods

-(void)callAPIToUpdateUserLocation {
    if (self.locationUpdateTimer) {
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
    }
    if ( ![TRIM_SPACE([NSUSERDEFAULT valueForKey:@"userID"]) length]) {
        return ;
    }
    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
    [parameterDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [parameterDict setValue:[APPDELEGATE latitude]  forKey:pLattitue];
    [parameterDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [parameterDict setValue:@"" forKey:pAddress];

    
    [parameterDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [parameterDict setObject:[NSUSERDEFAULT valueForKey:pDeviceToken] forKey:pDeviceToken];
    [parameterDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    
    OPServiceHelper * helper = [[OPServiceHelper alloc] init];
    [helper PostAPICallWithParameter:parameterDict apiName:@"User/update_lat_long" WithComptionBlock:^(id result, NSError *error) {
    }];
}
- (void)backgroundCleanDisk {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

//-(void)updateLocation {
//    [self.locationTracker updateLocationToServer];
//    if ([[NSUSERDEFAULT valueForKey:@"userID"] integerValue]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"getUnreadCount" object:nil];
//        NSLog(@"getting count");
//    }
//}
//
//-(void)startLocation {
//    [self.locationTracker startLocationTracking];
//}
//
//-(void)stopLocation {
//    [self.locationTracker stopLocationTracking];
//}


-(void)getCountryCode{
    
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        [reverseGeocoder reverseGeocodeLocation:[APPDELEGATE location] completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
        self.countryCode = myPlacemark.ISOcountryCode;
        
    }];
   
    
}




#pragma mark - Slider menu
-(JASidePanelController *)addRevealView {
    [self startLocationManager];
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
     if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        SelectChoiceVC *selectChoiceObj= [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
        self.viewController.centerPanel = selectChoiceObj;
        self.viewController.leftPanel = [[MenuVC alloc] initWithNibName:@"MenuVC" bundle:nil];
    }else {
        
        SelectChoiceViewController *serviceSelectChoiceObj= [[SelectChoiceViewController alloc]initWithNibName:@"SelectChoiceViewController" bundle:nil];
        self.viewController.centerPanel = serviceSelectChoiceObj;
        self.viewController.leftPanel = [[MenuSectionViewController alloc] initWithNibName:@"MenuSectionViewController" bundle:nil];
    }
     self.viewController.rightPanel = nil;
    return self.viewController;
}

#pragma mark - Reachability
-(void)checkReachability {
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    self.isReachable = [reach isReachable];
    reach.reachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = NO;
        });
    };
    
    [reach startNotifier];
}

-(void)callPostRequestWithParameters : (NSDictionary *)dict onURL : (NSString *)str
{
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL
                                                                            URLWithString:str]];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    [postRequest setHTTPBody:jsondata];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:postRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                            if(response)
                                                            {
                                                                //response
                                                                
                                                            }else {
                                                                //error
                                                            }
                                                        }];
    
    [dataTask resume];
}


@end
