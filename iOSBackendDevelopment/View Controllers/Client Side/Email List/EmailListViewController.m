//
//  EmailListViewController.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "EmailListViewController.h"
#import "MessagesTableViewCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "EmailDataModal.h"
#import "ServiceTrackingVC.h"
#import "MacroFile.h"
#import "ADCircularMenu.h"
#import "EmailViewVC.h"
#import "AppUtilityFile.h"
#import "MessagesVC.h"
#import "NSString+Validate.h"


static NSString *identifier = @"MessagesTableViewCell";

@interface EmailListViewController ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate>
{
    NSMutableArray *arrayEmailRowData;
    ADCircularMenu *circularMenuVC;
    NSInteger deletedCell;
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *emailListTableView;

@property (weak, nonatomic) IBOutlet UILabel *lblNavigationTitle;

@property (weak, nonatomic) IBOutlet UIButton *socialButton;
@property (weak, nonatomic) IBOutlet UIButton *menuBtnProperty;
@property (weak, nonatomic) NSString *strConversationID;
@property (nonatomic) NSTimer* updateData;

@end

@implementation EmailListViewController

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialSetup];
}
-(void)viewWillAppear:(BOOL)animated{
    //Initalise For Pagination

    
    //Get Email List
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    [self requestDictForAllEmail:pagination];
    self.updateData = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(callApiToUpdateList)
                                                     userInfo:nil
                                                      repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.updateData invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    _lblNavigationTitle.text = KNSLOCALIZEDSTRING(@"Email");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.socialButton setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
    }
    
    //Array alloc and init
    arrayEmailRowData = [[NSMutableArray alloc]init];
    
    //Register Table View Cell
    [self.emailListTableView registerNib:[UINib nibWithNibName:@"MessagesTableViewCell" bundle:nil] forCellReuseIdentifier:@"MessagesTableViewCell"];
    
    if (THREEOPTIONSCOMINGFROM == 1) {
        self.menuBtnProperty.tag = 5555;
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
        self.menuBtnProperty.tag = 6666;
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        }
        else {
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        }
    }
    
    
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];
//    //Initalise For Pagination
//    pagination = [[CCPagination alloc] init];
//    pagination.pageNo = 0;
//    
//    [self addPullToRefresh];
//    
//    //Get Email List
//    [self requestDictForAllEmail:pagination];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.emailListTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self requestDictForAllEmail:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayEmailRowData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[self.emailListTableView dequeueReusableCellWithIdentifier:identifier];
    EmailDataModal *emailList = [arrayEmailRowData objectAtIndex:indexPath.row];
    
    [cell.userlabel setText:emailList.userName];
    
    
    cell.userMessageLabel.attributedText = [NSString customAttributeString:emailList.emailMessage withAlignment:NSTextAlignmentLeft withLineSpacing:5 withFont:[UIFont fontWithName:@"Candara" size:16.0]];
//  [cell.userMessageLabel setText:emailList.emailMessage];
    [cell.dateLabel setText:emailList.serviceDate];
    [cell.userImageView sd_setImageWithURL:emailList.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EmailViewVC *mailObj = [[EmailViewVC alloc]initWithNibName:@"EmailViewVC" bundle:nil];
    mailObj.emailListObj = [arrayEmailRowData objectAtIndex:indexPath.row];
    mailObj.delegate = self;
    [self.navigationController pushViewController:mailObj animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    EmailDataModal *emailList = [arrayEmailRowData objectAtIndex:indexPath.row];
    
//    
//    if ([emailList.senderID isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]])
//    {
//        
//        UITableViewRowAction *Delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//                                        {
//                                            deletedCell = indexPath.row;
//                                            [self requestDictForDeleteEmail];
//                                        }];
//        return @[Delete];
//    }
//    else{
    
        if ([emailList.blockStatus isEqualToString:@"0"]) {
            UITableViewRowAction *Delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                            {
                                                deletedCell = indexPath.row;
                                                [self requestDictForDeleteEmail];
                                            }];
            
            UITableViewRowAction *Block = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                           {
                                               if ([emailList.senderID isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]])
                                               {
                                                   [self requestDictForUnBlock:emailList];
                                               }
                                               else if([emailList.receiverID isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]])
                                               {
                                                   [self requestDictForUnBlock:emailList];
                                               }
                                               else{
                                                   [self requestDictForUnBlock:emailList];
                                               }
                                               
                                           }];
            Block.backgroundColor = [UIColor colorWithRed:0 green:188/255.0f blue:170/255.0f alpha:1.0f];
            return @[Block,Delete];
        }
        else{
            
            
            UITableViewRowAction *Delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                            {
                                                deletedCell = indexPath.row;
                                                [self requestDictForDeleteEmail];
                                            }];
            return @[Delete];
        }
//    }
}

#pragma mark - UIButton's Action

