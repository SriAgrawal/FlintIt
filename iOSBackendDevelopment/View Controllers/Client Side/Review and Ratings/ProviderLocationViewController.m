   //
//  ProviderLocationViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 19/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ProviderLocationViewController.h"
#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MacroFile.h"
#import "PopUPVC.h"
#import "UIViewController+CWPopup.h"
#import "GiveAReviewServiceSideVC.h"
#import "HeaderFile.h"

@interface ProviderLocationViewController ()<GMSMapViewDelegate> {
    NSMutableArray *array_locationDetail;
    ServiceTrackingModal *modalObject;
    NSTimer *timer;
    RowDataModal *particularDetailForHold;
}

@property(assign) BOOL isFirstTime;
@property (strong,nonatomic) NSString * serviceProviderID;
@property (strong,nonatomic) NSString * clientID;
@property (strong,nonatomic) NSString * jobID;

@property (weak, nonatomic) IBOutlet UIView *viewOuter;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *cancelJobProperty;
@property (weak, nonatomic) IBOutlet UIButton *btnMarkAsCompelete;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelJob;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *distanceInMile;
@property (weak, nonatomic) IBOutlet UILabel *time;

@end

@implementation ProviderLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
// Do any additional setup after loading the view from its nib.
    
    [self initialSetup];
    if (self.isFromNotificationScreen) {
        [self makeServiceCallToGetUserDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialSetup {
    // To Hold Data
    particularDetailForHold = [[RowDataModal alloc] init];
    particularDetailForHold = self.particularDetail;
    
    _serviceProviderID = self.particularDetail.ServiceProviderId;
    _clientID =self.particularDetail.clientID;
    _jobID = _particularDetail.jobID;
    _navTitle.text = KNSLOCALIZEDSTRING(@"Provider Current Location");
    [self.btnCancelJob setTitle:KNSLOCALIZEDSTRING(@"Cancel Job") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }

    
    [self.cancelJobProperty.layer setCornerRadius:25.0];
    [self.btnMarkAsCompelete.layer setCornerRadius:25.0];
    [self.btnCancelJob.layer setCornerRadius:25.0];

    [self.viewOuter setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    
    self.mapView.delegate = self;
    
    [self.btnMarkAsCompelete setTitle:KNSLOCALIZEDSTRING(@"Mark as Completed") forState:UIControlStateNormal];
    [self.cancelJobProperty setTitle:KNSLOCALIZEDSTRING(@"Cancel Job") forState:UIControlStateNormal];


    if(_particularDetail.serviceDistanceDetail.length)
        [self.distanceInMile setText:_particularDetail.serviceDistanceDetail];
    else
        [self.distanceInMile setText:_particularDetail.userDistance];
    
    [self.time setText:_particularDetail.serviceTimeLeft];
    

    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        [self.btnCancelJob setHidden:NO];
        [self.cancelJobProperty setHidden:YES];
        [self.btnMarkAsCompelete setHidden:YES];

        if ([_particularDetail.jobStatusString isEqualToString:@"completed"]) {
//        [self.navTitle setText:KNSLOCALIZEDSTRING(@"Approve")];
            //change
            [self.navTitle setText:KNSLOCALIZEDSTRING(@"Provider Current Location")];

        [self.btnCancelJob setTitle:KNSLOCALIZEDSTRING(@"Approve") forState:UIControlStateNormal] ;
        [self.btnCancelJob setBackgroundColor:[UIColor colorWithRed:50/255.0f green:170/255.0f blue:144/255.0f alpha:1.0]] ;
        }else{
        [self.navTitle setText:KNSLOCALIZEDSTRING(@"Provider Current Location")];
        [_btnCancelJob setTitle:KNSLOCALIZEDSTRING(@"Cancel Job") forState:UIControlStateNormal];
        }
        
        if(_particularDetail.serviceProviderName.length)
            [self.name setText:_particularDetail.serviceProviderName];
        else
            [self.name setText:_particularDetail.userName];
        
    }else {
        [self.navTitle setText:KNSLOCALIZEDSTRING(@"Client Current Location")];
        [self.name setText:@"Client Name"];
        if (self.isFromNotificationScreen){
        [self.cancelJobProperty setHidden:self.isHideCancelButton];
        [self.btnMarkAsCompelete setHidden:self.isHideCancelButton];
        }else{
            [self.cancelJobProperty setHidden:NO];
            [self.btnMarkAsCompelete setHidden:NO];
        }
        [self.btnCancelJob setHidden:YES];
        if ([_providerJobStatus isEqualToString:@"completed"]) {
            [self.btnCancelJob setHidden:YES];
            [self.cancelJobProperty setHidden:YES];
            [self.btnMarkAsCompelete setHidden:YES];
        }
        [self.name setText:(self.isFromNotificationScreen)?_particularDetail.userName:_particularDetail.clientName];
    }
    
    array_locationDetail = [[NSMutableArray alloc]init];
    modalObject = [[ServiceTrackingModal alloc]init];
    [self updateLocation];
    [self showAllLocationDetail];
    
//    [self requestDictForServiceTracking];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(requestDictForServiceTracking) userInfo:nil repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated {
//    array_locationDetail = [[NSMutableArray alloc]init];
    [super viewDidAppear:animated];
    if (![APPDELEGATE isReachable]) {
        [self updateLocation];
        [self showAllLocationDetail];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [timer invalidate];
}

-(void)updateLocation{
    
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        
        NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
        [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
        [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
        
        NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
        [locationDictionary2 setValue:self.particularDetail.userLatitute forKey:@"lattitue"];
        [locationDictionary2 setValue:self.particularDetail.userLongitute forKey:@"longitute"];
        //verified.
//        [locationDictionary2 setValue:modalObject.serviceProviderLongitude forKey:@"longitute"];
        
        [array_locationDetail addObject:locationDictionary1];
        [array_locationDetail addObject:locationDictionary2];
    }
    else {
        NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
        [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
        [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
        
        NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
        [locationDictionary2 setValue:self.particularDetail.serviceProviderLatitude forKey:@"lattitue"];
        [locationDictionary2 setValue:self.particularDetail.serviceProviderLongitude forKey:@"longitute"];
//        [locationDictionary2 setValue:modalObject.ClientLatitude forKey:@"lattitue"];
//        [locationDictionary2 setValue:modalObject.ClientLongitude forKey:@"longitute"];
        
        [array_locationDetail addObject:locationDictionary1];
        [array_locationDetail addObject:locationDictionary2];
        
    }
    NSLog(@"----------------------%@",array_locationDetail);
//    [self showAllLocationDetail];

}
#pragma mark - Show all the BootCamp Location Markers

-(void)showAllLocationDetail {
    [ _mapView clear];
    if ([array_locationDetail count] != 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:1]];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]) zoom:18];
        
        if (!_isFirstTime) {
            // zoom the map into the users current location
            [self.mapView animateWithCameraUpdate:updatedCamera];
            _isFirstTime = YES;
        }

    }
    
    // Creates a marker in the center of the map.
    for (int i = 0 ; i < [array_locationDetail count] ; i ++) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:i]];
        marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]);
        
        if (i == 0)
            marker.icon = [UIImage imageNamed:@"location"];
        else if (i == 1)
            marker.icon = [UIImage imageNamed:@"location2"];
        else
            marker.icon = [UIImage imageNamed:@"location2"];
        
