//
//  MessagesVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "MessagesVC.h"
#import "MessagesTableViewCell.h"
#import "ADCircularMenu.h"
#import "ServiceTrackingVC.h"
#import "EmailListViewController.h"
#import "UIViewController+JASidePanel.h"
#import "MacroFile.h"
#import "AppUtilityFile.h"
#import "ChatVC.h"
#import "RowDataModal.h"
#import "CustomChatVC.h"

static NSString *identifier = @"MessagesTableViewCell";

@interface MessagesVC ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate>
{
    NSMutableArray *arrayMessageRowData;
    ADCircularMenu *circularMenuVC;
}

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (weak, nonatomic) IBOutlet UIButton *globalBtnProperty;
@property (weak, nonatomic) IBOutlet UIButton *menuBtnProperty;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (nonatomic) NSTimer* updateData;
@end

@implementation MessagesVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
}

-(void)viewWillAppear:(BOOL)animated{
    //Call API to fetch user list.
    
    [super viewWillAppear:animated];
    
    [self requestToFetchUserChatList];
    self.updateData = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(requestToFetchUserChatList)
                                   userInfo:nil
                                    repeats:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestToFetchUserChatList) name:@"updateData" object:nil];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.updateData invalidate];
    // remove observer here
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateData" object:nil];
}

#pragma mark -Helper Method

-(void)initialSetup {
    
    _navTitle.text = KNSLOCALIZEDSTRING(@"Messages");
    arrayMessageRowData = [[NSMutableArray alloc] init];
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"]){
        [self.globalBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
    }
    //Register the tableView cell
    [self.messageTableView registerNib:[UINib nibWithNibName:@"MessagesTableViewCell" bundle:nil] forCellReuseIdentifier:@"MessagesTableViewCell"];
    
    if (THREEOPTIONSCOMINGFROM == 1) {
        self.menuBtnProperty.tag = 8888;
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(0,20, 0, 0)];
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        }
        else {
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        }
        
    }else {
        self.menuBtnProperty.tag = 9999;
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            [self.menuBtnProperty setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        }
        else {
            [self.menuBtnProperty setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestToFetchUserChatList) name:@"messageReceived" object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageReceived" object:nil];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayMessageRowData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[self.messageTableView dequeueReusableCellWithIdentifier:identifier];
    
    RowDataModal *tempModel = [arrayMessageRowData objectAtIndex:indexPath.row];
    [cell.userlabel setText:tempModel.userName];
//    [cell.userMessageLabel setText:tempModel.message];
    cell.userMessageLabel.attributedText = [NSString customAttributeString:tempModel.message withAlignment:NSTextAlignmentLeft withLineSpacing:5 withFont:[UIFont fontWithName:@"Candara" size:17]];

    [cell.dateLabel setText:[self convertDateWithString:tempModel.messageTime]];
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:tempModel.userImage] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    tempModel.userImageObject = cell.userImageView.image;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    RowDataModal *blockInfo = [arrayMessageRowData objectAtIndex:indexPath.row];
    if (blockInfo.isBlockStatus) {
        return NO;
    }else {
        return YES;
    }
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    RowDataModal *blockInfo = [arrayMessageRowData objectAtIndex:indexPath.row];
    
    UITableViewRowAction *Delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        [self requestDictForDeleteEmail:blockInfo.userID];
                                        [arrayMessageRowData removeObjectAtIndex:indexPath.row];
                                    }];
    
    UITableViewRowAction *Block = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                   {
                                       [self requestDictForUnBlock:blockInfo];
                                   }];
    
    Block.backgroundColor = [UIColor colorWithRed:0 green:188/255.0f blue:170/255.0f alpha:1.0f];
    return @[Block,Delete];
    
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    RowDataModal *blockInfo = [arrayMessageRowData objectAtIndex:indexPath.row];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //remove the deleted object from your data source.
//
//        blockID = blockInfo.userID;
//        blockName = blockInfo.userName;
//        [self requestDictForUnBlock:blockInfo.userID];
//        [_messageTableView reloadData]; // tell table to refresh now
//    }
//
//
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomChatVC *chatVC = [[CustomChatVC alloc]init];
    chatVC.presentBool = NO;
    chatVC.userProfileDetail = [arrayMessageRowData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - Date Format

-(NSString*)convertDateWithString:(NSString *)dateStr{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    // Convert date object to desired output format
    [dateFormat setDateFormat:@"MM/dd/YYYY"];
    dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton's Action

- (IBAction)menuButton:(UIButton *)sender {
    [self.view endEditing:YES];

//    UIButton *btn = (UIButton *)sender;
//
//    if ([[btn currentImage] isEqual:[UIImage imageNamed:@"back_icon"]] || [[btn currentImage] isEqual:[UIImage imageNamed:@"back_rotate"]]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else {
//        [self.sidePanelController showLeftPanelAnimated:YES];
//    }
    
    if (sender.tag == 8888) {
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
        }
            break;
        default:
            break;
    }
    // NSLog(@"Circular Button : Clicked button at index : %d",buttonIndex);
}

// in case no data found on screen
-(void)showLabelIfNoDataFound:(NSString *)message{
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.messageTableView.bounds.size.width,  self.messageTableView.bounds.size.height)];
    noDataLabel.text             = KNSLOCALIZEDSTRING(message);
    noDataLabel.textColor        = [UIColor whiteColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.messageTableView.backgroundView = noDataLabel;
    [self.messageTableView reloadData];
}

