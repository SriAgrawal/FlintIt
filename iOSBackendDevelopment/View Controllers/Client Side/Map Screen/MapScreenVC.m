//
//  MapScreenVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 20/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "MapScreenVC.h"
#import "MacroFile.h"
#import "AppUtilityFile.h"
#import "FilterVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "ADCircularMenu.h"
#import "UIViewController+JASidePanel.h"
#import "EmailListViewController.h"
#import "MessagesVC.h"
#import "ServiceTrackingVC.h"
#import "DXStarRatingView.h"
#import "HeaderFile.h"
#import "MarkerInfo.h"

@interface MapScreenVC () <GMSMapViewDelegate,ADCircularMenuDelegate>{
    NSMutableArray *array_locationDetail;
    ADCircularMenu *circularMenuVC;
    RowDataModal *object;
    BOOL markerIsTapped;
    NSTimer *timer;
   

}

@property (strong,nonatomic)NSNumber *index;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (weak, nonatomic) IBOutlet DXStarRatingView *viewStar;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet DXStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAddress;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *workedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starRatingXConstraint;

@property (weak, nonatomic) IBOutlet UIView *userDescriptionView;


@end

@implementation MapScreenVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate startLocation];
//    [appDelegate.locationTracker updateLocationToServer];
    [_userDescriptionView setHidden:YES];
    [self updateLocationTracking];
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateLocationTracking) userInfo:nil repeats:YES];