//        GMSMutablePath *path = [GMSMutablePath path];
//        [path addCoordinate:CLLocationCoordinate2DMake([APPDELEGATE latitude].doubleValue,[APPDELEGATE latitude].doubleValue)];
//        [path addCoordinate:marker.position];
//
//        GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
//        rectangle.strokeWidth = 5.f;
//        rectangle.strokeColor = [UIColor lightGrayColor];
//        rectangle.map = _mapView;
        marker.map = self.mapView;
        marker.title = [NSString stringWithFormat:@"%d",i];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.mapView.myLocationEnabled = YES;
    });
}

- (IBAction)cancelJobAction:(id)sender {
    
    PopUPVC *popOver = [[PopUPVC alloc]initWithNibName:@"PopUPVC" bundle:nil];
    popOver.isCancelRequest = YES;
    popOver.delegate = self;
    popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    popOver.modalPresentationStyle =  UIModalPresentationFormSheet;
//    popOver.particularJobCancelDetail = self.particularDetail;_sendParticularDetail
     popOver.particularServiceProviderDetailInSendRequest = self.userDetail;
    [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
}

- (IBAction)backAction:(id)sender {
    
    NSLog(@"This is center ---%@", [[APPDELEGATE viewController] centerPanel]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancelAction:(id)sender {
    // Need to add approve API  here.
    // condition changed
    //[self.navTitle.text isEqualToString:KNSLOCALIZEDSTRING(@"Approve")]
    if ([self.btnCancelJob.titleLabel.text isEqualToString:KNSLOCALIZEDSTRING(@"Approve")]) {
//        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to approve the job?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"￼Don’t Approve"),KNSLOCALIZEDSTRING(@"Approve")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//            if (index) {
//                [self requestDictForApprovedJobRequest];
//            }
//        }];
        
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to approve the job?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"Approve"),KNSLOCALIZEDSTRING(@"￼Don’t Approve")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index == 1) {
                [self requestDictForUnApprovedJobRequest];
            }else{
                [self requestDictForApprovedJobRequest];
            }
        }];
    }
    else {
        PopUPVC *popOver = [[PopUPVC alloc]initWithNibName:@"PopUPVC" bundle:nil];
        popOver.isCancelRequest = YES;
        
        popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        popOver.modalPresentationStyle =  UIModalPresentationFormSheet;
        popOver.delegate = self;
        //    popOver.particularJobCancelDetail =  self.particularDetail;_sendParticularDetail
        popOver.particularServiceProviderDetailInSendRequest = self.userDetail;
        [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
    }
}
// API to unapprove job.
-(void)requestDictForUnApprovedJobRequest{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:self.userDetail.jobID forKey:@"job_id"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/unapproved_job" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            if (_isFromNotificationList) {
                NSArray * arrayOfController = [[APPDELEGATE navController]viewControllers];
                for (UIViewController * viewController in arrayOfController) {
                    NSLog(@"Controller _-----------%@",viewController);
                    if([viewController isKindOfClass:[JASidePanelController class]]) {
                        [[APPDELEGATE navController] popToViewController:viewController animated:NO];
                    }
                }
            }else
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
    }];
}
    


