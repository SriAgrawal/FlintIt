
//
//  MenuVC.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 01/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.




#import "MacroFile.h"
#import "HeaderFile.h"
#import "NSDictionary+NullChecker.h"
#import "BlockListVC.h"
#import "CDLanguageHandler.h"


static NSString *cellIdentifier = @"MenuTableViewCell";

@interface MenuVC ()<UITableViewDataSource,UITableViewDelegate> {
    BOOL isNotificationOn;
    BOOL isNumberOn;
    NSString *strCount;
    
}

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong , nonatomic)  NSMutableDictionary *dicDataArray;

@end

@implementation MenuVC

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
}

//-(void)viewWillAppear:(BOOL)animated {
//    [self requestDictForCount];
//}
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
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"Push Notifications",@"Display My Number",@"Home",@"Profile",@"Notifications",@"Change Password",@"Service Tracking",@"Favourite List",@"Chats",@"Email",@"Share the Application",@"Block List",@"Logout", nil];
    NSArray *imageArray = [[NSArray alloc]initWithObjects:@"notification_icon",@"phone_icon",@"icon5",@"user_icon1",@"icon9",@"password_icon",@"tracker_icon",@"fav_icon",@"chat_icon",@"mail_icon",@"share_icon",@"block",@"logout_icon",nil];
    
    self.dicDataArray = [NSMutableDictionary dictionaryWithObjectsAndKeys:titleArray,@"TITLE",imageArray,@"IMAGE",@"0",@"isNotificationOn",@"0",@"isNumberOn", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callApiToGetUnreadCount) name:@"getUnreadCount" object:nil];
}


/**
 get unread count when receive a notification
 */
-(void)callApiToGetUnreadCount{
    [self requestDictForCount];

}
-(void)getNotificationAndPhoneNumberState {
    [self requestDictForGettingNotificationAndNumber];
    [self requestDictForCount];

}

-(void)cancelService {
   
}

