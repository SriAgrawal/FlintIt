//
//  BlockListVC.m
//  iOSBackendDevelopment
//
//  Created by Yogesh Pal on 08/12/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "BlockListVC.h"
#import "HeaderFile.h"
#import "BlockListCell.h"

@interface BlockListVC ()<UITableViewDelegate,UITableViewDataSource, ADCircularMenuDelegate>
{
    NSMutableArray *dataSourceArray;
    ADCircularMenu *circularMenuVC;
    NSString *blockID,*blockName;
    
    
}
@property (weak, nonatomic) IBOutlet UITableView *blockTableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation BlockListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)initialSetup {
    //Register Cell
    [self.blockTableView registerNib:[UINib nibWithNibName:@"BlockListCell" bundle:nil] forCellReuseIdentifier:@"BlockListCell"];
    _titleLabel.text = KNSLOCALIZEDSTRING(@"Block List");
    self.blockTableView.allowsMultipleSelectionDuringEditing = NO;
    //Alloc array
    dataSourceArray = [[NSMutableArray alloc]init];
    
    
    [ self requestDictForAllBlockList];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSourceArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BlockListCell *cell = (BlockListCell *)[self.blockTableView dequeueReusableCellWithIdentifier:@"BlockListCell"];
    
    UserInfo *blockList = [dataSourceArray objectAtIndex:indexPath.row];
    [cell.userNameLbl setText:blockList.strUsername];
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:blockList.strUpload] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    if ([blockList.strBlockTime containsString:@" "])
        cell.blockTimeLbl.text = [NSString stringWithFormat:@"Blocked On:%@", [blockList.strBlockTime replaceCharcter:@" " withCharcter:@","]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
- ( NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Unblock";
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *blockInfo = [dataSourceArray objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataSourceArray removeObjectAtIndex:indexPath.row];
        if (!dataSourceArray.count) {
            [self performSelector:@selector(performAfterDelay) withObject:nil afterDelay:0.5];
        }
        blockID = blockInfo.strUserID;
        blockName = blockInfo.strUsername;
        [self requestDictForUnBlock:blockInfo.strUserID];
    }
}
-(void)performAfterDelay{
    [self showLabelIfNoDataFound:@"No record found."];
}
- (IBAction)menuBtnAction:(id)sender {
    [self.view endEditing:YES];
    [self.sidePanelController showLeftPanelAnimated:YES];
}
- (IBAction)languageBtnAction:(id)sender {
    
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

/*********************** Service Implementation Methods ****************/


-(void)requestDictForAllBlockList {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setValue:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"message/user_block_list" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            
            [dataSourceArray removeAllObjects];
            dataSourceArray = [self getParseOfBlockList:[result objectForKeyNotNull:@"block_list" expectedObj:[NSArray array]]];
            if (!dataSourceArray.count) {
                [self showLabelIfNoDataFound:@"No record found."];
            }
            [self.blockTableView reloadData];
            
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            
        }
    }];
    
}

-(void)requestDictForUnBlock:(NSString *)blockId {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mma"];
    NSString *dateStr = [dateFormat stringFromDate:now];
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:blockId forKey:@"block_id"];
    [requestDict setValue:dateStr forKey:@"time"];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"message/user_block_unblock" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [self requestDictForUnBlockMessage];
            [self.blockTableView reloadData];
            
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
    
}

-(void)requestDictForUnBlockMessage{
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    [requestDict setObject:blockID forKey:@"block_id"];
    [requestDict setObject:blockName forKey:@"block_name"];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"unblockuser" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"User unblocked successfully.") onController:self.navigationController];
            [self.blockTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
}

-(NSMutableArray *)getParseOfBlockList:(NSMutableArray *)blockArray{
    
    NSMutableArray *blockListArray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *dic in blockArray) {
        UserInfo *blockInfo = [[UserInfo alloc] init];
        blockInfo.strUserID = [dic objectForKeyNotNull:@"block_id" expectedObj:@""];
        blockInfo.strUsername = [dic objectForKeyNotNull:@"user_name" expectedObj:@""];
        blockInfo.strUpload = [dic objectForKeyNotNull:@"profile_image" expectedObj:@""];
        blockInfo.strBlockTime = [dic objectForKeyNotNull:@"time" expectedObj:@""];
        [blockListArray addObject:blockInfo];
    }
    return blockListArray;
}
// in case no data found on screen
-(void)showLabelIfNoDataFound:(NSString *)message{
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.blockTableView.bounds.size.width,  self.blockTableView.bounds.size.height)];
    noDataLabel.text             = KNSLOCALIZEDSTRING(message);
    noDataLabel.textColor        = [UIColor whiteColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.blockTableView.backgroundView = noDataLabel;
    [self.blockTableView reloadData];
}
@end
