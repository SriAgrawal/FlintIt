//
//  CancelledJobNotificationVC.m
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import "JobCompletedVC.h"
#import "MacroFile.h"
#import "HeaderFile.h"

@interface JobCompletedVC ()
{
    UserInfo *modalObject;
    OnGoingjobDetails *jobDetail;
    NSDictionary *userDic;
    RowDataModal *objModel;
}

@property (strong, nonatomic) IBOutlet UIButton *approveButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UILabel *lblNotifications;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *userPhoneBtn;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAddress;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak,nonatomic ) NSString *phoneNumber;
@end

@implementation JobCompletedVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Helper Method

-(void)initialSetup
{
    _lblNotifications.text = KNSLOCALIZEDSTRING(@"Notifications");
    [self.approveButton setTitle:KNSLOCALIZEDSTRING(@"Approve") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Set Layout of ImageView and Button
    [self.userImage.layer setCornerRadius:75];
    self.userImage.clipsToBounds = YES;
    [self.userImage.layer setBorderWidth:3];
    [self.userImage.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.approveButton.layer setCornerRadius:25];
    
//    modalObject = [[UserInfo alloc]init];
//    jobDetail = [[OnGoingjobDetails alloc]init];
    
    //Set Table Header View
    [self.tableView setTableHeaderView:self.headerView];
    
    //Get User Detail
//    if(self.particularServiceIdDetail)
//        [self requestDictForGettingProfileDetail];
//    else
    [self requestDictForGettingProfileDeta:self.dictNotificationInfo];

    //add Observer to refresh the page after notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshControllerDataWithService:) name:@"refreshProviderDetails" object:nil];
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)approveButtonAction:(id)sender {
    
    [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to approve the job?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"Approve"),KNSLOCALIZEDSTRING(@"￼Don’t Approve")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//        if (index) {
//            [self requestDictForApprovedJobRequest];
//        }else{
//            [self requestDictForUnApprovedJobRequest];
//        }
        if (index == 1) {
            [self requestDictForUnApprovedJobRequest];
        }else{
            [self requestDictForApprovedJobRequest];
        }
    }];
}

- (IBAction)userPhoneBtnAction:(id)sender {
    
    NSString *phoneNumber = self.phoneNumber;
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        // Show an error message: Your device can not do phone calls.
    }

}

- (void)refreshControllerDataWithService : (NSNotification *)notification {
    
    NSDictionary *dictNotif = [notification userInfo];
    [self requestDictForGettingProfileDeta:dictNotif];
}



#pragma mark - Reverse Gecoding to get address from (lat,long)

-(void)getUserUpdateLocation : (CLLocationCoordinate2D) coordinate {
    
    // Your location from latitude and longitude
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    //  __block NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
    __block NSString *str = nil;
    // Call the method to find the address
    [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
        if ([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length] && [[d valueForKey:@"Street"] length]) {
            str = [NSString stringWithFormat:@"%@, %@, %@ , %@",[d valueForKey:@"City"],[d valueForKey:@"State"],[d valueForKey:@"Country"],[d valueForKey:@"Street"]];
        }
        else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"State"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"City"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"City"]];
        }else if([[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"Country"]];
        }else{
            str = @"";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            self.userAddress.text = str;
            [self.tableView reloadData];
        });
        
        //  cell.tagLbl.text = str;
        
    } failureHandler:^(NSError *error) {
        NSLog(@"Error : %@", error);
    }
     ];
    
}
- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler{
    // NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler([NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary]);
            }
        }
    }];
}


/*********************** Service Implementation Methods ****************/

