//
//  MenuSectionViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 14/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"
#import "ServiceTrackingViewController.h"
#import "BlockListVC.h"

static NSString *cellIdentifier = @"MenuTableViewCell";

@interface MenuSectionViewController ()<UITableViewDataSource,UITableViewDelegate>{
    BOOL   isNotificationOn;
    NSString *strCount;
}

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong , nonatomic)  NSMutableDictionary *dicDataArray;

@end

@implementation MenuSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialSetup];
}

-(void)getNotificationAndPhoneNumberState
{
    [self requestDictForGettingNotificationAndNumber];
    [self requestDictForCount];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    //Register TableView Cell
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuTableViewCell"];
    
    //Bounce table vertical if required
    [self.menuTableView setAlwaysBounceVertical:NO];
    
    //Store the Image and Title on menu Screen
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"Push Notifications",@"Home",@"Profile",@"Notifications",@"Change Password",@"Service Tracking",@"Chats",@"Email",@"Share the Application",@"Block List",@"Logout", nil];
    NSArray *imageArray = [[NSArray alloc]initWithObjects:@"notification_icon",@"icon5",@"user_icon1",@"icon9",@"password_icon",@"tracker_icon",@"chat_icon",@"mail_icon",@"share_icon",@"block",@"logout_icon",nil];
    
    self.dicDataArray = [NSMutableDictionary dictionaryWithObjectsAndKeys:titleArray,@"TITLE",imageArray,@"IMAGE",@"0",@"isNotificationOn", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callApiToGetUnreadCount) name:@"getUnreadCount" object:nil];

}
-(void)callApiToGetUnreadCount{
    [self requestDictForCount];
}
#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dicDataArray valueForKey:@"TITLE"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuTableViewCell *cell = (MenuTableViewCell *)[self.menuTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell.menuLabel setText:KNSLOCALIZEDSTRING([[self.dicDataArray valueForKey:@"TITLE"] objectAtIndex:indexPath.row])];
    [cell.menuImageView setImage:[UIImage imageNamed:[[self.dicDataArray valueForKey:@"IMAGE"] objectAtIndex:indexPath.row]]];
    
    (indexPath.row > 0)?[cell.switchButton setHidden:YES]:[cell.switchButton setHidden:NO];
    
    [cell.switchButton setOn:[[self.dicDataArray valueForKey:@"isNotificationOn"] boolValue] animated:YES];
    
    NSArray *arrayCount = [strCount componentsSeparatedByString:@","];
    if (indexPath.row == 3) {
        [cell.countLabel setText:[arrayCount firstObject]];
        ([[arrayCount firstObject] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
    }else if (indexPath.row == 6) {
        if([arrayCount count] > 3){
            [cell.countLabel setText:arrayCount[3]];
            ([arrayCount[3] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
        }
    }else if (indexPath.row == 5) {
        [cell.countLabel setText:arrayCount[1]];
        ([arrayCount[1] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
    }else if (indexPath.row == 7) {
        [cell.countLabel setText:arrayCount[2]];
        ([arrayCount[2] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
    }else {
        [cell.countLabel setHidden:YES];
    }
    
    [cell.switchButton setTag:indexPath.row + 100];
    [cell.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            
            break;
        case 1: {
            SelectChoiceViewController *selectObject = [[SelectChoiceViewController alloc]initWithNibName:@"SelectChoiceViewController" bundle:nil];
            [self.sidePanelController setCenterPanel:selectObject];
        }
            
            break;
        case 2: {
            ProfileViewController *profileObject = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
            [self.sidePanelController setCenterPanel:profileObject];
        }
            break;
        case 3: {
            [self requestDictForReadUnread:@"notification"];
        }
            break;
        case 4: {
            ChangePasswordVC *changePasswordObject = [[ChangePasswordVC alloc]initWithNibName:@"ChangePasswordVC" bundle:nil];
            [self.sidePanelController setCenterPanel:changePasswordObject];
        }
            break;
        case 5: {
            ServiceTrackingViewController *serviceTrackingObject = [[ServiceTrackingViewController alloc]initWithNibName:@"ServiceTrackingViewController" bundle:nil];
            THREEOPTIONSCOMINGFROM = Menu;
            serviceTrackingObject.isFromSidePanel = YES;
            [self.sidePanelController setCenterPanel:serviceTrackingObject];
        }
            break;
        case 6: {
            MessagesVC *mailObject = [[MessagesVC alloc]initWithNibName:@"MessagesVC" bundle:nil];
            THREEOPTIONSCOMINGFROM = Menu;
            [self.sidePanelController setCenterPanel:mailObject];
        }
            
            break;
        case 7:{
            [self requestDictForReadUnread:@"email"];
            
        }
            break;
        case 8: {
            //            Currently it supports these UIActivityTypes:
            //
            //            UIActivityTypePostToFacebook
            //            UIActivityTypePostToTwitter
            //            UIActivityTypePostToWeibo
            //            UIActivityTypeMessage
            //            UIActivityTypeMail
            //            UIActivityTypePrint
            //            UIActivityTypeCopyToPasteboard
            //            UIActivityTypeAssignToContact
            //            UIActivityTypeSaveToCameraRoll
            //            UIActivityTypeAddToReadingList
            //            UIActivityTypePostToFlickr
            //            UIActivityTypePostToVimeo
            //            UIActivityTypePostToTencentWeibo
            //            UIActivityTypeAirDrop
            
            NSString *textToShare = @"Look at this awesome website for aspiring iOS Developers!";
            NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];
            
            NSArray *objectsToShare = @[textToShare, myWebsite];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            break;
        case 9: {
            BlockListVC *blockObject = [[BlockListVC alloc]initWithNibName:@"BlockListVC" bundle:nil];
            [self.sidePanelController setCenterPanel:blockObject];
        }
            break;
        case 10: {
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Logout") message:KNSLOCALIZEDSTRING(@"Are you sure you want to logout?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                if (index) {
                    [self requestDictForLogout];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)switchAction:(UISwitch *)sender {
    
    isNotificationOn = [sender isOn];
    
     [self requestDictForGettingMessageNotification];
    [self requestDictForSendNotificationAndNumber];

    
}
-(void)cancelService {
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForGettingNotificationAndNumber {
    

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/get_notification_status" WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
        [self.dicDataArray setValue:[result objectForKeyNotNull:pNotificationStatus expectedObj:@""] forKey:@"isNotificationOn"];
        isNotificationOn = [result objectForKeyNotNull:pNotificationStatus expectedObj:@""];
        [self.menuTableView reloadData];
        }
    }];

}

-(void)requestDictForGettingMessageNotification {
    
    NSString *apiName = [NSString stringWithFormat:@"updatePushStatus/%@/%@",[NSUSERDEFAULT valueForKey:@"userID"],isNotificationOn?@"1":@"0"];
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {

    }];
    
}
-(void)requestDictForSendNotificationAndNumber {

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:isNotificationOn?@"1":@"0" forKey:pNotificationStatus];
    [requestDict setValue:@"1" forKey:pDisplayNumberStatus];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/change_notification_status" WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
            [self.dicDataArray setValue:isNotificationOn?@"1":@"0" forKey:@"isNotificationOn"];
            [self.menuTableView reloadData];
        }
    }];

}

-(void)requestDictForReadUnread:(NSString *)type {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:type forKey:@"type"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] animated:YES];
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/read_unread_status" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
        if (!error) {
            if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"notification"]) {
                NotificationViewController *notificationObject = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
                [self.sidePanelController setCenterPanel:notificationObject];
            }else if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"email"]) {
                EmailListViewController *emailObject = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
                THREEOPTIONSCOMINGFROM = Menu;
                [self.sidePanelController setCenterPanel:emailObject];
            }

        }
    }];
    
    //[manager callPOSTMethodWithData:requestDict andMethodName:WebMethodget_Read_unread_status andController:self.navigationController];
}

