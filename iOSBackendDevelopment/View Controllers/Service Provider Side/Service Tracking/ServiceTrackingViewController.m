//
//  ServiceTrackingViewController.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 06/06/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ServiceTrackingViewController.h"
#import "HeaderFile.h"
#import "ServiceTableViewCell.h"


static NSString *CellIdentifier = @"ServiceTableViewCell";


@interface ServiceTrackingViewController ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate,DelegateAfterRequestCancel>
{
    ADCircularMenu *circularMenuVC;
    NSMutableArray *serviceDataArray;
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    
    UIRefreshControl *refreshControl;
}
@property (weak, nonatomic) IBOutlet UILabel *lblServiceTracking;

@property (strong, nonatomic) IBOutlet UITableView *serviceTrackingTableView;

@property (weak, nonatomic) IBOutlet UIButton *menuBtnProperty;
@property (weak, nonatomic) IBOutlet UIButton *globalBtnProperty;


@end

@implementation ServiceTrackingViewController

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

#pragma mark - Helper Method

-(void)initialSetup {

    _lblServiceTracking.text = KNSLOCALIZEDSTRING(@"Service Tracking");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.globalBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
    }
    
    //Register Cell
    [self.serviceTrackingTableView registerNib:[UINib nibWithNibName:@"ServiceTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    //Alloc Modal and Array
    serviceDataArray = [NSMutableArray array];
    
    if (THREEOPTIONSCOMINGFROM == 1) {
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        }
        else {
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        }
    }else {
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        }
        else {
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        }
    }
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    
    [self addPullToRefresh];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    pagination.pageNo = 0;
    [self requestDictForServiceProviderList:pagination];

}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.serviceTrackingTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self requestDictForServiceProviderList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [serviceDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ServiceTableViewCell *cell = (ServiceTableViewCell *)[self.serviceTrackingTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ServiceTrackingModal *serviceObj = [serviceDataArray objectAtIndex:indexPath.row];
    cell.serviceTypeImageView.hidden = YES;
    [cell.serviceName setText:serviceObj.serviceName];
    [cell.serviceProviderNameLabel setText:serviceObj.clientName];
    [cell.distanceLabel setText:serviceObj.serviceDistanceDetail];
//    [cell.timeNdateLAbel setText:[NSString stringWithFormat:@"%@/%@",serviceObj.serviceDate,serviceObj.serviceTime]];
    [cell.timeNdateLAbel setText:[NSString stringWithFormat:@"%@",serviceObj.serviceStartTime]];
    [cell.contactNumberLabel setText:[NSString stringWithFormat:@"%@",serviceObj.serviceContactNumber]];
    [cell.clientImageView sd_setImageWithURL:[NSURL URLWithString:serviceObj.profileImage] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
    providerObj.delegate = self;
    providerObj.particularDetail = [serviceDataArray objectAtIndex:indexPath.row];
    providerObj.particularDetail.selectedIndex = indexPath.row;
    
    providerObj.userDetail = [serviceDataArray objectAtIndex:indexPath.row];
    providerObj.userDetail.selectedIndex = indexPath.row;

    providerObj.providerJobStatus = [[serviceDataArray objectAtIndex:indexPath.row] valueForKey:@"jobLatestStatus"];
    [self.navigationController pushViewController:providerObj animated:YES];
}

- (IBAction)menuButtonAction:(id)sender {
    [self.view endEditing:YES];
    if (!self.isFromSidePanel) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.sidePanelController showLeftPanelAnimated:YES];
    }
}


- (IBAction)socialButtonAction:(id)sender {
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
            
//            for (UIViewController *controller in self.navigationController.viewControllers) {
//                if ([controller isKindOfClass:[JASidePanelController class]]) {
//                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
//                    if ([[sidePanelObj centerPanel] isKindOfClass:[ServiceTrackingVC class]]) {
//                        isNotFound = NO;
//                        
//                        if (![self isKindOfClass:[ServiceTrackingVC class]])
//                            [self.navigationController popToViewController:controller animated:YES];
//                        break;
//                    }
//                }else if ([controller isKindOfClass:[ServiceTrackingVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
//                    isNotFound = NO;
//                    
//                    if (![self isKindOfClass:[ServiceTrackingVC class]])
//                        [self.navigationController popToViewController:controller animated:YES];
//                    break;
//                }
//            }
//            
//            if (isNotFound) {
//                ServiceTrackingVC *serviceTrackingObject = [[ServiceTrackingVC alloc]initWithNibName:@"ServiceTrackingVC" bundle:nil];
//                THREEOPTIONSCOMINGFROM = Social;
//                [self.navigationController pushViewController:serviceTrackingObject animated:YES];
//            }
//
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[ServiceTrackingViewController class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[ServiceTrackingViewController class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[ServiceTrackingViewController class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[ServiceTrackingViewController class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            if (isNotFound) {
                ServiceTrackingViewController *serviceTrackingObject = [[ServiceTrackingViewController alloc]initWithNibName:@"ServiceTrackingViewController" bundle:nil];
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
            
            [self requestDictForServiceProviderList:pagination];
        }
    }
}

#pragma mark - Service Implementation Methods

-(void)requestDictForServiceProviderList:(CCPagination *)page {
    isLoadMoreExecuting = NO;
  
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/service_tracking_list_service" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            if ([pagination.pageNo integerValue] == 0) {
                [serviceDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.serviceTrackingTableView.bounds.size.width,  self.serviceTrackingTableView.bounds.size.height)];
                noDataLabel.text = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.serviceTrackingTableView.backgroundView = noDataLabel;
                [self.serviceTrackingTableView reloadData];
                
            }
            else if([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"Success.")]) {
                
                isLoadMoreExecuting = YES;
                self.serviceTrackingTableView.backgroundView = nil;
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSArray *serviceProviderList = [result objectForKeyNotNull:pServiceTrackingList expectedObj:[NSArray array]];
                
                for (NSDictionary *rowData in serviceProviderList) {
                    [serviceDataArray addObject:[ServiceTrackingModal parseServiceListService:rowData]];
                }
                [self.serviceTrackingTableView reloadData];
            }

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
}


-(void)delegateAfterComingFromRequest:(ServiceTrackingModal *)selectedServiceTracking {
    
    [serviceDataArray removeObject:selectedServiceTracking];
    
    if ([serviceDataArray count] == 0) {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.serviceTrackingTableView.bounds.size.width,  self.serviceTrackingTableView.bounds.size.height)];
        noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found.");
        noDataLabel.textColor        = [UIColor whiteColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.serviceTrackingTableView.backgroundView = noDataLabel;
        
    }else {
        self.serviceTrackingTableView.backgroundView = nil;
    }
    
    [self.serviceTrackingTableView reloadData];
}

@end
