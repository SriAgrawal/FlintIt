//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"
#import "FTLocationManager.h"
#import "HeaderFile.h"
#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"
#import "AppDelegate.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker  {
  
}

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            _locationManager.pausesLocationUpdatesAutomatically = NO;
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    [self updateLocationToServer];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");
	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        [[AlertView sharedManager]displayInformativeAlertwithTitle:@"Location Services Disabled" andMessage:@"You currently have all location services for this device disabled" onController:[APPDELEGATE navController]];
        
//		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		[servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [locationManager requestWhenInUseAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
    }
}

- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
//    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        [APPDELEGATE setLatitude:[NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude]];
        [APPDELEGATE setLongitude:[NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude]];
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;

            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
        }
    }
    
    //This is the timer to update the user location in every 15 min

    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];

    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
//    if (self.shareModel.delay10Seconds) {
//        [self.shareModel.delay10Seconds invalidate];
//        self.shareModel.delay10Seconds = nil;
//    }
//    
//    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:300 target:self
//                                                    selector:@selector(stopLocationDelayBy10Seconds)
//                                                    userInfo:nil
//                                                     repeats:NO];

}

//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"Network Error" andMessage:@"Please check your network connection." onController:[APPDELEGATE navController]];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
        }
            break;
        case kCLErrorDenied:{
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"Enable Location Service" andMessage:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" onController:[APPDELEGATE navController]];

//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


//Send the location to Server
- (void)updateLocationToServer {
    
    //NSLog(@"updateLocationToServer");
    // Find the best location from the array based on accuracy
    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    for(int i=0;i<self.shareModel.myLocationArray.count;i++) {
        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        if(i==0)
            myBestLocation = currentLocation;
        else{
            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
                myBestLocation = currentLocation;
            }
        }
    }
    NSLog(@"My Best location:%@",myBestLocation);
    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the serverÏ√
    if(self.shareModel.myLocationArray.count==0)
    {
        NSLog(@"Unable to get location, use the last known location");
        self.myLocation=self.myLastLocation;
        self.myLocationAccuracy=self.myLastLocationAccuracy;
    }else{
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
        self.myLocation=theBestLocation;
        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
    }
    
    [APPDELEGATE setLatitude:[NSString stringWithFormat:@"%.8f",self.myLocation.latitude]];
    [APPDELEGATE setLongitude:[NSString stringWithFormat:@"%.8f",self.myLocation.longitude]];
    NSLog(@"latititude-----%@",[APPDELEGATE latitude]);
    NSLog(@"longitude-----%@",[APPDELEGATE longitude]);
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:[[FTLocationManager sharedManager] location] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error)
        {
            if ( [TRIM_SPACE([NSUSERDEFAULT valueForKey:@"userID"]) length]) {
                NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
                [parameterDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
                [parameterDict setValue:[APPDELEGATE latitude]  forKey:pLattitue];
                [parameterDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
                [parameterDict setValue:@"" forKey:pAddress];
                NSLog(@"address----%@",[parameterDict valueForKey:pAddress]);
                [self callAPIToUpdateUserLocation:parameterDict];
            }
            
        }
        else {
            CLPlacemark *placemark = [placemarks lastObject];
            //                        [[NSUserDefaults standardUserDefaults] setObject:placemark.addressDictionary[ @"FormattedAddressLines"] forKey:@"address"];
            //                        [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ( [TRIM_SPACE([NSUSERDEFAULT valueForKey:@"userID"]) length]) {
                NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
                [parameterDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
                [parameterDict setValue:[APPDELEGATE latitude]  forKey:pLattitue];
                [parameterDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
                [parameterDict setValue:placemark.addressDictionary[ @"FormattedAddressLines"] forKey:pAddress];
                NSLog(@"address----%@",[parameterDict valueForKey:pAddress]);
                [self callAPIToUpdateUserLocation:parameterDict];
            }
            
        }
        
    }];

    //NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
    //Call API to Update Location
    
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
    
}

#pragma mark - Web API Method
#pragma mark - Service Implementation Methods

-(void)callAPIToUpdateUserLocation:(NSMutableDictionary*)dictTemp {
    
    
    [dictTemp setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [dictTemp setObject:[NSUSERDEFAULT valueForKey:pDeviceToken] forKey:pDeviceToken];
    [dictTemp setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    OPServiceHelper * helper = [[OPServiceHelper alloc] init];
    [helper PostAPICallWithParameter:dictTemp apiName:@"User/update_lat_long" WithComptionBlock:^(id result, NSError *error) {
    }];
}


@end
