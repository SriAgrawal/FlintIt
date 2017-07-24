//
//  AppDelegate.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 21/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "Flink_It-Swift.h"
#import <CoreLocation/CoreLocation.h>

#import "LocationTracker.h"
#import "LocationShareModel.h"
#import "BackgroundTaskManager.h"
#import "FTLocationManager.h"

@class JASidePanelController,INTULocationManager,INTULocationRequest;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
//@property (strong, nonatomic) INTULocationManager *customLocationManager;
@property(strong,nonatomic) NSString *latitude;
@property(strong,nonatomic) NSString *longitude;
@property(strong,nonatomic) NSString *str_location;
//@property LocationTracker *   locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property(strong,nonatomic) SocketIOClient* socket;
@property (assign, nonatomic) BOOL isReachable;
@property (strong, nonatomic) JASidePanelController  *viewController;

@property (nonatomic , strong)NSString  *countryCode;
@property (nonatomic, strong) CLLocation *location;


-(JASidePanelController *)addRevealView;
-(void)navigateToLoginWhenSessionOut:(NSString *)message;

// logout when loggedIn into another device.
-(void)navigateToLoginWhenSessionOutDevice:(NSString *)message;

// -(void)getCurrentLocation;
-(void)setupForApplicationLaunch;


-(void)stopLocationManager;
-(void)startLocationManager;

@property (assign, nonatomic) BOOL isTapOnImage;

@end