- (IBAction)btnMarkAsCompeleteAction:(id)sender {
    
    [self requestDictForCompleteJobRequest];
    
}

/*********************** Service Implementation Methods ****************/
-(void)requestDictForApprovedJobRequest {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

//    if (_particularDetail) {
//        [requestDict setValue:_particularDetail.userID forKey:pServicePrividerID];
//        [requestDict setValue:_particularDetail.jobID forKey:pJobId];
//    }
    if (_userDetail) {
        [requestDict setValue:_userDetail.userID forKey:pServicePrividerID];
        [requestDict setValue:_userDetail.jobID forKey:pJobId];
    }
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/approved_job_request" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            if ([[result valueForKey:@"review_status"]boolValue]) {
                if (_isFromNotificationList) {
                    NSArray * arrayOfController = [[APPDELEGATE navController]viewControllers];
                    for (UIViewController * viewController in arrayOfController) {
                        NSLog(@"Controller _-----------%@",viewController);
                        if([viewController isKindOfClass:[JASidePanelController class]]) {
                            [[APPDELEGATE navController] popToViewController:viewController animated:NO];
                        }
                    }
                }else
                    [self.navigationController popViewControllerAnimated:YES];

            }else{
                // reviewObj.reviewDetail = _particularDetail;

                GiveReviewVC *reviewObj = [[GiveReviewVC alloc]initWithNibName:@"GiveReviewVC" bundle:nil];
                reviewObj.delegate = self;
                reviewObj.reviewDetail = particularDetailForHold;
                [self.navigationController pushViewController:reviewObj animated:YES];
            }
            
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
    
}

