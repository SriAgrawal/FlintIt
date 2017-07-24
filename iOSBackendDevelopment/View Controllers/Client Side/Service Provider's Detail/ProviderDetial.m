//
//  ProviderDetia.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 08/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ProviderDetial.h"
#import "EmailListViewController.h"
#import "EmailVC.h"
#import "DXStarRatingView.h"
#import "AppUtilityFile.h"
#import "UIViewController+CWPopup.h"
#import "PopUPVC.h"
#import "MacroFile.h"
#import "AppDelegate.h"
#import "ReviewViewController.h"
#import "MessagesVC.h"
#import "UIViewController+JASidePanel.h"
#import "MessagesVC.h"
#import "ADCircularMenu.h"
#import "EmailListViewController.h"
#import "ServiceTrackingVC.h"
#import "ChatVC.h"
#import "ReportProfileVC.h"
#import "CustomChatVC.h"
#import "HeaderFile.h"


@import GoogleMaps;


@interface ProviderDetial ()<UIScrollViewDelegate,GMSMapViewDelegate,ADCircularMenuDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    ADCircularMenu *circularMenuVC;
    NSMutableArray *array_locationDetail;
    ProviderDetial *providerDetailObj;
    NSMutableArray *userDataArray;
    BOOL markerIsTapped;
    NSTimer *timer;
    IBOutlet UIButton *leftArrowButton;
    IBOutlet UIButton *rightArrowButton;


}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNoRightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@property (strong, nonatomic) IBOutlet UIView *headerView;

//Top View Outlet
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet DXStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCatagoryName;
@property (weak, nonatomic) IBOutlet UILabel *userDistance;
@property (weak, nonatomic) IBOutlet UILabel *reviewStatus;
@property (weak, nonatomic) IBOutlet UIButton *contactNumberBtn;


@property (weak, nonatomic) IBOutlet UIButton *userWorkedStatus;

//Map View Outlet
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

//User Address Detail
@property (weak, nonatomic) IBOutlet UIView *userAddressDescription;

@property (weak, nonatomic) IBOutlet UILabel *userAddress;
@property (weak, nonatomic) IBOutlet UILabel *userAddressDetail;

//UserPhoto And Price
@property (weak, nonatomic) IBOutlet UIView *UserPhotoAndPriceView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewProperty;

@property (weak, nonatomic) IBOutlet UIButton *reportProfileBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendingBtnProperty;

@property (weak, nonatomic) IBOutlet UILabel *lblPhotos;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;

//Lower View Outlet
@property (weak, nonatomic) IBOutlet UIView *lowerView;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;

@property (weak, nonatomic) IBOutlet UIButton *emailProperty;
@property (weak, nonatomic) IBOutlet UIButton *reviewProperty;
@property (weak, nonatomic) IBOutlet UIButton *chatProperty;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak,nonatomic ) NSString *phoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightContraint;
@property (weak, nonatomic) IBOutlet UIButton *mapZoomBtn;

@end

@implementation ProviderDetial

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate startLocation];
//    [self updateLocationTracking];
    userDataArray = [[NSMutableArray alloc]init];
    
    // Code to adjust map according to screen.
    self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 604);
    self.mapViewHeightContraint.constant = 70;
//    if (SCREEN_HEIGHT == 480) {
//        self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 416);
//        self.mapViewHeightContraint.constant = 30;
//    }else if (SCREEN_HEIGHT == 568){
//        self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 504);
//        self.mapViewHeightContraint.constant = 20;
//    }else if (SCREEN_HEIGHT == 667){
//        self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 604);
//        self.mapViewHeightContraint.constant = 70;
//    }
    UIButton * mapZoomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)];
    [self.mapView addSubview:mapZoomBtn];
    [mapZoomBtn addTarget:self action:@selector(mapZoomBtntpped) forControlEvents:UIControlEventTouchUpInside];
//    self.mapView 
    
    //Call API Method to get user Deatil for notification
    if (self.isFromNotificationScreen) {
        [self makeServiceCallToGetUserDetail];
    }

    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshProviderDetalsWith:(NSNotification *)notification {
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.emailProperty setBackgroundColor:[UIColor clearColor]];
    [self.reviewProperty setBackgroundColor:[UIColor clearColor]];
    [self.chatProperty setBackgroundColor:[UIColor clearColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    array_locationDetail = [[NSMutableArray alloc]init];
    [self updateLocation:self.particularServiceProviderDetail];
    if (!self.isFromNotificationScreen)
        [self showAllLocationDetail];
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateLocationTracking) userInfo:nil repeats:YES];