- (IBAction)menuButton:(UIButton *)sender {
//    UIButton *btn = (UIButton *)sender;
    [self.view endEditing:YES];

//    if ([[btn currentImage] isEqual:[UIImage imageNamed:@"back_icon"]] || [[btn currentImage] isEqual:[UIImage imageNamed:@"back_rotate"]]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [self.sidePanelController showLeftPanelAnimated:YES];
//    }
    if (sender.tag == 5555) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.sidePanelController showLeftPanelAnimated:YES];
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
            
            // modifications
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
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
            }else {
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
-(void)callApiToUpdateList{
    pagination.pageNo = 0;
    [self requestDictForAllEmail:pagination];
}
-(void)requestDictForAllEmail:(CCPagination *)page {
    
    isLoadMoreExecuting = NO;
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:@"10" forKey:pPageSize];
    [requestDict setObject:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/get_message" WithComptionBlock:^(id result, NSError *error) {
        
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            if ([pagination.pageNo integerValue] == 0) {
                [arrayEmailRowData removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emailListTableView.bounds.size.width,  self.emailListTableView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.emailListTableView.backgroundView = noDataLabel;
                
                [self.emailListTableView reloadData];
                
            }else {
                isLoadMoreExecuting = YES;
                self.emailListTableView.backgroundView = nil;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSMutableArray *emailArray = [result objectForKeyNotNull:pEmailList expectedObj:[NSArray array]];
                
                for (NSDictionary *dict in emailArray) {
                    [arrayEmailRowData addObject:[EmailDataModal parseEmailList:dict]];
                }
                [self.emailListTableView reloadData];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
    }];
    
}

-(void)requestDictForDeleteEmail {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    EmailDataModal *emailList = [arrayEmailRowData objectAtIndex:deletedCell];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:emailList.conversationID forKey:pConversation];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/delete_conversation" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            [arrayEmailRowData removeObjectAtIndex:deletedCell];
            if ([arrayEmailRowData count] == 0) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emailListTableView.bounds.size.width,  self.emailListTableView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found.");
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.emailListTableView.backgroundView = noDataLabel;
            }else{
                self.emailListTableView.backgroundView = nil;
            }
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Email deleted successfully.") onController:self];
            [_emailListTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
        
    }];
    
    
}

-(void)requestDictForUnBlock:(EmailDataModal *)objModel {
    
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mma"];
    NSString *dateStr = [dateFormat stringFromDate:now];
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        [requestDict setObject:objModel.receiverID forKey:@"block_id"];
    }else{
        [requestDict setObject:objModel.senderID forKey:@"block_id"];
    }
//    [requestDict setObject:objModel.receiverID forKey:@"block_id"];
    [requestDict setObject:dateStr forKey:@"time"];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"message/user_block_unblock" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            [self requestDictForBlock:objModel];
            [arrayEmailRowData removeObject:objModel];
            [self.emailListTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
    }];
}

-(void)requestDictForBlock:(EmailDataModal *)objModel {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        [requestDict setObject:objModel.receiverID forKey:@"block_id"];
    }else{
        [requestDict setObject:objModel.senderID forKey:@"block_id"];
    }
    [requestDict setObject:objModel.userName forKey:@"block_name"];
    
    [[OPServiceHelper sharedServiceHelper]PostAPICallWithParameter:requestDict apiName:@"blockuser" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            
            NSMutableDictionary *dic = [result objectForKeyNotNull:@"data" expectedObj:[NSDictionary dictionary]];
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:[dic objectForKeyNotNull:@"msg" expectedObj:@""] onController:self.navigationController];
            [self refereshTable];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:[result objectForKeyNotNull:pResponseMsg expectedObj:@""] onController:self.navigationController];
        }
    }];
}

-(void)previousObject:(EmailDataModal *)oldEmailListObj andModifyObject:(EmailDataModal *)newEmailListObj andIsArrayEmpty:(BOOL)isArrayEmpty {
    if (isArrayEmpty) {
        [arrayEmailRowData removeObject:oldEmailListObj];
    }else {
        NSInteger selectedObject = [arrayEmailRowData indexOfObject:oldEmailListObj];
        [arrayEmailRowData replaceObjectAtIndex:selectedObject withObject:newEmailListObj];
        // added
        EmailDataModal * dataModel = [arrayEmailRowData objectAtIndex:selectedObject];
        dataModel.userProfileImageURL = oldEmailListObj.userProfileImageURL;
        dataModel.userName = oldEmailListObj.userName;

    }
    
    if ([arrayEmailRowData count] == 0) {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emailListTableView.bounds.size.width,  self.emailListTableView.bounds.size.height)];
        noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found.");
        noDataLabel.textColor        = [UIColor whiteColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.emailListTableView.backgroundView = noDataLabel;
    }else {
        self.emailListTableView.backgroundView = nil;
    }
    
    [self.emailListTableView reloadData];
}

@end
