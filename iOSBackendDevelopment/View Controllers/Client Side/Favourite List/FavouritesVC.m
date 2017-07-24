//
//  FavouritesVC.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 30/03/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "FavouritesVC.h"
#import "FavouritesTableViewCell.h"
#import "RowDataModal.h"
#import "MacroFile.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AppUtilityFile.h"
#import "ADCircularMenu.h"
#import "ServiceTrackingVC.h"
#import "EmailListViewController.h"
#import "MacroFile.h"
#import "MessagesVC.h"
#import "FilterVC.h"
#import "MapScreenVC.h"

static NSString *identifier = @"FavouritesTableViewCell";

@interface FavouritesVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ADCircularMenuDelegate> {
    
    NSMutableArray *userDataArray;
    ADCircularMenu *circularMenuVC;
    RowDataModal *object;
    //For Pagination
    BOOL isFromFilter;
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *favouriteTableView;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *lblFavourites;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@property (strong, nonatomic) NSString *favouriteID;
@property (assign) BOOL isSearchData;
@property (weak, nonatomic) IBOutlet UIButton *mapBtn;

@end

@implementation FavouritesVC

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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Helper Class

-(void)initialSetup {
    
    _lblFavourites.text = KNSLOCALIZEDSTRING(@"Favourites");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [_searchTextField setTextAlignment:NSTextAlignmentRight];
    }

    //Alloc the array of favourite list data
    userDataArray = [NSMutableArray array];
    
    //Register Cell
     [self.favouriteTableView registerNib:[UINib nibWithNibName:@"FavouritesTableViewCell" bundle:nil] forCellReuseIdentifier:@"FavouritesTableViewCell"];
    
    //Layout of search field
    [_searchTextField setPlaceholder:KNSLOCALIZEDSTRING(@"Search Service Providers")];
    [_searchTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_searchTextField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    //Add pading in the search field
    addPading(self.searchTextField);
    
    //Add Search icon on search Text Field
    UIView *leftPaddignView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 30, 30)];
    [searchIcon setImage:[UIImage imageNamed:@"search_icon1"]];
    
    [leftPaddignView addSubview:searchIcon];
    [self.searchTextField setLeftView:leftPaddignView];
    [self.searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];

    //Get favourite List
    [self requestDictForFavouriteList:pagination];
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.favouriteTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self requestDictForFavouriteList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavouritesTableViewCell *cell = (FavouritesTableViewCell *)[self.favouriteTableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    RowDataModal *favoriteObject = [userDataArray objectAtIndex:indexPath.row];
    
    if (userDataArray.count) {
        UILabel * backGroundLabel = (UILabel *)[self.view viewWithTag:1000];
        backGroundLabel.text = @"";
    }
    [cell.userLabel setText:favoriteObject.userName];
    [cell.reviewLabel setText:favoriteObject.reviewDetail];
    [cell.workLabel setText:favoriteObject.userNumberFollowed];
    //[cell.userImageView setImage:[UIImage imageNamed:favoriteObject.userImage]];
    [cell.userImageView sd_setImageWithURL:favoriteObject.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [cell.starRatingView setStars:(int)favoriteObject.ratingNumber];
   // [cell.categoryImageview setImage:[UIImage imageNamed:favoriteObject.userCatagoryImage]];
//    [cell.descriptionLabel setText:favoriteObject.userCatagory];
    // localise
    [cell.descriptionLabel setText:KNSLOCALIZEDSTRING(favoriteObject.userCatagory)];

    [cell.categoryImageview setImage:[UIImage imageNamed:favoriteObject.userCatagoryImage]];
    cell.categoryImageview.image = [cell.categoryImageview.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [ cell.categoryImageview setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];

    
    _favouriteID = favoriteObject.FavouriteID;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProviderDetial *providerDetailObj = [[ProviderDetial alloc]initWithNibName:@"ProviderDetial" bundle:nil];
    providerDetailObj.isComingFromMenuServiceTracking = NO;
    providerDetailObj.delegate = self;
    providerDetailObj.particularServiceProviderDetail = [userDataArray objectAtIndex:indexPath.row];
    providerDetailObj.particularServiceProviderDetail.selectedServiceProviderIndex = indexPath.row;
    [self.navigationController pushViewController:providerDetailObj animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    RowDataModal *favoriteObject = [userDataArray objectAtIndex:indexPath.row];

        [self requestDictForDeleteFavouriteList:favoriteObject];
}


-(void)changeInTheServiceProviderDetail:(RowDataModal *)serviceProviderDetail {
    NSInteger selectedIndex = serviceProviderDetail.selectedServiceProviderIndex;
    [userDataArray replaceObjectAtIndex:selectedIndex withObject:serviceProviderDetail];
}


#pragma mark - UItextfield Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    
    if (textField == _searchTextField) {
        
        NSMutableDictionary * requestDict = [[NSMutableDictionary alloc]init];
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
        [requestDict setValue:@"all" forKey:pCatagoryName];
        [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
        [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];

        [requestDict setValue:[NSNumber numberWithBool:YES] forKey:pFavourite];
        
        NSArray * arrayOfCategories = [textField.text componentsSeparatedByString:@","];
        [requestDict setValue:arrayOfCategories forKey:@"description_array"];
       
        [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage]  forKey:@"language_preference"];
        [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/search_list_description" WithComptionBlock:^(id result, NSError *error) {
           
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                if (![[result valueForKey:pResponseMsg] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                    _isSearchData = YES;
                    NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
                    
                    [userDataArray removeAllObjects];
                    for (NSDictionary *rowData in categoryList) {
                        [userDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
                    }
                    [self.favouriteTableView reloadData];
                    
                }else
                {
                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"No match found.") onController:self];
                }

            }
            
        }];
        
    }
    

    
    return YES;
 }

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
    if (isFromFilter) {
        if (_isSearchData) {
            NSLog(@"All data is available at a time");
        }else
        {
            
        }
    }else
    {
        if (_isSearchData) {
            NSLog(@"All data is available at a time");
        }else
        {
                NSInteger currentOffset = scrollView.contentOffset.y;
                NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
                if (maximumOffset - currentOffset <= 10.0)
                {
                    if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting)
                    {
                        [self requestDictForFavouriteList:pagination];
                    }
                }
        }
    }
    