//    NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
//    [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
//    [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
//    
//    NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
//    [locationDictionary2 setValue:self.particularServiceProviderDetail.userLatitute forKey:@"lattitue"];
//    [locationDictionary2 setValue:self.particularServiceProviderDetail.userLongitute forKey:@"longitute"];
//    
//    NSLog(@"My lat------%@",[APPDELEGATE latitude]);
//    NSLog(@"My Long------%@",[APPDELEGATE longitude]);
//    NSLog(@"lat------%@",self.particularServiceProviderDetail.userLatitute);
//    NSLog(@"Long------%@",self.particularServiceProviderDetail.userLongitute);
//
//    
//    [array_locationDetail addObject:locationDictionary1];
//    [array_locationDetail addObject:locationDictionary2];
//    
//    [self showAllLocationDetail];
}

-(void)updateLocationTracking{
    // call API get respone parse data then
   
    NSMutableDictionary * requestDict  = [[NSMutableDictionary alloc]init];
//    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"login_user_id"];
//    [requestDict setValue:self.particularServiceProviderDetail.userID forKey:@"user_id"];
    
//  [requestDict setValue:@"158" forKey:@"user_id"];notification_detail_id
    
    // new added
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"user_id"];
    [requestDict setValue:self.particularServiceProviderDetail.userID forKey:@"get_user_details_id"];

    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/get_user_details" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
            [userDataArray removeAllObjects];
            for (NSDictionary *rowData in categoryList) {
                [userDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
            }
            
            RowDataModal *tempData = [userDataArray firstObject];
            
            [_tblView  reloadData];
            [self updateLocation:tempData];
            [self initialSetup];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];

}


#pragma mark -Helper Method

-(void)initialSetup {
    
     _navTitle.text = KNSLOCALIZEDSTRING(@"Provider's Detail");
     _lblPhotos.text = KNSLOCALIZEDSTRING(@"Photos");
     _lblPrice.text = KNSLOCALIZEDSTRING(@"Price/Hour*");
    [self.reportProfileBtn setTitle:KNSLOCALIZEDSTRING(@"Report Profile") forState:UIControlStateNormal] ;
    [self.reviewProperty setTitle:KNSLOCALIZEDSTRING(@"Review") forState:UIControlStateNormal] ;
    [self.sendingBtnProperty setTitle:KNSLOCALIZEDSTRING(@"Send Hiring Request") forState:UIControlStateNormal] ;
    [self.emailProperty setTitle:KNSLOCALIZEDSTRING(@"Email") forState:UIControlStateNormal] ;
    [self.chatProperty setTitle:KNSLOCALIZEDSTRING(@"Chat") forState:UIControlStateNormal] ;
    
    [self.sendingBtnProperty setTitle:KNSLOCALIZEDSTRING(self.particularServiceProviderDetail.userJobStatus) forState:UIControlStateNormal];
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];

    // current location
    CLLocationDegrees latitude = [self.particularServiceProviderDetail.userLatitute doubleValue];
    CLLocationDegrees longitude = [self.particularServiceProviderDetail.userLongitute doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    [self getUserUpdateLocation:coordinate];
    
    if(self.particularServiceProviderDetail.isTakenFirstJob) {
        [self.favouriteButton setHidden:NO];

    }
    else {
        [self.favouriteButton setHidden:YES];
        if (SCREEN_WIDTH == 320) {
            if ([language isEqualToString:@"ar"]) {
                _phoneNoRightConstraint.constant = -28;
                [_reviewStatus setTextAlignment:NSTextAlignmentLeft];
            }else{
                _phoneNoRightConstraint.constant = -30;
            }
        }else{
            if ([language isEqualToString:@"ar"]){
                 _phoneNoRightConstraint.constant = 5;
            }else{
                _phoneNoRightConstraint.constant = 0;
            }
        }
    }
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(0,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        _contactNumberBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.userDistance.textAlignment = NSTextAlignmentLeft;
//        _phoneNoRightConstraint.constant += 25;
//         _phoneNoRightConstraint.constant = 5;

    }
    
    //uicollection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(50.0, 50.0);
    flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
//    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SignUpCollectionViewCell" bundle:nil]                         forCellWithReuseIdentifier :@"SignUpCollectionViewCell"];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    //Set table Header View
    [self.tblView setTableHeaderView:self.headerView];
    
    [self.ratingView setIsOnReview:YES];
    //[self.ratingView setStars:0];
    [self.ratingView setUserInteractionEnabled:NO];

    [self.reportProfileBtn.layer setCornerRadius:15];
    [self.reportProfileBtn.layer setBorderWidth:1];
    [self.reportProfileBtn.layer setBorderColor:[UIColor colorWithRed:32.0/255.0 green:196.0/255.0 blue:167.0/255.0 alpha:1].CGColor];
    [self.reportProfileBtn.layer setMasksToBounds:YES];
    
    [self.lowerView.layer setCornerRadius:25];
    [self.lowerView.layer setBorderWidth:1];
    [self.lowerView.layer setMasksToBounds:YES];
    
    [self.sendingBtnProperty.layer setCornerRadius:22];
    
    [self.reviewProperty.layer setBorderWidth:1];
    [self.reviewProperty.layer setBorderColor:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1].CGColor];
    

    
    self.mapView.delegate = self;
    
  //  [self.userImage.layer setCornerRadius:self.userImage.frame.size.width/2];
    self.userImage.layer.cornerRadius = 50.0;
    [self.userImage setClipsToBounds:YES];

    if ([TRIM_SPACE(self.particularServiceProviderDetail.userContactNumber) length]) {
        [self.contactNumberBtn setHidden:NO];
    }else {
        [self.contactNumberBtn setHidden:YES];
    }
    

