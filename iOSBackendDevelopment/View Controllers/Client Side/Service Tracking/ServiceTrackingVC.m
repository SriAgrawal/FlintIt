//
//  ServiceTrackingVC.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "ServiceTrackingVC.h"
#import "ServiceTrackingTableViewCell.h"
#import "HeaderFile.h"

static NSString *CellIdentifier = @"ServiceTrackingTableViewCell";

@interface ServiceTrackingVC ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate,DelegateAfterRequestCancel>
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

@implementation ServiceTrackingVC

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self requestDictForServiceProviderList:pagination];

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
    [self.serviceTrackingTableView registerNib:[UINib nibWithNibName:@"ServiceTrackingTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    //Alloc Modal and Array
    serviceDataArray = [NSMutableArray array];
    
    if (THREEOPTIONSCOMINGFROM == 1) {
//        self.menuBtnProperty.tag = 7896;
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
//        self.menuBtnProperty.tag = 1234;
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        }
        else {
        [self.menuBtnProperty setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        }
    }
//    //Initalise For Pagination
//    pagination = [[CCPagination alloc] init];
//    pagination.pageNo = 0;
//    
//    [self requestDictForServiceProviderList:pagination];

    [self addPullToRefresh];
    
    if([_screenType isEqualToString:@"ProviderDetial"]){
        [self.menuBtnProperty setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    }
    
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
    
    ServiceTrackingTableViewCell *cell = (ServiceTrackingTableViewCell *)[self.serviceTrackingTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    ServiceTrackingModal *serviceObj = [serviceDataArray objectAtIndex:indexPath.row];
    
       RowDataModal *serviceObj = [serviceDataArray objectAtIndex:indexPath.row];
    
      [cell.serviceNameLabel setText:serviceObj.serviceName];
      [cell.serviceProviderLabel setText:serviceObj.serviceProviderName];
      [cell.distanceLabel setText:serviceObj.serviceDistanceDetail];
//      [cell.timeDateLabel setText:[NSString stringWithFormat:@"%@/%@",serviceObj.serviceDate,serviceObj.serviceTime]];
      [cell.serviceTypeImageView setImage:[UIImage imageNamed:serviceObj.userCatagoryImage]];
      [cell.timeLeftLabel setText:[NSString stringWithFormat:@"%@",serviceObj.serviceTimeLeft]];
      cell.serviceTypeImageView.image = [cell.serviceTypeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [cell.timeDateLabel setText:[NSString stringWithFormat:@"%@",serviceObj.serviceStartTime]];

      [cell.serviceTrackingImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];
    
     // added
    
     [cell.serviceTrackingImageView sd_setImageWithURL:[NSURL URLWithString:serviceObj.userImage] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    
      return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
//    providerObj.delegate = self;
//    providerObj.particularDetail = [serviceDataArray objectAtIndex:indexPath.row];
//    providerObj.particularDetail.selectedIndex = indexPath.row;
//    [self.navigationController pushViewController:providerObj animated:YES];
    
    if ([self.screenType isEqualToString:@"ProviderDetial"]) {
        ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
        providerObj.delegate = self;
        providerObj.particularDetail = [serviceDataArray objectAtIndex:indexPath.row];
        providerObj.particularDetail.selectedIndex = indexPath.row;
        providerObj.userDetail = [serviceDataArray objectAtIndex:indexPath.row];
        providerObj.userDetail.selectedIndex = indexPath.row;

        [self.navigationController pushViewController:providerObj animated:YES];
        
    }else {
//        ProviderDetial *providerDetailObj = [[ProviderDetial alloc]initWithNibName:@"ProviderDetial" bundle:nil];
//        providerDetailObj.delegate = self;
//        providerDetailObj.isComingFromMenuServiceTracking = YES;
//
//        providerDetailObj.particularServiceProviderDetail = [serviceDataArray objectAtIndex:indexPath.row];
//        providerDetailObj.particularServiceProviderDetail.selectedServiceProviderIndex = indexPath.row;
//        [self.navigationController pushViewController:providerDetailObj animated:YES];
        ProviderLocationViewController *providerObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
        providerObj.delegate = self;
        providerObj.particularDetail = [serviceDataArray objectAtIndex:indexPath.row];
        providerObj.userDetail = [serviceDataArray objectAtIndex:indexPath.row];

        [self.navigationController pushViewController:providerObj animated:YES];
    }
}

#pragma mark - UIButton Actions

- (IBAction)menuButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
//    UIButton *btn = (UIButton *)sender;
    if (!_isFromMenu) {
        NSLog(@"view controller s--------%@",self.navigationController.viewControllers);
        BOOL isPop = false;
        NSArray *viewControllers = [[self navigationController] viewControllers];
        for( int i=0;i<[viewControllers count];i++){
            id obj=[viewControllers objectAtIndex:i];
            if([obj isKindOfClass:[CategoryNameVC class]]){
                [[self navigationController] popToViewController:obj animated:YES];
                isPop = YES;
                return;
            }
        }
        if (!isPop) {
            for (UIViewController * controller in viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
//                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
//        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self.sidePanelController showLeftPanelAnimated:YES];
    }
//    if ([[btn currentImage] isEqual:[UIImage imageNamed:@"back_icon"]] || [[btn currentImage] isEqual:[UIImage imageNamed:@"back_rotate"]]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else
//    {
//          [self.sidePanelController showLeftPanelAnimated:YES];
//    }
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
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/service_tracking_list_client" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
        
        if ([pagination.pageNo integerValue] == 0) {
            [serviceDataArray removeAllObjects];
        }
        
        if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
            UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.serviceTrackingTableView.bounds.size.width,  self.serviceTrackingTableView.bounds.size.height)];
            noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
            noDataLabel.textColor        = [UIColor whiteColor];
            noDataLabel.textAlignment    = NSTextAlignmentCenter;
            self.serviceTrackingTableView.backgroundView = noDataLabel;
            
            [self.serviceTrackingTableView reloadData];
        }else {
            isLoadMoreExecuting = YES;
            self.serviceTrackingTableView.backgroundView = nil;
            
            pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
            
            NSArray *serviceProviderList = [result objectForKeyNotNull:pServiceTrackingList expectedObj:[NSArray array]];
            
            for (NSDictionary *rowData in serviceProviderList) {
                [serviceDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:YES]];
                [self.serviceTrackingTableView reloadData];
            }
        }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }

    }];
    

   }

-(void)changeInTheServiceProviderDetail:(RowDataModal *)serviceProviderDetail {
    NSInteger selectedIndex = serviceProviderDetail.selectedServiceProviderIndex;
    [serviceDataArray replaceObjectAtIndex:selectedIndex withObject:serviceProviderDetail];
}

//handle delegate
-(void)delegateAfterComingFromRequest:(RowDataModal *)rowDataModalObj{
    
}
@end
