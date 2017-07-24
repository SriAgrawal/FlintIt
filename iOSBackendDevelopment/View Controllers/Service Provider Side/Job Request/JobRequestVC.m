//
//  JobRequestVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "JobRequestVC.h"
#import "ADCircularMenu.h"
#import "UIViewController+JASidePanel.h"
#import "MessagesVC.h"
#import "ServiceTrackingVC.h"
#import "EmailListViewController.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"
#import "JobRequestCell.h"
#import "RowDataModal.h"
#import "ClientDetailViewController.h"
#import "HeaderFile.h"

static NSString *CellIdentifier = @"JobRequestCell";

@interface JobRequestVC ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate> {
    ADCircularMenu *circularMenuVC;
    NSMutableArray *requestDataArray;
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@end

@implementation JobRequestVC

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    _navTitle.text = KNSLOCALIZEDSTRING(@"Job Requests");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Register Cell
    [self.tblView registerNib:[UINib nibWithNibName:@"JobRequestCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    //Alloc Modal and Array
    requestDataArray = [NSMutableArray array];
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];
    
    [self requestDictForJobRequestList:pagination];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.tblView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self requestDictForJobRequestList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [requestDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JobRequestCell *cell = (JobRequestCell *)[self.tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    RowDataModal *requestObj = [requestDataArray objectAtIndex:indexPath.row];
    
    [cell.clientName setText:requestObj.userName];
    [cell.clientAge setText:requestObj.userAge];
    [cell.clientAddress setText:requestObj.userLocationName];
    [cell.jobName setText:requestObj.jobName];
//    [cell.timeNdateLAbel setText:[NSString stringWithFormat:@"%@/%@", requestObj.serviceDate, requestObj.serviceTime]];
    [cell.timeNdateLAbel setText:[NSString stringWithFormat:@"%@", requestObj.serviceStartTime]];

    [cell.clientImage sd_setImageWithURL:requestObj.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [cell.viewStar setStars:[requestObj.starRating intValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientDetailViewController *clientDetailObj = [[ClientDetailViewController alloc]initWithNibName:@"ClientDetailViewController" bundle:nil];
    clientDetailObj.delegate = self;
    clientDetailObj.particularClientDetail = [requestDataArray objectAtIndex:indexPath.row];
    clientDetailObj.particularClientDetail.selectedServiceProviderIndex = indexPath.row;
    [self.navigationController pushViewController:clientDetailObj animated:YES];
}


#pragma mark - UIButton Actions

- (IBAction)backAction:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)socialAction:(id)sender {
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

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) {
        
        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
            
            [self requestDictForJobRequestList:pagination];
        }
    }
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForJobRequestList:(CCPagination *)page {
    isLoadMoreExecuting = NO;
  
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/job_request_list" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            if ([pagination.pageNo integerValue] == 0) {
                [requestDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width,  self.tblView.bounds.size.height)];
                noDataLabel.text             =KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.tblView.backgroundView = noDataLabel;
                
                [self.tblView reloadData];
                
            }else {
                isLoadMoreExecuting = YES;
                self.tblView.backgroundView  = nil;
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSMutableArray *JobArrayList = [result objectForKeyNotNull:pJobRequest expectedObj:[NSArray array]];
                
                [self getUserUpdateLocation:JobArrayList];
                [self.tblView reloadData];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}


-(void)methodForListAfterAcceptAndDecline:(RowDataModal *)particularClientDetail {
    NSInteger indexRow = [requestDataArray indexOfObject:particularClientDetail];
    [requestDataArray removeObjectAtIndex:indexRow];
    
    if ([requestDataArray count] == 0) {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width,  self.tblView.bounds.size.height)];
        noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found. ");
        noDataLabel.textColor        = [UIColor whiteColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tblView.backgroundView = noDataLabel;
    }else {
        self.tblView.backgroundView  = nil;
    }
    
    [self.tblView reloadData];
}

#pragma mark - Reverse Gecoding to get address from (lat,long)

-(void)getUserUpdateLocation:(NSArray *)array {
    
    [MBProgressHUD showHUDAddedTo:[APPDELEGATE navController].view animated:YES];
    
    
    //    [MBProgressHUD showHUDAddedTo:[APPDELEGATE navController].view animated:YES];
    for (NSDictionary *rowData in array) {
        // Your location from latitude and longitude
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[rowData objectForKeyNotNull:@"latitude" expectedObj:@""] doubleValue] longitude:[[rowData objectForKeyNotNull:@"longitude" expectedObj:@""] doubleValue]];
        //  __block NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
        __block NSString *str = nil;
        // Call the method to find the address
        [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
            [MBProgressHUD hideHUDForView:[[APPDELEGATE navController] view] animated:YES];
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
            RowDataModal *obj = [RowDataModal parseJobRequestList:rowData];
            obj.userLocationName = str;
            [requestDataArray addObject:obj];
            [self.tblView reloadData];
            //        self.userAddressLbl.text = str;
            //  cell.tagLbl.text = str;
            
        } failureHandler:^(NSError *error) {
            NSLog(@"Error : %@", error);
        }
         ];
    }
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
