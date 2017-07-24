//
//  ClientDetailViewController.m
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ClientDetailViewController.h"
#import "CustomChatVC.h"
#import "ProfileTableViewCell.h"
#import "ClientDetailTableViewCell.h"
#import "RatingTableViewCell.h"
#import "UserTableViewCell.h"
#import "HeaderFile.h"
#import "ReviewsRatingVC.h"
#import "DXStarRatingView.h"


@import GoogleMaps;

static NSString *cellIdentifier = @"ProfileTableViewCell";
static NSString *cellIdentifierSecond = @"ClientDetailTableViewCell";
static NSString *cellIdentifierThird = @"RatingTableViewCell";
static NSString *cellIdentifierFourth = @"UserTableViewCell";

@interface ClientDetailViewController ()<UITableViewDataSource,UITableViewDelegate,GMSMapViewDelegate,ADCircularMenuDelegate>
{
    NSDictionary *dictDataArray,*dictArray;
    UserInfo *modalObject;
    ADCircularMenu *circularMenuVC;
    NSMutableArray *array_locationDetail;
    
    NSMutableArray *userDataArray;
    
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *clientDetailTableView;

@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnDecline;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;
@property (weak,nonatomic ) NSString *phoneNumber;

@end

@implementation ClientDetailViewController

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initialSetup];
    [self requestDictForReadUnread:@"job"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    array_locationDetail = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
    [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
    [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
    
    NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
    [locationDictionary2 setValue:self.particularClientDetail.userLatitute forKey:@"lattitue"];
    [locationDictionary2 setValue:self.particularClientDetail.userLongitute forKey:@"longitute"];
    
    [array_locationDetail addObject:locationDictionary1];
    [array_locationDetail addObject:locationDictionary2];
    
    [self showAllLocationDetail];
    if (self.isFromNotificationScreen) {
        [self makeServiceCallToGetUserDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    if (SCREEN_HEIGHT == 480) {
        self.clientDetailTableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    }else if (SCREEN_HEIGHT == 568){
        self.clientDetailTableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 110);
    }
    
    UIButton * mapZoomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)];
    [self.mapView addSubview:mapZoomBtn];
    [mapZoomBtn addTarget:self action:@selector(mapZoomBtntpped) forControlEvents:UIControlEventTouchUpInside];

    _navTitle.text = KNSLOCALIZEDSTRING(@"Client's  Detail");
    [self.btnAccept setTitle:KNSLOCALIZEDSTRING(@"Accept") forState:UIControlStateNormal] ;
    [self.btnChat setTitle:KNSLOCALIZEDSTRING(@"Chat") forState:UIControlStateNormal] ;
    [self.btnEmail setTitle:KNSLOCALIZEDSTRING(@"Email") forState:UIControlStateNormal] ;
    [self.btnDecline setTitle:KNSLOCALIZEDSTRING(@"Decline") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Register Cell
    [self.clientDetailTableView registerNib:[UINib nibWithNibName:@"ClientDetailTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierSecond];
    [self.clientDetailTableView registerNib:[UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self.clientDetailTableView registerNib:[UINib nibWithNibName:@"RatingTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierThird];
    [self.clientDetailTableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierFourth];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    userDataArray = [NSMutableArray array];
    // added
    if (_isHideAcceptCancelButton) {
        [self.btnAccept setHidden:self.isHideAcceptCancelButton];
        [self.btnDecline setHidden:self.isHideAcceptCancelButton];
    }
    self.clientDetailTableView.rowHeight = UITableViewAutomaticDimension;
    self.clientDetailTableView.estimatedRowHeight = 200;
    if (self.isFromNotificationScreen) {
        [self.btnAccept setHidden:self.isHideAcceptCancelButton];
        [self.btnDecline setHidden:self.isHideAcceptCancelButton];
    }
    
    CLLocationDegrees latitude = [self.particularClientDetail.userLatitute doubleValue];
    CLLocationDegrees longitude = [self.particularClientDetail.userLongitute doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];
    
    
    [self requestDictForReviewList:pagination];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.clientDetailTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self  requestDictForReviewList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
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
        self.particularClientDetail.userAddress = str;
        [self.clientDetailTableView reloadData];
        //  cell.tagLbl.text = str;
        
    } failureHandler:^(NSError *error) {
        NSLog(@"Error : %@", error);
    }
     ];
    //    return finalDic;
    
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
#pragma mark - Show all the BootCamp Location Markers

-(void)showAllLocationDetail {
    [ _mapView clear];
    if ([array_locationDetail count] != 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:1]];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]) zoom:18];
        
        // zoom the map into the users current location
        [self.mapView animateWithCameraUpdate:updatedCamera];
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
        
        marker.map = self.mapView;
        //  marker.title = [NSString stringWithFormat:@"%d",i];
    }
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        self.mapView.myLocationEnabled = YES;
    //    });
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        ClientDetailTableViewCell *cell = (ClientDetailTableViewCell *)[self.clientDetailTableView dequeueReusableCellWithIdentifier:cellIdentifierSecond];
        
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"]) {
            cell.clientContactNumber.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        if([TRIM_SPACE(self.self.particularClientDetail.userContactNumber) length]) {
            [cell.clientContactNumber setHidden:NO];
        }
        else {
            [cell.clientContactNumber setHidden:YES];
        }
        
        cell.clientName.text =KNSLOCALIZEDSTRING(self.particularClientDetail.userName);
        cell.clientAddress.text = KNSLOCALIZEDSTRING(self.particularClientDetail.userAddress);
        cell.clientAge.text = KNSLOCALIZEDSTRING(self.particularClientDetail.userAge);
        [cell.clientContactNumber setTitle:KNSLOCALIZEDSTRING(self.particularClientDetail.userContactNumber) forState:UIControlStateNormal];
//        [cell.clientImage sd_setImageWithURL:self.particularClientDetail.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_img1"]];
        [cell.clientImage sd_setImageWithURL:self.particularClientDetail.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
        _phoneNumber = self.particularClientDetail.userContactNumber;
        [cell.clientContactNumber addTarget:self action:@selector(phoneNumberAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.clientAddress.text = self.particularClientDetail.userAddress;
        //Rating
//        [cell.ratingView setStars:(int)self.particularClientDetail.starRating];
        [cell.ratingView setUserInteractionEnabled:NO];
        if (self.isFromNotificationScreen || _isfromRemoteNotification) {
            [cell.ratingView setStars:(int)self.particularClientDetail.ratingNumber];
        }else{
            [cell.ratingView setStars:[self.particularClientDetail.starRating intValue]];
        }

//        [cell.ratingView setIsOnReview:YES];

        return cell;
        
    }
    else if(indexPath.row == 5) {
        RatingTableViewCell *cell = (RatingTableViewCell *)[self.clientDetailTableView dequeueReusableCellWithIdentifier:cellIdentifierThird];
        
        cell.lblRatingReview.text = KNSLOCALIZEDSTRING(@"Ratings and Reviews");
        cell.lblRatingReview.backgroundColor = [UIColor colorWithRed:0/255.0 green:183/255.0 blue:163/255.0 alpha:1.0];
        cell.lblRatingReview.layer.cornerRadius = 15.0f;
        cell.lblRatingReview.layer.masksToBounds = YES;
        return cell;
    }
    else if (indexPath.row < 5){
        ProfileTableViewCell *cell = (ProfileTableViewCell *)[self.clientDetailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell.btnContact setHidden:YES];
        [cell.lblDescription setHidden:NO];
        
        switch (indexPath.row) {
            case 1:
                
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Job Price");
                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:15.0f]];
                cell.lblDescription.text = [self.particularClientDetail.userPrice length] ?self.particularClientDetail.userPrice : self.particularClientDetail.clientPrice;
                break;
                
            case 2:
                
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Job Title");
                cell.lblDescription.text = self.particularClientDetail.jobName;
                break;
                
            case 3:
                
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Description");
                cell.lblDescription.text = self.particularClientDetail.jobdescription;
                break;
                // hidden as per suggestion by client
            case 4:
                cell.baseView.hidden = YES;
                //                cell.lblData.text = KNSLOCALIZEDSTRING(@"Email");
                //                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:15.0f]];
                //                cell.lblDescription.text = self.particularClientDetail.userEmail;
                //                cell.lblData.text = @"";
                //                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:15.0f]];
                //                cell.lblDescription.text = @"";
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0)
    {
        return 100;
    }
    else if(indexPath.row > 5)
    {
        return 100;
    }else if (indexPath.row == 4)
    {
        return 0;
    }
    else
        return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 5) {
        ReviewsRatingVC *ratingVC = [[ ReviewsRatingVC alloc] initWithNibName:@"ReviewsRatingVC" bundle:nil];
        ratingVC.dataSourceArray = userDataArray;
        [self.navigationController pushViewController:ratingVC animated:YES];
    }
}
-(void)phoneNumberAction : (UIButton *) sender {
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

- (IBAction)btnAcceptAction:(id)sender {
    [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to accept the job request?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
        if (index) {
            [self requestDictForAcceptJobRequest];
        }
    }];
}
- (IBAction)btnChatAction:(id)sender {
    if ( [self.particularClientDetail.block_status isEqualToString:@"1"]||[_block_status isEqualToString:@"1"]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
    }
    else
    {
        CustomChatVC *chatVC = [[CustomChatVC alloc]init];
        chatVC.presentBool = NO;
        chatVC.userProfileDetail = self.particularClientDetail;
        
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    

}

- (IBAction)btnEmailAction:(id)sender {
    if ([self.particularClientDetail.block_status isEqualToString:@"1"]|| [_block_status isEqualToString:@"1"] ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
    }
    else
    {
        EmailVC *mailObject = [[EmailVC alloc]initWithNibName:@"EmailVC" bundle:nil];
        mailObject.particularDetail = self.particularClientDetail;
        [self.navigationController pushViewController:mailObject animated:YES];
    }

}

- (IBAction)btnDeclineAction:(id)sender {
    [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to decline the job request?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
        if (index) {
            [self requestDictForDeclineJobRequest];
        }
    }];
}

- (IBAction)btnBackAction:(id)sender {
    //     [manager cancelRequestwithName:WebMethodReviewList];
    //     [manager cancelRequestwithName:WebMethodAcceptJobRequest];
    //     [manager cancelRequestwithName:WebMethodDeclineJobRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSocialAction:(id)sender {
    circularMenuVC = nil;
    
    //use 3 or 7 or 12 for symmetric look (current implementation supports max 12 buttons)
    NSArray *arrImageName = [[NSArray alloc] initWithObjects:
                             @"chat_icon",
                             @"mail_icon",
                             @"tracker_icon",
                             nil];
    
    circularMenuVC = [[ADCircularMenu alloc] initWithMenuButtonImageNameArray:arrImageName
                                                     andCornerButtonImageName:@"global_icon"];
    circularMenuVC.delegateCircularMenu = self;
    [circularMenuVC show];
}

#pragma mark - Delegate Method Of ADCircularMenu

- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[MessagesVC class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[MessagesVC class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[MessagesVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[MessagesVC class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            if (isNotFound) {
                MessagesVC *messageObject = [[MessagesVC alloc]initWithNibName:@"MessagesVC" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:messageObject animated:YES];
            }
        }
            break;
        case 1:{
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[EmailListViewController class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[EmailListViewController class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[EmailListViewController class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[EmailListViewController class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            if (isNotFound) {
                EmailListViewController *emailObject = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:emailObject animated:YES];
            }
        }
            break;
        case 2: {
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[ServiceTrackingVC class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[ServiceTrackingVC class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[ServiceTrackingVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[ServiceTrackingVC class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            if (isNotFound) {
                ServiceTrackingVC *serviceTrackingObject = [[ServiceTrackingVC alloc]initWithNibName:@"ServiceTrackingVC" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:serviceTrackingObject animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) {
        
        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
            
            [self requestDictForReviewList:pagination];
        }
    }
}


#pragma mark - Service Implementation Methods

-(void)requestDictForReviewList:(CCPagination *)page {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
//    [requestDict setObject:self.userId ? self.userId : _particularClientDetail.userID forKey:pUserId];
    // new changes
    [requestDict setObject:self.userId ? self.userId : _particularClientDetail.userID forKey:@"review_id"];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:@"10" forKey:pPageSize];
    [requestDict setObject:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/review_data" WithComptionBlock:^(id result, NSError *error) {

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            if ([pagination.pageNo integerValue] == 0) {
                [userDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.clientDetailTableView.bounds.size.width,  self.clientDetailTableView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.clientDetailTableView.backgroundView = noDataLabel;
                
                [self.clientDetailTableView reloadData];
            }else {
                isLoadMoreExecuting = YES;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                
                NSMutableArray *reviewArray = [result objectForKeyNotNull:pReviewList expectedObj:[NSArray array]];
                for (NSDictionary *dict in reviewArray) {
                    [userDataArray addObject:[ReviewRelatedData parseReviewList:dict]];
                }
                [self.clientDetailTableView reloadData];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}


-(void)requestDictForAcceptJobRequest {
    
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pServicePrividerID];
    [requestDict setObject:self.particularClientDetail.userID forKey:pClientID];
    [requestDict setValue:(self.isFromNotificationScreen)?self.jobId:self.particularClientDetail.jobID forKey:pJobId];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/accept_job_request" WithComptionBlock:^(id result, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [self.delegate methodForListAfterAcceptAndDecline:self.particularClientDetail];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Your main thread code goes in here
                NSLog(@"Im on the main thread");
                BOOL isControllerFound = NO;
                NSArray *arrayViewController = [[APPDELEGATE navController] viewControllers];
                for (UIViewController *viewController in arrayViewController) {
                    if([viewController isKindOfClass:[JASidePanelController class]]) {
                        [[APPDELEGATE navController] popToViewController:viewController animated:NO];
                        isControllerFound = YES;
                        
                        break;
                    }
                }
                
                if (!isControllerFound) {
                    SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
                    [self.sidePanelController setCenterPanel:selectChoiceObject];
                }
            });
            

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}

-(void)requestDictForDeclineJobRequest{
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pServicePrividerID];
    [requestDict setValue:self.particularClientDetail.userID forKey:pClientID];
    [requestDict setValue:(self.isFromNotificationScreen)?self.jobId:self.particularClientDetail.jobID forKey:pJobId];
    [requestDict setValue:[NSString string] forKey:pCancelRegion];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/cancel_job_request" WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
            [self.delegate methodForListAfterAcceptAndDecline:self.particularClientDetail];
            BOOL isControllerFound = NO;
            
            NSArray *arrayViewController = [[APPDELEGATE navController] viewControllers];
            for (UIViewController *viewController in arrayViewController) {
                if([viewController isKindOfClass:[JASidePanelController class]]) {
                    [[APPDELEGATE navController]popToViewController:viewController animated:NO];
                    isControllerFound = YES;
                    
                }
            }
            if (!isControllerFound) {
                SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
                [self.sidePanelController setCenterPanel:selectChoiceObject];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
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
            

            self.particularClientDetail = [[RowDataModal alloc] init];
            [userDataArray removeAllObjects];
            [userDataArray addObject:[RowDataModal parseCatagoryList:result comingFromServiceTracking:NO]];
            self.particularClientDetail = [userDataArray firstObject];
            
            [self updateLocation];
            [self showAllLocationDetail];
            [self initialSetup];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}
//#pragma mark - Networking Client Delegate Method
//
//-(void)serviceResponse:(id)response andMethodName:(WebMethodType)methodName {
//    switch (methodName) {
//            
//        case WebMethodAcceptJobRequest: {
//            [self.delegate methodForListAfterAcceptAndDecline:self.particularClientDetail];
//            //            [self.navigationController popViewControllerAnimated:YES];
//            
//            BOOL isControllerFound = NO;
//            NSArray *arrayViewController = [[APPDELEGATE navController] viewControllers];
//            for (UIViewController *viewController in arrayViewController) {
//                if([viewController isKindOfClass:[JASidePanelController class]]) {
//                    [[APPDELEGATE navController] popToViewController:viewController animated:NO];
//                    isControllerFound = YES;
//                }
//            }
//            
//            if (!isControllerFound) {
//                SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
//                [self.sidePanelController setCenterPanel:selectChoiceObject];
//            }
//            
//            
//        }
//            break;
//        case WebMethodDeclineJobRequest: {
//            [self.delegate methodForListAfterAcceptAndDecline:self.particularClientDetail];
//            BOOL isControllerFound = NO;
//            
//            NSArray *arrayViewController = [[APPDELEGATE navController] viewControllers];
//            for (UIViewController *viewController in arrayViewController) {
//                if([viewController isKindOfClass:[JASidePanelController class]]) {
//                    [[APPDELEGATE navController]popToViewController:viewController animated:NO];
//                    isControllerFound = YES;
//                    
//                }
//            }
//            if (!isControllerFound) {
//                SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
//                [self.sidePanelController setCenterPanel:selectChoiceObject];
//            }
//        }
//            break;
//        case WebMethodReviewList: {
//            if ([pagination.pageNo integerValue] == 0) {
//                [userDataArray removeAllObjects];
//            }
//            
//            if ([[response objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:@"No record found."]) {
//                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.clientDetailTableView.bounds.size.width,  self.clientDetailTableView.bounds.size.height)];
//                noDataLabel.text             = KNSLOCALIZEDSTRING([response objectForKeyNotNull:pResponseMsg expectedObj:@""]);
//                noDataLabel.textColor        = [UIColor whiteColor];
//                noDataLabel.textAlignment    = NSTextAlignmentCenter;
//                self.clientDetailTableView.backgroundView = noDataLabel;
//                
//                [self.clientDetailTableView reloadData];
//            }else {
//                isLoadMoreExecuting = YES;
//                
//                pagination = [CCPagination getPaginationInfoFromDict:[response objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
//                
//                
//                NSMutableArray *reviewArray = [response objectForKeyNotNull:pReviewList expectedObj:[NSArray array]];
//                for (NSDictionary *dict in reviewArray) {
//                    [userDataArray addObject:[ReviewRelatedData parseReviewList:dict]];
//                }
//                [self.clientDetailTableView reloadData];
//            }
//            break;
//        }
//        case WebMethodType_Get_user_details_for_notification:{
//            self.particularClientDetail = [[RowDataModal alloc] init];
//            [userDataArray removeAllObjects];
//            [userDataArray addObject:[RowDataModal parseCatagoryList:response comingFromServiceTracking:NO]];
//            self.particularClientDetail = [userDataArray firstObject];
//            
//            [self updateLocation];
//            [self showAllLocationDetail];
//            [self initialSetup];
//            //            [[AlertView sharedManager]presentAlertWithTitle:@"WebMethodType_Get_user_details_for_notification" message:[NSString stringWithFormat:@"%@-%@",self.particularClientDetail.userLatitute,_particularClientDetail.userLongitute] andButtonsWithTitle:@[@"ok"] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//            //                [self updateLocation];
//            //                [self showAllLocationDetail];
//            //                [self initialSetup];
//            //            }];
//            
//        }
//            break;
//        default:
//            break;
//    }
//}

-(void)updateLocation{
    [array_locationDetail removeAllObjects];
    NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
    [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
    [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
    
    NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
    [locationDictionary2 setValue:self.particularClientDetail.userLatitute forKey:@"lattitue"];
    [locationDictionary2 setValue:_particularClientDetail.userLongitute forKey:@"longitute"];
    //verified.
    //        [locationDictionary2 setValue:modalObject.serviceProviderLongitude forKey:@"longitute"];
    
    [array_locationDetail addObject:locationDictionary1];
    [array_locationDetail addObject:locationDictionary2];
}
//#pragma mark - Networking Error Methods
//
//-(void)serviceError:(id)response andMethodName:(WebMethodType)methodName {
//    isLoadMoreExecuting = YES;
//    
//    [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:[response objectForKeyNotNull:pResponseMsg expectedObj:@""] onController:self.navigationController];
//}


//-(void)connectionFailWithErrorMessage:(NSString *)error andMethodName:(WebMethodType)methodName {
//    isLoadMoreExecuting = YES;
//    
//    [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error onController:self.navigationController];
//}

-(void)requestDictForReadUnread:(NSString *)type {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:type forKey:@"type"];
    [requestDict setValue:(self.isFromNotificationScreen)?self.jobId:self.particularClientDetail.jobID forKey:@"id"];

    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/read_unread_status_notification" WithComptionBlock:^(id result, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if (!error) {

        }
    }];
}

// COde to add pop up
-(void)mapZoomBtntpped{
    [self.view endEditing:YES];
    GMSMapView *mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    mapView.tag = 88888;
    UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    navView.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0];
    UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 20, 50, 40)];
    [cancelBtn setImage:[UIImage imageNamed:@"cross_icon"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(removeMapFromView:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = 99999;
    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -70, 25, 150, 40)];
    [titleLbl setText:KNSLOCALIZEDSTRING(@"Location")];
    [titleLbl setFont:[UIFont fontWithName:@"Candara" size:22.0f]];
    [titleLbl setTextColor:[UIColor blackColor]];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    
    [navView addSubview:titleLbl];
    [navView addSubview:cancelBtn];
    [mapView addSubview:navView];
    [self.view addSubview:mapView];
    [self showAllLocationDetailOnPopUp:mapView];
}
// Show location on map.
-(void)showAllLocationDetailOnPopUp:(GMSMapView *)mapPopUP {
    [ mapPopUP clear];
    if ([array_locationDetail count] != 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:1]];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]) zoom:18];
        
        // zoom the map into the users current location
        [mapPopUP animateWithCameraUpdate:updatedCamera];
        
    }
    
    // Creates a marker in the center of the map.
    for (int i = 0 ; i < [array_locationDetail count] ; i ++) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:i]];
        marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]);
        (i==0)?(marker.icon = [UIImage imageNamed:@"location"]):(marker.icon = [UIImage imageNamed:@"location2"]);
        marker.map = mapPopUP;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    
}

-(void)removeMapFromView:(UIButton *)sender{
    UIView * mapView = [self.view viewWithTag:88888];
    [mapView removeFromSuperview];
}
@end