//    [self initialSetup];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLocationTracking{
    
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
        //[requestDict setValue:self.mapSelectedCatagory forKey:pCatagoryName];
        [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
        [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
        [requestDict setValue:@"" forKey:pPageSize];
        [requestDict setValue:@"" forKey:pPageNumber];
        [requestDict setValue:@"1" forKey:pGetAll];
        [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
         [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

        !_isFromFavourite ?[requestDict setValue:[NSNumber numberWithBool:NO] forKey:pFavourite]:[requestDict setValue:[NSNumber numberWithBool:YES] forKey:pFavourite];
        !_isFromFavourite ?[requestDict setValue:self.mapSelectedCatagory forKey:pCatagoryName]:[requestDict setValue:@"All" forKey:pCatagoryName];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/category_list" WithComptionBlock:^(id result, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
            
            if (_dataArray) {
                [_dataArray removeAllObjects];
            }else
                _dataArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *rowData in categoryList) {
                [_dataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
            }
            for (RowDataModal *objModal in _dataArray) {
                objModal.isProviderSelected = NO;
            }
            if (_dataArray.count) {
                RowDataModal *objModal = [_dataArray objectAtIndex: _index.integerValue ?_index.integerValue:0];
                objModal.isProviderSelected = YES;
                _userDescriptionView.hidden = NO;
                
                [self initialSetup];
            }else
            {
                _userDescriptionView.hidden = YES;
                [self initialSetup];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}

#pragma mark - Helper Class

-(void)initialSetup  {
    
    _navTitle.text = KNSLOCALIZEDSTRING(@"Map");
    //Layout of search field
//    [_searchTextField setPlaceholder:KNSLOCALIZEDSTRING(@"Search Service Providers")];
//    [_searchTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [_searchTextField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.userImage.layer.cornerRadius = 35;
    self.userImage.clipsToBounds=YES;
    
    
    //Add pading in the search field
    addPading(self.searchTextField);
    
    self.mapView.delegate = self;
    
    [self.viewStar setIsOnReview:YES];
     self.viewStar.userInteractionEnabled = NO;
//    [self.viewStar setStars:5];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }


    
    [self showAllLocationDetail];
    [self displayDataSourceOverViewContainerAtIndex: _index.integerValue ?_index.integerValue:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAllLocationDetail)
                                                 name:@"updateMap"
                                               object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)displayDataSourceOverViewContainerAtIndex:(NSInteger)index
{
    if([self.dataArray count]) {
    object = [self.dataArray objectAtIndex:index];
  
        // current location
        CLLocationDegrees latitude = [object.userLatitute doubleValue];
        CLLocationDegrees longitude = [object.userLongitute doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
        [self getUserUpdateLocation:coordinate];
        
        
    self.userName.text = object.userName;
    //self.userAddress.text = object.userAddress;
    self.reviewLabel.text = object.reviewDetail;
    [self.userImage sd_setImageWithURL:object.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
        
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.reviewLabel setTextAlignment:NSTextAlignmentLeft];
        }
        else
        {
            _starRatingXConstraint.constant = 8;
        }
        
    [self.descriptionImageView setImage:[UIImage imageNamed:object.userCatagoryImage]];
    self.descriptionImageView.image = [self.descriptionImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [ self.descriptionImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];
    self.distanceLabel.text = object.userDistance;
    self.workedLabel.text = object.userNumberFollowed;
    [self.ratingView setStars:(int)object.ratingNumber];
    self.descriptionLabel.text = object.userCatagory;
        // localise
        self.descriptionLabel.text = KNSLOCALIZEDSTRING(object.userCatagory);

    }
    [self showAllLocationDetail];
    
}


#pragma mark - Show all the BootCamp Location Markers

-(void)showAllLocationDetail {

        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake([[APPDELEGATE latitude] floatValue], [[APPDELEGATE longitude] floatValue]) zoom:5];
    
          if (!markerIsTapped) {
             // zoom the map into the users current location
              [self.mapView animateWithCameraUpdate:updatedCamera];
              markerIsTapped = YES;
            }
    
         GMSMarker *currentLocMarker = [[GMSMarker alloc] init];
        [self.mapView clear];
         currentLocMarker.position = CLLocationCoordinate2DMake([[APPDELEGATE latitude] floatValue],[[APPDELEGATE longitude]floatValue]);
         currentLocMarker.icon = [UIImage imageNamed:@"track_icon"];
         currentLocMarker.map = self.mapView;
        // Creates a marker in the center of the map.
       for (int i = 0 ; i < [_dataArray count] ; i++) {
           
          RowDataModal *objModal = [_dataArray objectAtIndex:i];
           if([objModal.userLatitute isEqual:@""]||[objModal.userLongitute isEqual:@""])    {
               
           } else     {
               
          GMSMarker *marker = [[GMSMarker alloc] init];
          marker.userData = [NSString stringWithFormat:@"%d",i];
          marker.position = CLLocationCoordinate2DMake([objModal.userLatitute floatValue], [objModal.userLongitute floatValue]);

        
               if (objModal.isProviderSelected) {
                   marker.icon = [UIImage imageNamed:@"location"]; // blue icon
               }else
               {
                   marker.icon = [UIImage imageNamed:@"location2"]; // orange icon
               }
               
          marker.map = self.mapView;
        }
    }

}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    markerIsTapped = YES;
    GMSMarker *selectedMarker = mapView.selectedMarker;
    selectedMarker.icon = [UIImage imageNamed:@"location2"];
    
    [self.mapView setSelectedMarker:marker];
//   marker.icon = [UIImage imageNamed:@"location"];
  
    _index = marker.userData;
    if (_index) {
        for (RowDataModal *objModal in _dataArray) {
            objModal.isProviderSelected = NO;
        }
        NSLog(@"index is %@",_index);
        RowDataModal *objModal = [_dataArray objectAtIndex:_index.integerValue];
        objModal.isProviderSelected = YES;
        
        [self displayDataSourceOverViewContainerAtIndex:_index.integerValue];
    }
    return YES;
}

#pragma mark - UItextfield Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    
    return YES;
}

- (IBAction)listAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterAction:(id)sender {
    FilterVC *filterObject = [[FilterVC alloc]initWithNibName:@"FilterVC" bundle:nil];
    [self.navigationController pushViewController:filterObject animated:YES];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)providerDetailBtnAction:(id)sender {
    if([self.dataArray count]) {
//        RowDataModal *objModal = [_dataArray objectAtIndex: _index.integerValue ?_index.integerValue:0];
        ProviderDetial *providerDetailObj = [[ProviderDetial alloc]initWithNibName:@"ProviderDetial" bundle:nil];
        providerDetailObj.isComingFromMenuServiceTracking = NO;
//        providerDetailObj.delegate = self;
        providerDetailObj.particularServiceProviderDetail = [_dataArray objectAtIndex: _index.integerValue ?_index.integerValue:0];
//        providerDetailObj.particularServiceProviderDetail.selectedServiceProviderIndex = indexPath.row;
        [self.navigationController pushViewController:providerDetailObj animated:YES];
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
