//
//  SelectChoiceViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 12/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"

static NSString *cellIdentifier = @"SelectChoiceCollectionViewCell";

@interface SelectChoiceViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DemoPopDelegate>
{
    NSDictionary *dictDataArray;
    NSString *strCount;
}

@property (weak, nonatomic) IBOutlet UILabel *lblSelectChoice;

@property (strong, nonatomic) IBOutlet UICollectionView *choiceCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UILabel *notificationCountLbl;
@property (weak, nonatomic) IBOutlet UIButton *notificationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *notificationImageView;

@end

@implementation SelectChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
    [self getTravelTime];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestDictForCount];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Method

-(void)initialSetup {
    
    [_notificationImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];
    [_notificationCountLbl setHidden:YES];
    _notificationBtn.layer.cornerRadius = 18.0;
    _notificationBtn.layer.masksToBounds = YES;
    _notificationCountLbl.layer.cornerRadius = 10.0;
    _notificationCountLbl.layer.masksToBounds = YES;
    _lblSelectChoice.text = KNSLOCALIZEDSTRING(@"Select Your Choice");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    }
    
    //Set Title and Corresponding Image
    NSArray *titleArray = [[NSMutableArray alloc]initWithObjects:@"Email",@"Chat",@"Status",@"Service Tracking",@"Job Requests",@"Subscribe",@"Edit Profile",@"Logout",nil];
    NSArray *imageArray = [[NSMutableArray alloc]initWithObjects:@"email_icon_new",@"chat_icon1",@"status_icon",@"icon-1",@"job_icon",@"sub_icon",@"edit_profile_icon",@"logout_icon1",nil];
    dictDataArray = [[NSDictionary alloc]initWithObjectsAndKeys:titleArray,@"TITLE",imageArray,@"IMAGE", nil];
    
    //Set Delegate and Datasouce of CollectionView
    [_choiceCollectionView setDataSource:self];
    [_choiceCollectionView setDelegate:self];
    
    //Register the Cell
    [_choiceCollectionView registerNib:[UINib nibWithNibName:@"SelectChoiceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    // observer for getting unread count
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callApiToGetUnreadCount) name:@"getUnreadCount" object:nil];

}

/**
 get count of unread meassages when receive a remote notification.
 */
