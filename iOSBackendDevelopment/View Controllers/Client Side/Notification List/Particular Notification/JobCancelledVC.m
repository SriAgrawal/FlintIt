//
//  JobCancelledVC.m
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import "JobCancelledVC.h"
#import "MacroFile.h"
#import "HeaderFile.h"

@interface JobCancelledVC ()
{
    RowDataModal *objInfo;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *viewProfileButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *lblNotifications;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;


@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLbl;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLbl;
@property (weak, nonatomic) IBOutlet UILabel *userAmountLbl;
@property (weak, nonatomic) IBOutlet UILabel *userDateofBirthLbl;
@property (weak, nonatomic) IBOutlet UILabel *userContactLbl;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *acceptedLbl;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation JobCancelledVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    objInfo = [[RowDataModal alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProviderDetalsWith:) name:@"refreshProviderDetails" object:nil];
    if ([[self.userDict allKeys] count]) {
        [self callApiForNotificationDetails:self.userDict];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshProviderDetalsWith:(NSNotification *)notification {
    [self callApiForNotificationDetails:[notification userInfo]];
}

#pragma mark - Helper Method

-(void)initialSetup
{
    _lblNotifications.text = KNSLOCALIZEDSTRING(@"Notifications");
    [self.viewProfileButton setTitle:KNSLOCALIZEDSTRING(@"View Profile") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Set Image and Layout
    [self.imageView sd_setImageWithURL:objInfo.userProfileImageURL placeholderImage:[UIImage imageNamed:@"john_img_large"]];
    [self.imageView.layer setCornerRadius:self.imageView.frame.size.width/2];
    [self.imageView.layer setBorderWidth:3];
    [self.imageView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    
    //Set Corner Radius
    [self.viewProfileButton.layer setCornerRadius:25];
    
    //Set HeaderView on tableView
    [self.tableView setTableHeaderView:self.headerView];
    
    //Set UserInfo
    
    _userAgeLbl.text = objInfo.userAge;
    _userNameLbl.text = objInfo.userName;
    _userAmountLbl.text = objInfo.userPrice;
//    _userAddressLbl.text = objInfo.userAddress;
    //_userDateofBirthLbl.text = @"20/11/2016";
    //        _serviceNameLbl.text = KNSLOCALIZEDSTRING(([NSString stringWithFormat:@"For%@",notificationInfo.strServiceName]));
    
    
    if ([language isEqualToString:@"ar"]) {
        _acceptedLbl.text = KNSLOCALIZEDSTRING(@"Have Accepted your request for Hiring.");
        //_serviceNameLbl.text = KNSLOCALIZEDSTRING(([NSString stringWithFormat:@"For%@",objInfo.serviceName]));
    }
    else if ([language isEqualToString:@"es"]){
        _acceptedLbl.text = KNSLOCALIZEDSTRING(@"Have Accepted your request for Hiring.");
        //_serviceNameLbl.text = KNSLOCALIZEDSTRING(([NSString stringWithFormat:@"For%@",objInfo.serviceName]));
    }
    else{
        _acceptedLbl.text = KNSLOCALIZEDSTRING(@"Have Accepted your request for Hiring.");
        //_serviceNameLbl.text = KNSLOCALIZEDSTRING(([NSString stringWithFormat:@"For%@",objInfo.serviceName]));
    }
    _serviceNameLbl.text = [NSString stringWithFormat:@"For %@",objInfo.serviceName];
    CLLocationDegrees latitude = [objInfo.userLatitute doubleValue];
    CLLocationDegrees longitude = [objInfo.userLongitute doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];
}

- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)viewProfileAction:(id)sender {
}

/*********************** Service Implementation Methods ****************/


-(void)callApiForNotificationDetails:(NSDictionary *)dict {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//    [requestDict setObject:[dict valueForKey:@"service_provider_id"] forKey:pUserId];
    [requestDict setObject:[dict valueForKey:@"job_id"] forKey:@"job_id"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [requestDict setObject:[dict valueForKey:@"job_id"] forKey:pJobId];
    [requestDict setValue:[APPDELEGATE latitude] forKey:@"latitude"];
    [requestDict setValue:[APPDELEGATE longitude] forKey:@"longitude"];
    
    // newly added
    [requestDict setObject:[dict valueForKey:@"service_provider_id"] forKey:@"notification_detail_id"];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/get_user_details_for_notification" WithComptionBlock:^(id result, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            objInfo = [RowDataModal parseCatagoryList:result comingFromServiceTracking:NO];
            [self initialSetup];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
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
        self.userAddressLbl.text = str;
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

@end