//    if (_isSearchData) {
//        
//    }else{
//    
//    NSInteger currentOffset = scrollView.contentOffset.y;
//    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
//    if (maximumOffset - currentOffset <= 10.0) {
//        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
//            [self requestDictForFavouriteList:pagination];
//        }
//      }
//    }
}


#pragma mark - UIButton Actions

- (IBAction)menuButton:(id)sender {
    [self.view endEditing:YES];
    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (IBAction)socialButton:(id)sender {
    [self.view endEditing:YES];

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

- (IBAction)filterButton:(id)sender {
    [self.view endEditing:YES];

    FilterVC *filterObject = [[FilterVC alloc]initWithNibName:@"FilterVC" bundle:nil];
    filterObject.catagoryName = [NSString string];
    filterObject.delegate = self;
    _isSearchData = NO;
  [self.navigationController pushViewController:filterObject animated:YES];
}

- (IBAction)btnMap:(id)sender {
    [self.view endEditing:YES];

    MapScreenVC *mapObject = [[MapScreenVC alloc]initWithNibName:@"MapScreenVC" bundle:nil];
    mapObject.isFromFavourite = YES;
    [self.navigationController pushViewController:mapObject animated:YES];
}

#pragma mark - Service Implementation Methods

-(void)requestDictForFavouriteList:(CCPagination *)page {
    
    isLoadMoreExecuting = NO;

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
   
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_favourite_list" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            _isSearchData = NO;
            
            if ([pagination.pageNo integerValue] == 0) {
                [userDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                [self showLabelIfNoDataFound:[result objectForKeyNotNull:pResponseMsg expectedObj:@""]];
//                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.favouriteTableView.bounds.size.width,  self.favouriteTableView.bounds.size.height)];
//                noDataLabel.tag              = 1000;
//                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
//                noDataLabel.textColor        = [UIColor whiteColor];
//                noDataLabel.textAlignment    = NSTextAlignmentCenter;
//                self.favouriteTableView.backgroundView = noDataLabel;
//                _mapBtn.userInteractionEnabled = YES;
//                [self.favouriteTableView reloadData];
                
            }else {
                isLoadMoreExecuting = YES;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSArray *favouriteList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
                
                for (NSDictionary *rowData in favouriteList) {
                    [userDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
                }
                
                [self.favouriteTableView reloadData];
            }

        }else
        {
            
        }
    }];
    
}

-(void)requestDictForDeleteFavouriteList:(RowDataModal *)objModel {
    
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
    [requestDict setValue:objModel.FavouriteID forKey:pFavouriteID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/delete_favourite_list" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            [userDataArray removeObject:objModel];
            [_favouriteTableView reloadData];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}
// in case no data found on screen
-(void)showLabelIfNoDataFound:(NSString *)message{
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.favouriteTableView.bounds.size.width,  self.favouriteTableView.bounds.size.height)];
    noDataLabel.tag              = 1000;
    noDataLabel.text             = KNSLOCALIZEDSTRING(message);
    noDataLabel.textColor        = [UIColor whiteColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.favouriteTableView.backgroundView = noDataLabel;
    _mapBtn.userInteractionEnabled = YES;
    [self.favouriteTableView reloadData];
}


-(void)methodForListAfterFilter:(NSMutableArray *)listArray andPaginationInformation:(CCPagination *)pageInformation {
    [userDataArray removeAllObjects];
    isFromFilter = YES;
    _isSearchData = NO;
    userDataArray = listArray;
    pagination = pageInformation;

    if (!userDataArray.count) {
        [self showLabelIfNoDataFound:@"No record found."];
    }
    [self.favouriteTableView reloadData];
}

@end