-(void)callApiToGetUnreadCount{
    [self requestDictForCount];
}
#pragma mark - UICollectionView DataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[dictDataArray valueForKey:@"TITLE"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectChoiceCollectionViewCell *cell = (SelectChoiceCollectionViewCell *)[_choiceCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.choiceLabel.text = KNSLOCALIZEDSTRING([[dictDataArray valueForKey:@"TITLE"] objectAtIndex:indexPath.row]);
    cell.choiceImageView.image = [UIImage imageNamed:[[dictDataArray valueForKey:@"IMAGE"] objectAtIndex:indexPath.row]];
    NSArray *arrayCount = [strCount componentsSeparatedByString:@","];
    if (indexPath.item == 0) {
        [cell.alertLabel setText:[arrayCount firstObject]];
        ([[arrayCount firstObject] integerValue] > 0) ? [cell.alertLabel setHidden:NO] : [cell.alertLabel setHidden:YES];
        
    }else if (indexPath.item == 1) {
        if([arrayCount count]>3){
            [cell.alertLabel setText:arrayCount[3]];
            ([arrayCount[3] integerValue] > 0) ? [cell.alertLabel setHidden:NO] : [cell.alertLabel setHidden:YES];
        }else{
            [cell.alertLabel setHidden:YES];
        }
    }else if (indexPath.item == 3) {
        [cell.alertLabel setText:arrayCount[1]];
        ([arrayCount[1] integerValue] > 0) ? [cell.alertLabel setHidden:NO] : [cell.alertLabel setHidden:YES];
        
    }else if (indexPath.item == 4) {
        [cell.alertLabel setText:arrayCount[2]];
        ([arrayCount[2] integerValue] > 0) ? [cell.alertLabel setHidden:NO] : [cell.alertLabel setHidden:YES];
        
    }else {
        [cell.alertLabel setHidden:YES];
        
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (SCREEN_WIDTH == 320) {
        return CGSizeMake(90, 130);
    }else
        return CGSizeMake(100, 130);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            //            EmailListViewController *emailObj = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
            //            THREEOPTIONSCOMINGFROM = Social;
            //            [self.navigationController pushViewController:emailObj
            //                                                 animated:YES];
            [self requestDictForReadUnread:@"email"];
        }
            break;
        case 1: {
            MessagesVC *messageObj = [[MessagesVC alloc]initWithNibName:@"MessagesVC" bundle:nil];
            THREEOPTIONSCOMINGFROM = Social;
            [self.navigationController pushViewController:messageObj
                                                 animated:YES];
        }
            break;
        case 2: {
            StatusAvailableBusyVC *popOver = [[StatusAvailableBusyVC alloc]initWithNibName:@"StatusAvailableBusyVC" bundle:nil];
            
            popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            popOver.modalPresentationStyle =  UIModalPresentationFormSheet;
            
            [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
        }
            break;
        case 3: {
            ServiceTrackingViewController *serviceObj = [[ServiceTrackingViewController alloc]initWithNibName:@"ServiceTrackingViewController" bundle:nil];
            THREEOPTIONSCOMINGFROM = Social;
            serviceObj.isFromSidePanel = NO;
            [self.navigationController pushViewController:serviceObj
                                                 animated:YES];
        }
            break;
        case 4: {
            //            JobRequestVC *requestObj = [[JobRequestVC alloc]initWithNibName:@"JobRequestVC" bundle:nil];
            //            [self.navigationController pushViewController:requestObj
            //                                                 animated:YES];
            [self requestDictForReadUnread:@"job"];
        }
            break;
        case 5: {
            [self.view endEditing:YES];
//            SubscriptionPlanPopUpVC *demoVC = [[SubscriptionPlanPopUpVC alloc] initWithNibName:@"SubscriptionPlanPopUpVC" bundle:nil];
//            demoVC.delegate = self;
//            [self.navigationController presentPopupViewController:demoVC animationType:MJPopupViewAnimationFade];
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Coming soon.") onController:self];
        }
            break;
        case 6: {
            EditProfileViewController *editObj = [[EditProfileViewController alloc]initWithNibName:@"EditProfileViewController" bundle:nil];
            [self.navigationController pushViewController:editObj
                                                 animated:YES];
        }
            break;
        case 7: {
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

- (IBAction)menuAction:(id)sender {
    [self.view endEditing:YES];
    [self.sidePanelController showLeftPanelAnimated:YES];
}


#pragma mark - Subscription PopUp Delegate Methods
-(void)cancelButtonMethod{
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
}


/*********************** Service Implementation Methods ****************/


-(void)requestDictForReadUnread:(NSString *)type {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:type forKey:@"type"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/read_unread_status" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"email"]) {
                EmailListViewController *emailObj = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:emailObj
                                                     animated:YES];
            }else if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"job"]) {
                JobRequestVC *requestObj = [[JobRequestVC alloc]initWithNibName:@"JobRequestVC" bundle:nil];
                [self.navigationController pushViewController:requestObj
                                                     animated:YES];
            }else if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"notification"]){
                NotificationViewController *notificationObject = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
                notificationObject.isFromSelectYourChoice = YES;
                [self.navigationController pushViewController:notificationObject animated:YES];
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
            
            strCount = [NSString stringWithFormat:@"%@,%@,%@", [result objectForKeyNotNull:@"email" expectedObj:@""], [result objectForKeyNotNull:@"service_tracking_count" expectedObj:@""], [result objectForKeyNotNull:@"job" expectedObj:@""]];

            [_notificationCountLbl setHidden:[[result objectForKeyNotNull:@"notification" expectedObj:@""] intValue]>0?NO:YES];
            _notificationCountLbl.text = [result objectForKeyNotNull:@"notification" expectedObj:@""];
//            [self.choiceCollectionView reloadData];
            [self requestToFetchMessageCount];
        }
    }];
    
}


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
            
            [NSUSERDEFAULT removeObjectForKey:@"userID"];
//            [APPDELEGATE stopLocation]
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

-(void)requestToFetchMessageCount {
    
    NSString *apiName = [NSString stringWithFormat:@"unreadMessageCount/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            NSMutableDictionary * dist_unread = [result objectForKeyNotNull:@"unreadMessage" expectedObj:@""];
            strCount = [strCount stringByAppendingString:[NSString stringWithFormat:@",%@",[dist_unread objectForKeyNotNull:@"totalUnreadUser" expectedObj:@""]]];
            [self.choiceCollectionView reloadData];
        }
    }];
    
}

-(void)getTravelTime{
    
    NSString *strUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@", 28.14534,  77.24534, 28.34534,  77.34534, @"DRIVING"];
    NSURL *url = [NSURL URLWithString:[@"http://maps.googleapis.com/maps/api/directions/json?origin=18.635413,72.9766233&destination=28.5366222,77.2664587&sensor=false&mode=DRIVING" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if(jsonData != nil)
    {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *arrDistance=[result objectForKey:@"routes"];
        if ([arrDistance count]==0) {
            NSLog(@"N.A.");
        }
        else{
            NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
            NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
            NSLog(@"%@",[NSString stringWithFormat:@"Estimated Time %@",[[dictleg   objectForKey:@"duration"] objectForKey:@"text"]]);
        }
    }
    else{
        NSLog(@"N.A.");
    }
    
}
//-(void)requestToFetchMessageCount {
//    
//
//    NSString *apiName = [NSString stringWithFormat:@"unreadMessage/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
//    
//    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
//        
//        if (!error) {
//            strCount = [strCount stringByAppendingString:[NSString stringWithFormat:@",%@",[result objectForKeyNotNull:@"unreadMessage" expectedObj:@""]]];
//            [self.choiceCollectionView reloadData];
//        }
//    }];
//    
//}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getUnreadCount" object:nil];
}
- (IBAction)notificationBtnAction:(id)sender {
    [self requestDictForReadUnread:@"notification"];

}


@end
