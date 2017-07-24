//
//  EmailViewVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 15/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "EmailViewVC.h"
#import "EmailVC.h"
#import "ClientMailRow.h"
#import "ServiceProviderEmailRow.h"
#import "EmailListViewController.h"
#import "ADCircularMenu.h"
#import "UIViewController+JASidePanel.h"
#import "ServiceTrackingVC.h"
#import "MacroFile.h"
#import "AppUtilityFile.h"
#import "MessagesVC.h"
#import "HeaderFile.h"

NSString *CellIdentifierForClientRow            = @"ClientMailRow";
NSString *CellIdentifierForServiceProviderRow   = @"ServiceProviderEmailRow";

@interface EmailViewVC ()<UITableViewDelegate,UITableViewDataSource,ADCircularMenuDelegate>
{
    ADCircularMenu *circularMenuVC;
    NSMutableArray *arrayEmailRowData;
    
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblEmailFrom;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceProviderName;

@property (weak, nonatomic) IBOutlet UIButton *replyBtnProperty;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation EmailViewVC

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
    
    _navTitle.text = KNSLOCALIZEDSTRING(@"Email View");
    _lblEmailFrom.text = KNSLOCALIZEDSTRING(@"Email From :");
    [self.replyBtnProperty setTitle:KNSLOCALIZEDSTRING(@"Reply") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    // Nsmutable Array
    arrayEmailRowData = [NSMutableArray array];
    
    [self.lblServiceProviderName setText:self.emailListObj.userName];
    
    [self.replyBtnProperty.layer setCornerRadius:25.0];
    
    //Register the tableView Cell
    [self.tblView registerNib:[UINib nibWithNibName:@"ClientMailRow" bundle:nil] forCellReuseIdentifier:CellIdentifierForClientRow];
    [self.tblView registerNib:[UINib nibWithNibName:@"ServiceProviderEmailRow" bundle:nil] forCellReuseIdentifier:CellIdentifierForServiceProviderRow];
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];
    
    //Fetch all Email List
    [self requestDictForAllEmail:pagination];
    
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 100;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.tblView addSubview:refreshControl];
}

-(void)refereshTable {
    pagination.pageNo = 0;
    [self requestDictForAllEmail:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - TableView DataSource and Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayEmailRowData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientMailRow *clientCell = (ClientMailRow *)[self.tblView dequeueReusableCellWithIdentifier:CellIdentifierForClientRow];
    
    ServiceProviderEmailRow *serviceCell = (ServiceProviderEmailRow *)[self.tblView dequeueReusableCellWithIdentifier:CellIdentifierForServiceProviderRow];
    
    EmailDataModal *emailList = [arrayEmailRowData objectAtIndex:indexPath.row];
    if([emailList.senderID isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
        serviceCell.lblText.text = emailList.emailMessage;
        [serviceCell.serviceProviderImageView sd_setImageWithURL:emailList.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
        return serviceCell;
    }
    else {
        clientCell.lblText.text = emailList.emailMessage;

        [clientCell.imgViewClient sd_setImageWithURL:emailList.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
        
        return clientCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    EmailDataModal *emailList = [arrayEmailRowData objectAtIndex:indexPath.row];
//    
//    CGRect rowHeight = [self getEstimatedHeightWithFont:[UIFont systemFontOfSize:17] withWidth:SCREEN_WIDTH-94 withExtraHeight:30 text:emailList.emailMessage];
//    return   MAX(rowHeight.size.height, 100) ;
    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        EmailDataModal *emailModal = [arrayEmailRowData objectAtIndex:indexPath.row];

        [self requestDeleteParticularEmail:emailModal];
    }
}


#pragma mark  - Calculation of Label Height

- (CGRect)getEstimatedHeightWithFont:(UIFont*)font withWidth:(CGFloat)width withExtraHeight:(CGFloat)ht text:(NSString *)text{
    
    if (!text || !text.length)
        return CGRectZero;
    
    
    CGRect rect = [text boundingRectWithSize : (CGSize){width, CGFLOAT_MAX}
                                     options : NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes : @{ NSFontAttributeName: font }
                                     context : nil];
    
    return rect;
}


#pragma mark - UIButton Actions

- (IBAction)replyBtnAction:(id)sender {
    
    if ([_emailListObj.blockStatus boolValue] == 1) {
         [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
    }else{
        EmailVC *emailObj = [[EmailVC alloc]initWithNibName:@"EmailVC" bundle:nil];
        emailObj.particularDetail = self.emailListObj;
        emailObj.delegate = self;
        [self.navigationController pushViewController:emailObj animated:YES];
    }

}

- (IBAction)backBtnAction:(id)sender {
    EmailDataModal *emailListLastObject = [arrayEmailRowData lastObject];
    
    if(arrayEmailRowData.count == 0) {
        [self.delegate previousObject:self.emailListObj andModifyObject:emailListLastObject andIsArrayEmpty:YES];
    }else {
        [self.delegate previousObject:self.emailListObj andModifyObject:emailListLastObject andIsArrayEmpty:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
            
            [self requestDictForAllEmail:pagination];
        }
    }
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForAllEmail:(CCPagination *)page {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:self.emailListObj.conversationID forKey:pConversation];
    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper]PostAPICallWithParameter:requestDict apiName:@"Message/get_email_message_of_particular_conversation" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            if ([pagination.pageNo integerValue] == 0) {
                [arrayEmailRowData removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width,  self.tblView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.tblView.backgroundView = noDataLabel;
                
                [self. tblView reloadData];
                
            }else {
                isLoadMoreExecuting = YES;
                self.tblView.backgroundView = nil;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSMutableArray *emailArray = [result objectForKeyNotNull:pEmailList expectedObj:[NSArray array]];
                for (NSDictionary *dict in emailArray) {
                    [arrayEmailRowData addObject:[EmailDataModal parseEmailList:dict]];
                }
                [self. tblView reloadData];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
        
    }];
   
}

-(void)requestDeleteParticularEmail:(EmailDataModal*)emailModal {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setValue:emailModal.conversationID forKey:pConversation];
    [requestDict setValue:emailModal.emailID forKey:pId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/delete_email" WithComptionBlock:^(id result, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [arrayEmailRowData removeObject:emailModal];
            
            if(arrayEmailRowData.count == 0) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width,  self.tblView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found.");
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.tblView.backgroundView = noDataLabel;
            }else {
                self.tblView.backgroundView = nil;
            }
            [_tblView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
}

-(void)updateEmailList:(EmailDataModal *) emailListObj {
    if ([emailListObj.emailID length]) {
        [arrayEmailRowData insertObject:emailListObj atIndex:0];
        self.emailListObj.conversationID = emailListObj.conversationID;
//        [arrayEmailRowData addObject:emailListObj];
        self.tblView.backgroundView = nil;
        [self.tblView reloadData];
    }
}

@end