//    
//    if([TRIM_SPACE(self.particularServiceProviderDetail.jobID) length]) {
//        [self.reportProfileBtn setHidden:NO];
//        [self.favouriteButton setHidden:NO];
//    }
//    else {
//        [self.reportProfileBtn setHidden:YES];
//        [self.favouriteButton setHidden:YES];
//    }
    
    [self.ratingView setStars:(int)self.particularServiceProviderDetail.ratingNumber];
    self.userName.text = self.particularServiceProviderDetail.userName;
    [self.contactNumberBtn setTitle:self.particularServiceProviderDetail.userContactNumber forState:UIControlStateNormal];
    self.phoneNumber = self.particularServiceProviderDetail.userContactNumber;
    self.userDistance.text = self.particularServiceProviderDetail.userDistance;
    self.reviewStatus.text = self.particularServiceProviderDetail.reviewDetail;
    [self.userWorkedStatus setTitle:self.particularServiceProviderDetail.userNumberFollowed forState:UIControlStateNormal];
    //    NSString *address = [[[NSUserDefaults standardUserDefaults] objectForKey:@"address"]componentsJoinedByString:@","];
    //    self.userAddress.text = self.particularServiceProviderDetail.userAddress;
    //    self.lblAmount.text = self.particularServiceProviderDetail.userPrice;
    
    self.lblAmount.text = [NSString stringWithFormat:@"$%@",self.particularServiceProviderDetail.userPrice];

    //    self.userCatagoryName.text = self.particularServiceProviderDetail.userCatagory;
    self.userCatagoryName.text = KNSLOCALIZEDSTRING(self.particularServiceProviderDetail.userCatagory);

    self.userAddressDetail.text = self.particularServiceProviderDetail.userDescription;
    [self.userImage sd_setImageWithURL:self.particularServiceProviderDetail.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [self.categoryImageView setImage:[UIImage imageNamed:self.particularServiceProviderDetail.userCatagoryImage]];
    self.categoryImageView.image = [self.categoryImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.categoryImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];
    
    self.favouriteButton.selected = self.particularServiceProviderDetail.isAlreadyFavourite;
    NSLog(@"%d",self.favouriteButton.selected);
    
    if (!self.particularServiceProviderDetail.userSampleImage.count) {
        leftArrowButton.hidden = YES;
        rightArrowButton.hidden = YES;
    }
    
    // manage status
    if (self.particularServiceProviderDetail)
        [_statusImageView setImage:!self.particularServiceProviderDetail.userAvailabilty?[UIImage imageNamed:@"busy.png"]:[UIImage imageNamed:@"green.png"]];

}