-(void)requestDictForCount {

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/get_count_read" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            
            strCount = [NSString stringWithFormat:@"%@,%@,%@", [result objectForKeyNotNull:@"notification" expectedObj:@""], [result objectForKeyNotNull:@"service_tracking_count" expectedObj:@""], [result objectForKeyNotNull:@"email" expectedObj:@""]];

            [self.menuTableView reloadData];
        }
        [self requestToFetchMessageCount];

    }];
    
    //[manager callPOSTMethodWithData:requestDict andMethodName:WebMethodget_Get_count_read andController:self.navigationController];
}


-(void)requestToFetchMessageCount {
    
    
    NSString *apiName = [NSString stringWithFormat:@"unreadMessageCount/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            NSMutableDictionary * dist_unread = [result objectForKeyNotNull:@"unreadMessage" expectedObj:@""];
            strCount = [strCount stringByAppendingString:[NSString stringWithFormat:@",%@",[dist_unread objectForKeyNotNull:@"totalUnreadUser" expectedObj:@""]]];
            [self.menuTableView reloadData];
        }
    }];
    
}
//-(void)requestToFetchMessageCount {
//    
//    NSString *apiName = [NSString stringWithFormat:@"unreadMessage/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
//
//    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
//       
//        if (!error) {
//            strCount = [strCount stringByAppendingString:[NSString stringWithFormat:@",%@",[result objectForKeyNotNull:@"unreadMessage" expectedObj:@""]]];
//            [self.menuTableView reloadData];
//        }
//    }];
//}


/*********************** Service Implementation Methods ****************/

-(void)requestDictForLogout {



    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setValue:@"ios" forKey:pDeviceType];
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/logout" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [self requestDictToLogoutFromMongoDB];
            NSMutableDictionary *dict;
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                dict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]] ;
                [dict setValue:@"NO" forKey:@"isOTPVerified"];
                [NSUSERDEFAULT setValue:dict forKey:@"ClientUserInfoDictionary"];
            }else {
                dict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]] ;
                [dict setValue:@"NO" forKey:@"isOTPVerified"];
                [NSUSERDEFAULT setValue:dict forKey:@"ServiceUserInfoDictionary"];
            }
            
            [NSUSERDEFAULT setBool:0 forKey:@"isSocialLogin"];
            [NSUSERDEFAULT setValue:[NSDictionary dictionary] forKey:@"ClientUserInfoDictionary"];
            [NSUSERDEFAULT setValue:[NSDictionary dictionary] forKey:@"ServiceUserInfoDictionary"];
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [[GIDSignIn sharedInstance] signOut];
            
            [NSUSERDEFAULT removeObjectForKey:@"userID"];

//            [APPDELEGATE stopLocation];
            [APPDELEGATE stopLocationManager];

            [NSUSERDEFAULT synchronize];
            [APPDELEGATE setupForApplicationLaunch];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
        
    }];
    
}
// logout from mongo DB
-(void)requestDictToLogoutFromMongoDB{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"removeToken" WithComptionBlock:^(id result, NSError *error) {
        NSLog(@"hello user logout %@",result);
    }];
}


// dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getUnreadCount" object:nil];
}
@end