#pragma mark - API request
-(void)requestToFetchUserChatList {
    
    NSString *apiName = [NSString stringWithFormat:@"chatUserList/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            NSArray *userList = [result objectForKeyNotNull:@"data" expectedObj:[NSArray array]];
            [arrayMessageRowData removeAllObjects];
            if (!userList.count) {
                [self showLabelIfNoDataFound:@"No record found."];
            }
         
            for (NSDictionary *rowData in userList) {
                [arrayMessageRowData addObject:[RowDataModal parseListOfChatUsers:rowData]];
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageTime"  ascending:NO];
            [arrayMessageRowData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [self.messageTableView reloadData];
            
            [self requestDictForBlockList];
            
        }
        
    }];
    
    
}

-(void) requestDictForDeleteEmail:(NSString*)deleteID {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:deleteID forKey:@"otherUserID"];
    
    NSString *apiName = [NSString stringWithFormat:@"deleteChat/%@/%@",[NSUSERDEFAULT valueForKey:@"userID"],deleteID];
    
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        
        if(!error)
        {

            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Message deleted successfully.") onController:self];
            if (!arrayMessageRowData.count) {
                [self showLabelIfNoDataFound:@"No record found."];
            }
            [self.messageTableView reloadData];
            
        }
    }];
    
   
}

-(void)requestDictForUnBlock:(RowDataModal *)objModel {
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mma"];
    NSString *dateStr = [dateFormat stringFromDate:now];
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:objModel.userID forKey:@"block_id"];
    [requestDict setValue:dateStr forKey:@"time"];
    
    [requestDict setValue:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"message/user_block_unblock" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            [self requestDictForBlock:objModel];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
    
}

// block user
-(void)requestDictForBlock:(RowDataModal *)objModel {
 
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    [requestDict setValue:objModel.userID forKey:@"block_id"];
    [requestDict setValue:objModel.userName forKey:@"block_name"];
    
    [[OPServiceHelper sharedServiceHelper]PostAPICallWithParameter:requestDict apiName:@"blockuser" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            
            objModel.isBlockStatus = YES;
            
            
            //            for (RowDataModal *obj in arrayMessageRowData) {
            //                if ([obj.userID isEqualToString:objModel.userID]) {
            //                    obj.isBlockStatus = YES;
            //                }
            //            }
            NSMutableDictionary *dic = [result objectForKeyNotNull:@"data" expectedObj:[NSDictionary dictionary]];

            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:[dic objectForKeyNotNull:@"msg" expectedObj:@""] onController:self.navigationController];
            [self.messageTableView reloadData];
        }
    }];
  
}


-(void)requestDictForBlockList {
    
    
    NSString *apiName = [NSString stringWithFormat:@"blockeduserlist/%@",[NSUSERDEFAULT valueForKey:@"userID"]];
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
            
            NSArray *blockList = [[[result objectForKeyNotNull:@"data" expectedObj:[NSArray array]] firstObject] objectForKeyNotNull:@"blocked_user" expectedObj:[NSArray array]];
            for (NSDictionary *dic in blockList) {
                for (RowDataModal *obj in arrayMessageRowData) {
                    if ([obj.userID isEqualToString:[dic objectForKeyNotNull:@"id" expectedObj:@""]])
                        obj.isBlockStatus = YES;
                }
            }
            [self.messageTableView reloadData];
        }
        
    }];
    
   
}




@end