#pragma mark - Show all the BootCamp Location Markers

-(void)showAllLocationDetail {
    [ _mapView clear];
    if ([array_locationDetail count] != 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:1]];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]) zoom:18];
        
        if (!markerIsTapped) {
            // zoom the map into the users current location
            [self.mapView animateWithCameraUpdate:updatedCamera];
            markerIsTapped = YES;
        }

    }
    
    // Creates a marker in the center of the map.
    for (int i = 0 ; i < [array_locationDetail count] ; i ++) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[array_locationDetail objectAtIndex:i]];
        marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue], [[dict valueForKey:@"longitute"] floatValue]);
        (i==0)?(marker.icon = [UIImage imageNamed:@"location"]):(marker.icon = [UIImage imageNamed:@"location2"]);
        marker.map = self.mapView;
//        GMSMutablePath *path = [GMSMutablePath path];
//        [path addCoordinate:CLLocationCoordinate2DMake([APPDELEGATE latitude].doubleValue,[APPDELEGATE latitude].doubleValue)];
//        [path addCoordinate:CLLocationCoordinate2DMake([[dict valueForKey:@"lattitue"] floatValue],[[dict valueForKey:@"longitute"] floatValue])];
//                                                       
//        GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
//                                                       rectangle.strokeWidth = 5.f;
//                                                       rectangle.map = _mapView;
        //marker.title = [NSString stringWithFormat:@"%d",i];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // self.mapView.myLocationEnabled = YES;
    });
    
    
}

-(void)photoClick:(UIButton *)sender {
    
}

#pragma mark - UICollectionView Delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _particularServiceProviderDetail.userSampleImage.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SignUpCollectionViewCell *cell =(SignUpCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"SignUpCollectionViewCell" forIndexPath:indexPath];
    
    if (_particularServiceProviderDetail.userSampleImage.count) {
        
    NSString *urlString = [NSString stringWithFormat:@"%@", [_particularServiceProviderDetail.userSampleImage objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [cell.sampleImageView sd_setImageWithURL:url];
        [cell.deleteButton setHidden:YES];
    }
    else {
     cell.sampleImageView.image = nil;
  
    }
    return cell;
}

#pragma mark - UIButton Action

- (IBAction)backAction:(id)sender {
    
    [self.delegate changeInTheServiceProviderDetail:self.particularServiceProviderDetail];
//    [manager cancelRequestwithName:WebMethodAddFavourite];
//    [manager cancelRequestwithName:WebMethodDeleteFavouriteList];
//    [manager cancelRequestwithName:WebMethodCancelRequest];
    if(self.isComingFromMenuServiceTracking && self.isRemoteNotificationFlow) {
        
        NSArray *arrayVC = [[APPDELEGATE navController] viewControllers];
        for (UIViewController *viewController in arrayVC) {
            if([viewController isKindOfClass:[JASidePanelController class]]){
                [self.navigationController popToViewController:viewController animated:NO];
            }
        }
        SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
        [self.sidePanelController setCenterPanel:selectChoiceObject];

    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)reportProfileAction:(id)sender {
    
    ReportProfileVC *reportObject = [[ReportProfileVC alloc]initWithNibName:@"ReportProfileVC" bundle:nil];
     reportObject.particularReportDetail = self.particularServiceProviderDetail;
    [self.navigationController pushViewController:reportObject animated:YES];
}

- (IBAction)sendingBtnAction:(id)sender {
   
    UIButton *btn = (UIButton *)sender;
    
    if ([[btn currentTitle] isEqualToString:KNSLOCALIZEDSTRING(@"Send Hiring Request")]) {
        PopUPVC *popOver = [[PopUPVC alloc]initWithNibName:@"PopUPVC" bundle:nil];
        popOver.isCancelRequest = NO;
        popOver.particularServiceProviderDetailInSendRequest = self.particularServiceProviderDetail;
        popOver.delegate = self;
        popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        popOver.modalPresentationStyle =  UIModalPresentationFormSheet;

        [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
    }else if ([[btn currentTitle] isEqualToString:KNSLOCALIZEDSTRING(@"Cancel Job Request")]){
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to cancel the request?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index) {
                [self requestDictForCancelRequest];
            }
        }];
    }
    else if ([[btn currentTitle] isEqualToString:KNSLOCALIZEDSTRING(@"On Going Job")]) {
        if([self.particularServiceProviderDetail.jobStatusString isEqualToString:@"accepted"]) {
            if (self.isComingFromMenuServiceTracking) {
                ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
                providerObj.particularDetail = self.particularServiceProviderDetail;
                
                providerObj.userDetail = self.particularServiceProviderDetail;
                [self.navigationController pushViewController:providerObj animated:YES];
            }
            else {
                ServiceTrackingVC *trackingObject = [[ServiceTrackingVC alloc]initWithNibName:@"ServiceTrackingVC" bundle:nil];
                trackingObject.screenType = @"ProviderDetial";
                [self.navigationController pushViewController:trackingObject animated:YES];
                
//                ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
//                providerObj.particularDetail = self.particularServiceProviderDetail;
//                
//                providerObj.userDetail = self.particularServiceProviderDetail;
//                [self.navigationController pushViewController:providerObj animated:YES];
            }
        }
        else  {

            ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
            providerObj.particularDetail = self.particularServiceProviderDetail;
            providerObj.userDetail = self.particularServiceProviderDetail;

            // To manage pop
            providerObj.isFromNotificationList = YES;
            [self.navigationController pushViewController:providerObj animated:YES];
        }
    }
}