#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dicDataArray valueForKey:@"TITLE"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuTableViewCell *cell = (MenuTableViewCell *)[self.menuTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell.menuLabel setText:KNSLOCALIZEDSTRING([[self.dicDataArray valueForKey:@"TITLE"] objectAtIndex:indexPath.row])];
    [cell.menuImageView setImage:[UIImage imageNamed:[[self.dicDataArray valueForKey:@"IMAGE"] objectAtIndex:indexPath.row]]];
    (indexPath.row > 1)?[cell.switchButton setHidden:YES]:[cell.switchButton setHidden:NO];
    
    if (indexPath.row == 0) {
        [cell.switchButton setOn:[[self.dicDataArray valueForKey:@"isNotificationOn"] boolValue] animated:YES];
    }else if (indexPath.row == 1) {
        [cell.switchButton setOn:[[self.dicDataArray valueForKey:@"isNumberOn"] boolValue] animated:YES];
    }
    NSArray *arrayCount = [strCount componentsSeparatedByString:@","];
    if (indexPath.row == 4) {
        [cell.countLabel setText:[arrayCount firstObject]];
        ([[arrayCount firstObject] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
    }else if (indexPath.row == 6) {
        [cell.countLabel setText:arrayCount[1]];
        ([arrayCount[1] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
    }else if (indexPath.row == 8) {
        if([arrayCount count] > 3){
            [cell.countLabel setText:arrayCount[3]];
            ([arrayCount[3] integerValue] > 0) ? [cell.countLabel setHidden:NO] : [cell.countLabel setHidden:YES];
        }
    }else if (indexPath.row == 9) {
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
        case 1:
            
            break;
        case 2: {
            SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
            //[self.sidePanelController setRecognizesPanGesture:NO];
            [self.sidePanelController setCenterPanel:selectChoiceObject];
        }
            break;
        case 3: {
            ProfileDetailVC *profileObject = [[ProfileDetailVC alloc]initWithNibName:@"ProfileDetailVC" bundle:nil];
            //[self.sidePanelController setRecognizesPanGesture:NO];
            [self.sidePanelController setCenterPanel:profileObject];
            
        }
            break;
        case 4: {
            //            NotificationViewController *notificationObject = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
            //            [self.sidePanelController setCenterPanel:notificationObject];
            [self requestDictForReadUnread:@"notification"];
            
        }
            break;
        case 5: {
            ChangePasswordVC *changePasswordObject = [[ChangePasswordVC alloc]initWithNibName:@"ChangePasswordVC" bundle:nil];
            //[self.sidePanelController setRecognizesPanGesture:NO];
            [self.sidePanelController setCenterPanel:changePasswordObject];
        }
            break;
        case 6:{
            ServiceTrackingVC *serviceTrackingObject = [[ServiceTrackingVC alloc]initWithNibName:@"ServiceTrackingVC" bundle:nil];
            THREEOPTIONSCOMINGFROM = Menu;
            serviceTrackingObject.isFromMenu = YES;
            [self.sidePanelController setCenterPanel:serviceTrackingObject];
        }
            break;
        case 7: {
            FavouritesVC *favouriteObject = [[FavouritesVC alloc]initWithNibName:@"FavouritesVC" bundle:nil];
            [self.sidePanelController setCenterPanel:favouriteObject];
        }
            break;
        case 8: {
            MessagesVC *messageObject = [[MessagesVC alloc]initWithNibName:@"MessagesVC" bundle:nil];
            THREEOPTIONSCOMINGFROM = Menu;
            [self.sidePanelController setCenterPanel:messageObject];
        }
            
            break;
        case 9: {
            //            EmailListViewController *emailObject = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
            //            THREEOPTIONSCOMINGFROM = Menu;
            //            [self.sidePanelController setCenterPanel:emailObject];
            [self requestDictForReadUnread:@"email"];
        }
            break;
        case 10: {
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
        case 11: {
            BlockListVC *blockObject = [[BlockListVC alloc]initWithNibName:@"BlockListVC" bundle:nil];
            [self.sidePanelController setCenterPanel:blockObject];
        }
            break;
        case 12: {
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
    NSInteger btnTag = sender.tag;
    
    (btnTag == 100)?(isNotificationOn = [sender isOn]):(isNumberOn = [sender isOn]);

    if (btnTag == 100) {
        
        // Both api will call
        
        [self requestDictForGettingMessageNotification];
        
    }
    
    
    
    [self requestDictForSendNotificationAndNumber];

    
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForGettingMessageNotification {
    
    
    
    NSString *apiName = [NSString stringWithFormat:@"updatePushStatus/%@/%@",[NSUSERDEFAULT valueForKey:@"userID"], isNotificationOn?@"1":@"0"];
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {

    }];
    }


-(void)requestDictForGettingNotificationAndNumber {
    

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/get_notification_status" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            [self.dicDataArray setValue:[result objectForKeyNotNull:pNotificationStatus expectedObj:@""] forKey:@"isNotificationOn"];
            [self.dicDataArray setValue:[result objectForKeyNotNull:pDisplayNumberStatus expectedObj:@""] forKey:@"isNumberOn"];
            isNumberOn = [[result objectForKeyNotNull:pDisplayNumberStatus expectedObj:@""] boolValue];
            isNotificationOn = [[result objectForKeyNotNull:pNotificationStatus expectedObj:@""] boolValue];
            [self.menuTableView reloadData];
        }
    }];
    
}

-(void)requestDictForSendNotificationAndNumber {
    
    
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:isNotificationOn?@"1":@"0" forKey:pNotificationStatus];
    [requestDict setValue:isNumberOn?@"1":@"0" forKey:pDisplayNumberStatus];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/change_notification_status" WithComptionBlock:^(id result, NSError *error) {

        if (!error) {
            [self.dicDataArray setValue:isNotificationOn?@"1":@"0" forKey:@"isNotificationOn"];
            [self.dicDataArray setValue:isNumberOn?@"1":@"0" forKey:@"isNumberOn"];
            [self.menuTableView reloadData];
        }
    }];
    
}

-(void)requestDictForLogout {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:pDeviceToken] forKey:pDeviceToken];
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
            [NSUSERDEFAULT removeObjectForKey:@"userID"];
//            [APPDELEGATE stopLocation];
            [APPDELEGATE stopLocationManager];

            [APPDELEGATE setupForApplicationLaunch];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}
// logout from mongo DB client
-(void)requestDictToLogoutFromMongoDB{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"removeToken" WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
            NSLog(@"hello user logout %@",result);
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
//    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
//        
//        if (!error) {
//            strCount = [strCount stringByAppendingString:[NSString stringWithFormat:@",%@",[result objectForKeyNotNull:@"unreadMessage" expectedObj:@""]]];
//            [self.menuTableView reloadData];
//        }
//    }];
//    
//}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getUnreadCount" object:nil];
}


@end
