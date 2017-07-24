//
//  ProfileDetailVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 07/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ProfileDetailVC.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "EditProfileVC.h"
#import "ProfileDetailCell.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"

static NSString *identifier = @"ProfileDetailCell";

@interface ProfileDetailVC ()<UITabBarDelegate,UITableViewDataSource,UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    UserInfo *modalObject;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@property (weak, nonatomic) IBOutlet UILabel *lblMyProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblOnGoingServices;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

//User Detail
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDistancePrefrenceMilesLabel;

@property (weak, nonatomic) IBOutlet UIButton *userPhoneBtn;

@property (weak,nonatomic ) NSString *phoneNumber;



@end

@implementation ProfileDetailVC

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

#pragma mark - Helper Methods

-(void)initialSetup
{
    _lblMyProfile.text = KNSLOCALIZEDSTRING(@"My Profile");
   _lblOnGoingServices.text = KNSLOCALIZEDSTRING(@"On Going Services");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnEdit setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    }
    
    //Set table Header View
    [self.tblView setTableHeaderView:self.headerView];
    [self.tblView setDataSource:self];
    [self.tblView setDelegate:self];
    
    //Register Cell
    [self.tblView registerNib:[UINib nibWithNibName:@"ProfileDetailCell" bundle:nil] forCellReuseIdentifier:@"ProfileDetailCell"];

    //Set Image and Layout
  //  [self.userImage.layer setCornerRadius:self.userImage.frame.size.width/2];
    self.userImage.layer.cornerRadius = 75.0;
    [self.userImage.layer setBorderWidth:3];
    [self.userImage.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.userImage setClipsToBounds:YES];
    [_userPhoneBtn setImage:[UIImage new] forState:UIControlStateNormal];
    //Get User Detail
    [self requestDictForGettingProfileDetail];
    
     _userPhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _userPhoneBtn.imageEdgeInsets = UIEdgeInsetsZero;
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [modalObject.onGoingJobArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProfileDetailCell *cell = (ProfileDetailCell *)[self.tblView dequeueReusableCellWithIdentifier:identifier];
    
    OnGoingjobDetails *jobDetail = [modalObject.onGoingJobArray objectAtIndex:indexPath.row];
    
    [cell.serviceNumber setText:jobDetail.comingJobName];
    [cell.serviceStatus setText:jobDetail.comingDate];
    
//    if(indexPath.row == 0){
//        [cell.serviceNumber setText:@"Service One"];
//    }
//    else {
//        [cell.serviceNumber setText:@"Service Two"];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}



#pragma mark - UIButton Actions

- (IBAction)menuAction:(id)sender {
    
    
    [self.view endEditing:YES];
    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (IBAction)editProfileAction:(id)sender {
    EditProfileVC *editProfileObject = [[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
    editProfileObject.editModalObject = modalObject;
    editProfileObject.delegate = self;
    [self.navigationController pushViewController:editProfileObject animated:YES];
}

- (IBAction)userPhoneBtn:(id)sender {
//    NSString *phoneNumber = self.phoneNumber;
//    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
//    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
//    
//    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
//        [UIApplication.sharedApplication openURL:phoneUrl];
//    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
//        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
//    } else {
//        // Show an error message: Your device can not do phone calls.
//    }

}

- (IBAction)userEmailBtn:(id)sender {
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@""];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[modalObject.strEmailAddress]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}


/*********************** Service Implementation Methods ****************/

-(void)requestDictForGettingProfileDetail {
  
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_profile" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            modalObject = [UserInfo parseResponseForProfileDetail:result];
            [self updateUserProfile];
            [self.tblView reloadData];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
     
    }];

}


-(void)updateUserProfile {
    [self.userImage sd_setImageWithURL:modalObject.strUploadURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    
    [self.userNameLabel setText:[NSString stringWithFormat:@"%@",modalObject.strUsername]];
    [self.userAgeLabel setText:[NSString stringWithFormat:@"Age %@ years",modalObject.strAge]];
    CLLocationDegrees latitude = [[APPDELEGATE latitude] doubleValue];
    CLLocationDegrees longitude = [[APPDELEGATE longitude] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];
    [self.userEmailAddressLabel setText:[NSString stringWithFormat:@"%@",modalObject.strEmailAddress]];
    [self.userPhoneBtn setTitle:[NSString stringWithFormat:@"%@",modalObject.strContact]forState:UIControlStateNormal];
    self.phoneNumber = modalObject.strContact;

//    [self.userDistancePrefrenceMilesLabel setText:[NSString stringWithFormat:@"Distance Prefrence %@",modalObject.strDistance]];
    
    
    [self.userDistancePrefrenceMilesLabel setText:KNSLOCALIZEDSTRING(@"Distance Preference")];
    self.userDistancePrefrenceMilesLabel.text = [self.userDistancePrefrenceMilesLabel.text stringByAppendingString:[NSString stringWithFormat:@" : %@",modalObject.strDistance]];
    
    if ([modalObject.onGoingJobArray count]) {
        [self.lblOnGoingServices setHidden:NO];
    }else {
        [self.lblOnGoingServices setHidden:YES];
    }
    
    [self.tblView reloadData];
}

-(void)methodForUpdateClientDetail:(UserInfo *)userDetail {
    modalObject = userDetail;
    
    [self updateUserProfile];
}


#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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
        self.userAddressLabel.text = str;
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