- (IBAction)emailAction:(id)sender {
    
    if ([self.particularServiceProviderDetail.block_status isEqualToString:@"1"]|| [_block_status isEqualToString:@"1"]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
    }
    else
    {
        [self.reviewProperty setBackgroundColor:[UIColor clearColor]];
        [self.chatProperty setBackgroundColor:[UIColor clearColor]];
        
        [self.emailProperty setBackgroundColor:[UIColor colorWithRed:28.0/255.0 green:169.0/255.0 blue:145.0/255.0 alpha:1]];
        
        EmailVC *emailObject = [[EmailVC alloc]initWithNibName:@"EmailVC" bundle:nil];
        emailObject.particularDetail = self.particularServiceProviderDetail;
        [self.navigationController pushViewController:emailObject animated:YES];
    }

}

- (IBAction)reviewAction:(id)sender {
    [self.emailProperty setBackgroundColor:[UIColor clearColor]];
    [self.chatProperty setBackgroundColor:[UIColor clearColor]];
    
    [self.reviewProperty setBackgroundColor:[UIColor colorWithRed:28.0/255.0 green:169.0/255.0 blue:145.0/255.0 alpha:1]];

    ReviewViewController *reviewObject = [[ReviewViewController alloc]initWithNibName:@"ReviewViewController" bundle:nil];
    reviewObject.particularReviewDetail = self.particularServiceProviderDetail;
    [self.navigationController pushViewController:reviewObject animated:YES];
}

- (IBAction)chatAction:(id)sender {
    if ([self.particularServiceProviderDetail.block_status isEqualToString:@"1"] || [_block_status isEqualToString:@"1"]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
    }
    else
    {
        [self.emailProperty setBackgroundColor:[UIColor clearColor]];
        [self.reviewProperty setBackgroundColor:[UIColor clearColor]];
        
        [self.chatProperty setBackgroundColor:[UIColor colorWithRed:28.0/255.0 green:169.0/255.0 blue:145.0/255.0 alpha:1]];
        
        CustomChatVC *chatVC = [[CustomChatVC alloc]init];
        chatVC.presentBool = NO;
        chatVC.userProfileDetail = self.particularServiceProviderDetail;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

- (IBAction)socialButton:(id)sender {
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

- (IBAction)contactButtonAction:(id)sender {
    
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
    // NSLog(@"Circular Button : Clicked button at index : %d",buttonIndex);
}

- (IBAction)favouriteButton:(id)sender {

    if(!self.favouriteButton.selected) {
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to add it as favourite?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index) {
                [self requestDictForAddFavourite:self.favouriteButton.selected];
            }
        }];
    }
    else {
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to remove it as favourite?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index) {
                [self requestDictForAddFavourite:self.favouriteButton.selected];
            }
        }];
    }
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForAddFavourite:(BOOL)isFavourite {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:self.particularServiceProviderDetail.userID forKey:pFavouriteID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    if (isFavourite) {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/delete_favourite_list" WithComptionBlock:^(id result, NSError *error) {
           
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                self.favouriteButton.selected = !self.favouriteButton.selected;
                NSLog(@"%d",self.favouriteButton.selected);
                
                self.particularServiceProviderDetail.isAlreadyFavourite = self.favouriteButton.selected;
            }else
            {
                [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

            }
        }];
        
    }else {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_favourite" WithComptionBlock:^(id result, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                self.favouriteButton.selected = !self.favouriteButton.selected;
                NSLog(@"%d",self.favouriteButton.selected);
                
                self.particularServiceProviderDetail.isAlreadyFavourite = self.favouriteButton.selected;
            }else
            {
                [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
                
            }
        }];
    }
}