-(void)requestDictForApprovedJobRequest {
    
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[self.dictNotificationInfo valueForKey:pClientID] forKey:pClientID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [requestDict setValue:[self.dictNotificationInfo valueForKey:pServicePrividerID] forKey:pServicePrividerID];
    [requestDict setValue:[self.dictNotificationInfo valueForKey:pJobId] forKey:pJobId];

    
    if(!_particularNotificationDetail)  {
        _particularNotificationDetail = [[NotificationRelatedData alloc]init];
    }
    
    _particularNotificationDetail.jobID = [self.dictNotificationInfo valueForKey:pJobId];
    _particularNotificationDetail.receiverID = [self.dictNotificationInfo valueForKey:pServicePrividerID];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/approved_job_request" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
//            GiveReviewVC *reviewObj = [[GiveReviewVC alloc]initWithNibName:@"GiveReviewVC" bundle:nil];
//            reviewObj.delegate = self;
//            reviewObj.particularReviewDetail = _particularNotificationDetail;
//            [self.navigationController pushViewController:reviewObj animated:YES];
            // reviewObj.reviewDetail = _particularServiceIdDetail;

            // Change as per client
                if ([[result valueForKey:@"review_status"]boolValue]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    GiveReviewVC *reviewObj = [[GiveReviewVC alloc]initWithNibName:@"GiveReviewVC" bundle:nil];
                    reviewObj.delegate = self;
                    reviewObj.particularReviewDetail = _particularNotificationDetail;
                    [self.navigationController pushViewController:reviewObj animated:YES];
                }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    

}
// API to unapprove job.
-(void)requestDictForUnApprovedJobRequest{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[self.dictNotificationInfo valueForKey:@"job_id"] forKey:@"job_id"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/unapproved_job" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
    }];
}
-(void)requestDictForGettingProfileDetail {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    if (_particularServiceIdDetail) {
        [requestDict setValue:_particularServiceIdDetail.userID forKey:pUserId];
    }else{
        [requestDict setValue:_particularNotificationDetail.senderID forKey:pUserId];
    }
    
//    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

    [requestDict setValue:[APPDELEGATE latitude] forKey:@"latitude"];
    [requestDict setValue:[APPDELEGATE longitude] forKey:@"longitude"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_profile" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            modalObject = [UserInfo parseResponseForProfileDetail:result];
            jobDetail = [modalObject.onGoingJobArray firstObject];
            [self updateUserProfile];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];

}

//-(void)requestDictForGettingProfileDeta:(NSDictionary *)dict {
//    
//    if (!manager) {
//        manager = [[ServiceHelper alloc] init];
//    }
//    
//    [manager setServiceHelperDelegate:self];
//    
//    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
//    if ([language isEqualToString:@"ar"]) {
//        [requestDict setObject:@"arabic" forKey:@"language_preference"];
//    }else if ([language isEqualToString:@"es"])
//    {
//        [requestDict setObject:@"spanish" forKey:@"language_preference"];
//    }else
//    {
//        [requestDict setObject:@"english" forKey:@"language_preference"];
//    }
//    
//    [requestDict setValue:[APPDELEGATE latitude] forKey:@"latitude"];
//    [requestDict setValue:[APPDELEGATE longitude] forKey:@"longitude"];
//    [requestDict setValue:[dict valueForKey:@"client_id"] forKey:pUserId];
//    
//    [manager callPOSTMethodWithData:requestDict andMethodName:WebMethodUserProfile andController:self.navigationController];
//}
-(void)requestDictForGettingProfileDeta:(NSDictionary *)dict {
    
    

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    if([[dict valueForKey:@"user_type"] isEqualToString:@"provider"])
        [requestDict setObject:[dict valueForKey:@"service_provider_id"] forKey:@"notification_detail_id"];
    else
        [requestDict setObject:[dict valueForKey:@"client_id"] forKey:@"notification_detail_id"];

    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    
    [requestDict setObject:[dict valueForKey:@"job_id"] forKey:pJobId];
    
    [requestDict setValue:[APPDELEGATE latitude] forKey:@"latitude"];
    [requestDict setValue:[APPDELEGATE longitude] forKey:@"longitude"];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/get_user_details_for_notification" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            objModel = [RowDataModal parseCatagoryList:result comingFromServiceTracking:NO];

//            modalObject = [UserInfo parseResponseForProfileDetail:requestDict];
//            jobDetail = [modalObject.onGoingJobArray firstObject];
            [self updateUserProfile];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}




-(void)updateUserProfile {
    
//    [self.userImage sd_setImageWithURL:modalObject.strUploadURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [self.userImage sd_setImageWithURL:objModel.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];

    [self.userNameLabel setText:[NSString stringWithFormat:@"%@",objModel.userName]];
    [self.userAgeLabel setText:[NSString stringWithFormat:@"Age %@ years",objModel.userAge]];
//    [self.userAddress setText:[NSString stringWithFormat:@"%@",modalObject.strAddress]];
    [self.userPhoneBtn setTitle:[NSString stringWithFormat:@"%@",objModel.userContactNumber]forState:UIControlStateNormal];
    [self.serviceNameLabel setText:objModel.jobName];
    self.phoneNumber = objModel.userContactNumber;
    
    //CLLocationDegrees latitude = [objInfo.userLatitute doubleValue];
    //CLLocationDegrees longitude = [objInfo.userLongitute doubleValue];
    //CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    
    
    CLLocationDegrees latitude = [objModel.userLatitute doubleValue];
    CLLocationDegrees longitude = [objModel.userLongitute doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];

    [self.tableView reloadData];
}


-(void)methodForUpdateClientDetail:(UserInfo *)userDetail {
    modalObject = userDetail;
    [self updateUserProfile];
}

@end
