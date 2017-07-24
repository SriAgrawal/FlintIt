//
//  NotificationViewController.m
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MacroFile.h"
#import "EmailVC.h"
#import "GiveReviewVC.h"
#import "GiveAReviewServiceSideVC.h"
#import "HeaderFile.h"

static NSString *identifier = @"NotificationTableViewCell";

@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *dataArray;
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    
    UIRefreshControl *refreshControl;
    NotificationRelatedData *modalObject;
}

@property (strong, nonatomic) IBOutlet UITableView *notificationTableView;

@property (weak, nonatomic) IBOutlet UILabel *lblMyNotification;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@end

@implementation NotificationViewController

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self initialSetup];
}
-(void)viewWillAppear:(BOOL)animated{
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup
{
    _lblMyNotification.text = KNSLOCALIZEDSTRING(@"My Notifications");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    }

    //Alloc and Initailise the array
    dataArray = [[NSMutableArray alloc]init];
    
    //Register the tableView Cell
    [self.notificationTableView registerNib:[UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil] forCellReuseIdentifier:@"NotificationTableViewCell"];
    
    if (_isFromSelectYourChoice) {
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [_btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
            [_btnMenu setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        }else{
            [_btnMenu setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
   
        }
    }

    //Bounce table vertical if required
    [self.notificationTableView setAlwaysBounceVertical:NO];
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];
    
    modalObject = [[NotificationRelatedData alloc]init];

    //Get Notification List
    [self requestDictForAllNotification:pagination];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.notificationTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self requestDictForAllNotification:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[self.notificationTableView dequeueReusableCellWithIdentifier:identifier];
   
    NotificationRelatedData *notificationList = [dataArray objectAtIndex:indexPath.row];
    
    [cell.notificationLabel setText:notificationList.notificationText];
    [cell.timeLabel setText:[self convertTimeStampToNsDate:notificationList.createdAt]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    modalObject = [dataArray objectAtIndex:indexPath.row];
    
    if([modalObject.userType isEqualToString:@"provider"]) {
        ProviderDetial *providerObj = [[ProviderDetial alloc]initWithNibName:@"ProviderDetial" bundle:nil];
        providerObj.isFromNotificationScreen = YES;
        providerObj.userId = modalObject.senderID;
        providerObj.jobId = modalObject.jobID;
        providerObj.block_status = modalObject.block_status;
        [self.navigationController pushViewController:providerObj animated:YES];
    }else if([modalObject.type isEqualToString:@"request"] && [modalObject.userType isEqualToString:@"client"]){
        ClientDetailViewController *clientObj = [[ClientDetailViewController alloc]initWithNibName:@"ClientDetailViewController" bundle:nil];
        clientObj.isFromNotificationScreen = YES;
        clientObj.userId = modalObject.senderID;
        clientObj.jobId = modalObject.jobID;
        clientObj.block_status = modalObject.block_status;

        [self.navigationController pushViewController:clientObj animated:YES];
    }else if([modalObject.type isEqualToString:@"accepted"] && [modalObject.userType isEqualToString:@"client"]){
        ClientDetailViewController *clientObj = [[ClientDetailViewController alloc]initWithNibName:@"ClientDetailViewController" bundle:nil];
        clientObj.isFromNotificationScreen = YES;
        clientObj.isHideAcceptCancelButton = YES;
        clientObj.userId = modalObject.senderID;
        clientObj.jobId = modalObject.jobID;
        
        clientObj.block_status = modalObject.block_status;

        [self.navigationController pushViewController:clientObj animated:YES];
    }else if([modalObject.type isEqualToString:@"completed"] && [modalObject.userType isEqualToString:@"client"]){
        // No Navigation in case of job completed
//        ProviderLocationViewController *clientObj = [[ProviderLocationViewController alloc]initWithNibName:@"ProviderLocationViewController" bundle:nil];
//        clientObj.isFromNotificationScreen = YES;
//        clientObj.isHideCancelButton = YES;
//        clientObj.userId = modalObject.senderID;
//        clientObj.jobId = modalObject.jobID;
//        
//        clientObj.block_status = modalObject.block_status;
//
//        [self.navigationController pushViewController:clientObj animated:YES];
    }else if([modalObject.type isEqualToString:@"canceled"] && [modalObject.userType isEqualToString:@"client"]){
        ClientDetailViewController *clientObj = [[ClientDetailViewController alloc]initWithNibName:@"ClientDetailViewController" bundle:nil];
        clientObj.isFromNotificationScreen = YES;
        clientObj.isHideAcceptCancelButton = YES;
        clientObj.userId = modalObject.senderID;
        clientObj.jobId = modalObject.jobID;
        
        clientObj.block_status = modalObject.block_status;

        [self.navigationController pushViewController:clientObj animated:YES];
    }else if([modalObject.type isEqualToString:@"pending"] && [modalObject.userType isEqualToString:@"client"]){
        ClientDetailViewController *clientObj = [[ClientDetailViewController alloc]initWithNibName:@"ClientDetailViewController" bundle:nil];
        clientObj.isFromNotificationScreen = YES;
        clientObj.isHideAcceptCancelButton = NO;
        clientObj.userId = modalObject.senderID;
        clientObj.jobId = modalObject.jobID;
        
        clientObj.block_status = modalObject.block_status;

        [self.navigationController pushViewController:clientObj animated:YES];
    }
}

#pragma mark - UIButton Actions

- (IBAction)menuAction:(id)sender {
    [self.view endEditing:YES];
    if (_isFromSelectYourChoice) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.sidePanelController showLeftPanelAnimated:YES];
    }
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) {
        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
            [self requestDictForAllNotification:pagination];
        }
    }
}

-(NSString*)convertTimeStampToNsDate:(NSString *)timestamp{
    NSString * timeStampString =timestamp;
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSString *_date=[_formatter stringFromDate:date];
    return _date;
}
/*********************** Service Implementation Methods ****************/


-(void)requestDictForAllNotification:(CCPagination *)page {
    
    isLoadMoreExecuting = NO;
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:@"10" forKey:pPageSize];
    [requestDict setObject:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/all_notification" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
        
        if (!error) {
            
            if ([pagination.pageNo integerValue] == 0) {
                [dataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.notificationTableView.bounds.size.width,  self.notificationTableView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.notificationTableView.backgroundView = noDataLabel;
                
                [self.notificationTableView reloadData];
            }else {
                isLoadMoreExecuting = YES;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSMutableArray *notificationArray = [result objectForKeyNotNull:pNotificationDetail expectedObj:[NSArray array]];
                for (NSDictionary *dict in notificationArray) {
                    [dataArray addObject:[NotificationRelatedData parseNotificationList:dict]];
                }
                [self.notificationTableView reloadData];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}


@end