-(void)requestDictForCancelRequest {
   
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
    [requestDict setValue:self.particularServiceProviderDetail.userID forKey:pServicePrividerID];
    [requestDict setValue:self.particularServiceProviderDetail.jobID forKey:pJobId];
    [requestDict setValue:[NSString string] forKey:pCancelRegion];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/cancel_job_request" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            self.particularServiceProviderDetail.userJobStatus = @"canceled";
            [self.sendingBtnProperty setTitle:KNSLOCALIZEDSTRING(@"Send Hiring Request") forState:UIControlStateNormal];
        }else
        {
//            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Error!") message:error.localizedDescription andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
    
}
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

- (IBAction)leftArrowBtn:(id)sender {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:YES];
}

- (IBAction)rightArrowBtn:(id)sender {
    NSInteger section=[self.collectionView numberOfSections]-1;
    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    
    [self.collectionView scrollToItemAtIndexPath:lastIndexPath
                                atScrollPosition:UICollectionViewScrollPositionRight
                                        animated:YES];
}
// Call Web API To Get User Detail For Notification

-(void)makeServiceCallToGetUserDetail {
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
//    [requestDict setValue:self.userId forKey:@"user_id"];
    [requestDict setValue:self.jobId forKey:@"job_id"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    // newly added

    [requestDict setObject:self.userId forKey:@"notification_detail_id"];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/get_user_details_for_notification" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            self.particularServiceProviderDetail = [[RowDataModal alloc] init];
            [userDataArray removeAllObjects];
            [userDataArray addObject:[RowDataModal parseCatagoryList:result comingFromServiceTracking:NO]];
            self.particularServiceProviderDetail = [userDataArray firstObject];
            
            [_tblView  reloadData];
            [_collectionView reloadData];
            [self updateLocation:self.particularServiceProviderDetail];
            [self initialSetup];
            [self showAllLocationDetail];

        }else
            {
                [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
                
            }
    }];

    
}

-(void)updateLocation:(RowDataModal*)recieveUserInfo
{
    if ([array_locationDetail count]) {
        [array_locationDetail removeAllObjects];
    }else
    {
        array_locationDetail = [[NSMutableArray alloc]init];
    }
    
    NSMutableDictionary *locationDictionary1 = [NSMutableDictionary dictionary];
    [locationDictionary1 setValue:[APPDELEGATE latitude] forKey:@"lattitue"];
    [locationDictionary1 setValue:[APPDELEGATE longitude] forKey:@"longitute"];
    
    NSMutableDictionary *locationDictionary2 = [NSMutableDictionary dictionary];
    [locationDictionary2 setValue:recieveUserInfo.userLatitute forKey:@"lattitue"];
    [locationDictionary2 setValue:recieveUserInfo.userLongitute forKey:@"longitute"];
    
    NSLog(@"My lat------%@",[APPDELEGATE latitude]);
    NSLog(@"My Long------%@",[APPDELEGATE longitude]);
    NSLog(@"lat------%@",recieveUserInfo.userLatitute);
    NSLog(@"Long------%@",recieveUserInfo.userLongitute);
    
    [array_locationDetail addObject:locationDictionary1];
    [array_locationDetail addObject:locationDictionary2];
    
}


-(void)comingFromSendRequestWithJobId:(NSString*)jobId {
    self.particularServiceProviderDetail.userJobStatus = @"Cancel Job Request";
    self.particularServiceProviderDetail.jobID = jobId;
    [self.sendingBtnProperty setTitle:KNSLOCALIZEDSTRING(@"Cancel Job Request") forState:UIControlStateNormal];
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
        self.userAddress.text = str;
//        [self.categoryTableView reloadData];
        //        self.userAddressLbl.text = str;
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