-(void)requestDictForCompleteJobRequest {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pServicePrividerID];
    [requestDict setValue:(self.isFromNotificationScreen)?self.jobId:_jobID forKey:pJobId];
    [requestDict setValue:(self.isFromNotificationScreen)?self.userId:_clientID forKey:pClientID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];


    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
     ;
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/complete_job_request" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            GiveAReviewServiceSideVC *reviewObj = [[GiveAReviewServiceSideVC alloc]initWithNibName:@"GiveAReviewServiceSideVC" bundle:nil];
            reviewObj.delegate = self;
//            reviewObj.objRowModal = _particularDetail;
            reviewObj.objRowModal = _userDetail;
            [self.navigationController pushViewController:reviewObj animated:YES];
        }else
        {
//            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Error!") message:error.localizedDescription andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
    
}

-(void)requestDictForServiceTracking {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
        [requestDict setValue:_serviceProviderID forKey:pServicePrividerID];

        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/service_tracking_lat_long_client" WithComptionBlock:^(id result, NSError *error) {
            
            
            if (!error) {
                if(array_locationDetail) {
                    [array_locationDetail removeAllObjects];
                }
                self.particularDetail = [RowDataModal parseServiceTrackingForProviderLocationWithDict:result isFromClient:YES];
                [self.distanceInMile setText:self.particularDetail.serviceDistanceDetail];
                [self.time setText:self.particularDetail.serviceTime];
                
                [self updateLocation];
                [self showAllLocationDetail];
            }
        }];
     }
    else {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pServicePrividerID];
        [requestDict setValue: (self.isFromNotificationScreen)?self.userId:_clientID forKey:pClientID];

        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/service_tracking_lat_long_service" WithComptionBlock:^(id result, NSError *error) {
            
            
            if (!error) {
                if(array_locationDetail){
                    [array_locationDetail removeAllObjects];
                }
                
                self.particularDetail = [RowDataModal parseServiceTrackingForProviderLocationWithDict:result isFromClient:NO];
                //modalObject = [ServiceTrackingModal parseServiceTracking:response];
                [self.distanceInMile setText:self.particularDetail.serviceDistanceDetail];
                [self.time setText:self.particularDetail.serviceTime];
                
                [self updateLocation];
                [self showAllLocationDetail];

            }
        }];
        
        
       
    }
}
// Call Web API To Get User Detail For Notification

-(void)makeServiceCallToGetUserDetail{
   
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
//    [requestDict setValue:self.userId forKey:@"user_id"];
    [requestDict setValue:self.jobId forKey:@"job_id"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    // newly added
    [requestDict setValue:self.userId forKey:@"notification_detail_id"];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/get_user_details_for_notification" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            self.particularDetail = [[RowDataModal alloc] init];
            NSMutableArray *serviceDataArray = [NSMutableArray array];
            [serviceDataArray addObject:[RowDataModal parseCatagoryList:result comingFromServiceTracking:YES]];
            self.particularDetail = [serviceDataArray firstObject];
            //modalObject = [ServiceTrackingModal parseServiceTracking:response];
            [self.distanceInMile setText:self.particularDetail.serviceDistanceDetail];
            [self.time setText:self.particularDetail.serviceTime];
            
            [self initialSetup];
            [self showAllLocationDetail];        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
}

-(void)comingFromRequest {
    
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[JASidePanelController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

@end
