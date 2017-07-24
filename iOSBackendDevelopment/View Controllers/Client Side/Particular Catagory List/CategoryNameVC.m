//
//  CategoryNameVC.m
//  iOSBackendDevelopment
//
//  Created by admin on 09/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "CategoryNameVC.h"
#import "CategoryNameTableViewCell.h"
#import "MacroFile.h"
#import "DXStarRatingView.h"
#import "RowDataModal.h"
#import "MacroFile.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AppUtilityFile.h"
#import "ADCircularMenu.h"
#import "ProviderDetial.h"
#import "HeaderFile.h"
#import "CCPagination.h"
#import "CustomChatVC.h"

static NSString *cellIdentifier = @"CategoryNameTableViewCell";

@interface CategoryNameVC ()<UITableViewDataSource,UITableViewDelegate,ADCircularMenuDelegate,UITextFieldDelegate> {
    
    NSMutableArray *userDataArray;
    NSMutableArray *searchArray;
    BOOL isSearching;
    ADCircularMenu *circularMenuVC;
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    BOOL isFromFilter;
    UIRefreshControl *refreshControl;
    IBOutlet UIButton *btnMap;
}

@property (assign) BOOL isSearchData;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextfield;

@end

@implementation CategoryNameVC

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.


    [self initialSetup];
//    if (!isFromFilter) {
//        pagination.pageNo = 0;
//        [self requestDictForCatagoryList:pagination];
//    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self initialSetup];
    if (!isFromFilter) {
        pagination.pageNo = 0;
        [self requestDictForCatagoryList:pagination];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Helper Methods
-(void)initialSetup {
    _lblNavTitle.text = KNSLOCALIZEDSTRING(self.selectedCatagory);
    
    //Initalise the Array of modal Class
    userDataArray = [NSMutableArray array];
    searchArray = [NSMutableArray array];
    isSearching = NO;
    //Register Cell
    [self.categoryTableView registerNib:[UINib nibWithNibName:@"CategoryNameTableViewCell" bundle:nil] forCellReuseIdentifier:@"CategoryNameTableViewCell"];

    //Layout of search field
    [_searchTextfield setPlaceholder:KNSLOCALIZEDSTRING(@"Search")];
    [_searchTextfield setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_searchTextfield.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    //Add pading in the search field
     addPading(self.searchTextfield);
    
    //Add Search icon on search Text Field
    UIView *leftPaddignView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 30, 30)];
    [searchIcon setImage:[UIImage imageNamed:@"search_icon1"]];
    
    [leftPaddignView addSubview:searchIcon];
    [_searchTextfield setLeftView:leftPaddignView];
    [_searchTextfield setLeftViewMode:UITextFieldViewModeAlways];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
         self.searchTextfield.textAlignment = NSTextAlignmentRight;
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.backButton setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    
    [self addPullToRefresh];
    
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTableCategoryVC) forControlEvents:UIControlEventValueChanged];
    [self.categoryTableView addSubview:refreshControl];
}

-(void)refereshTableCategoryVC {
    
    pagination.pageNo = 0;
    [self requestDictForCatagoryList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}


-(void)endrefresing{
    [refreshControl endRefreshing];
}



#pragma mark - UITableView DataSources and Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isSearching ? [searchArray count] : [userDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CategoryNameTableViewCell *cell = (CategoryNameTableViewCell *)[self.categoryTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RowDataModal *categoryObject = [userDataArray objectAtIndex:indexPath.row];

    [cell.lblUserName setText:categoryObject.userName];
    [cell.starRatingView setStars:(int)categoryObject.ratingNumber];
    [cell.lblreview setText:categoryObject.reviewDetail];
    [cell.lblDescription setText:categoryObject.userNumberFollowed];
    [cell.userImageView sd_setImageWithURL:categoryObject.userProfileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    // add live address here.
    [cell.lblAddress setText:categoryObject.userLocationName];
    

    
    if (isSearching) {
        if (categoryObject.isLocationFetched) {
            [cell.lblAddress setText:categoryObject.userLocationName];
        }else{
            [categoryObject getUserAddressFromObjModal:categoryObject completionHandler:^{
            [cell.lblAddress setText:categoryObject.userLocationName];
                
            }];
        }
    }else{
        if (categoryObject.isLocationFetched) {
            [cell.lblAddress setText:categoryObject.userLocationName];
        }else{
            [categoryObject getUserAddressFromObjModal:categoryObject completionHandler:^{
            [cell.lblAddress setText:categoryObject.userLocationName];
                
            }];
        }
    }
    [cell.lblDistance setText:categoryObject.userDistance];
    [cell.catagoryLbl setText:KNSLOCALIZEDSTRING(categoryObject.userCatagory)];
//    [cell.catagoryLbl setText:categoryObject.userCatagory];
    [cell.categoryImageView setImage:[UIImage imageNamed:categoryObject.userCatagoryImage]];
    cell.categoryImageView.image = [cell.categoryImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.categoryImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProviderDetial *providerDetailObj = [[ProviderDetial alloc]initWithNibName:@"ProviderDetial" bundle:nil];
    providerDetailObj.isComingFromMenuServiceTracking = NO;
    providerDetailObj.delegate = self;
    providerDetailObj.particularServiceProviderDetail = [userDataArray objectAtIndex:indexPath.row];
    providerDetailObj.particularServiceProviderDetail.selectedServiceProviderIndex = indexPath.row;
    [self.navigationController pushViewController:providerDetailObj animated:YES];
}

#pragma mark - UItextfield Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    
    if (textField == _searchTextfield) {
        
        NSMutableDictionary * requestDict = [[NSMutableDictionary alloc]init];
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
        [requestDict setValue:self.selectedCatagory forKey:pCatagoryName];
        [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
        [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
//        [requestDict setValue:@"" forKey:pPageSize];
//        [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
//        [requestDict setValue:@"" forKey:pPageNumber];
        [requestDict setValue:[NSNumber numberWithBool:NO] forKey:pFavourite];

        NSArray * arrayOfCategories = [TRIM_SPACE(textField.text) componentsSeparatedByString:@","];
        [requestDict setValue:arrayOfCategories forKey:@"description_array"];
      
        
        
        [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
        [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict  apiName:@"job/search_list_description" WithComptionBlock:^(id result, NSError *error) {
            
            if (!error) {
                
                if (![[result valueForKey:pResponseMsg] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                    _isSearchData = YES;
                    NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
                    
                    pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                    
                    [userDataArray removeAllObjects];
                    for (NSDictionary *rowData in categoryList) {
                        [userDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
                    }
                    [self.categoryTableView reloadData];
                    
                }else
                {
                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"No match found.") onController:self];
                }
            }else
            {
                isLoadMoreExecuting = YES;

                [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:error.localizedDescription onController:self];
            }
        }];

    }
    
    
    

    return YES;
}

#pragma mark - UIButton Actions

- (IBAction)backAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController  popViewControllerAnimated:YES];
}

- (IBAction)btnMap:(id)sender {
    [self.view endEditing:YES];

    MapScreenVC *mapObject = [[MapScreenVC alloc]initWithNibName:@"MapScreenVC" bundle:nil];
   // mapObject.dataArray = userDataArray ;
    mapObject.mapSelectedCatagory = _selectedCatagory;
    [self.navigationController pushViewController:mapObject animated:YES];
}

- (IBAction)btnFilter:(id)sender {
    [self.view endEditing:YES];

    FilterVC *filterObject = [[FilterVC alloc]initWithNibName:@"FilterVC" bundle:nil];
    filterObject.delegate = self;
    filterObject.catagoryName = self.selectedCatagory;
    _isSearchData = NO;
    [self.navigationController pushViewController:filterObject animated:YES];
}

- (IBAction)btnGlobal:(id)sender {
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
                    [self requestDictForCatagoryList:pagination];
                }
            }
        }

    }
}
#pragma mark - Service Implementation Methods

-(void)requestDictForCatagoryList:(CCPagination *)page {
    
   
    isLoadMoreExecuting = NO;

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:self.selectedCatagory forKey:pCatagoryName];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    [requestDict setValue:@"" forKey:pGetAll];
    [requestDict setValue:[NSNumber numberWithBool:NO] forKey:pFavourite];
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/category_list" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            if ([pagination.pageNo integerValue] == 0) {
                [userDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                [self showLabelIfNoDataFound:[result objectForKeyNotNull:pResponseMsg expectedObj:@""]];
//                UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.categoryTableView.bounds.size.width,  self.categoryTableView.bounds.size.height)];
//                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
//                noDataLabel.textColor        = [UIColor whiteColor];
//                noDataLabel.textAlignment    = NSTextAlignmentCenter;
//                self.categoryTableView.backgroundView = noDataLabel;
//                btnMap.userInteractionEnabled = YES;
//                [self.categoryTableView reloadData];
                
            }else {
                [self showLabelIfNoDataFound:@""];

                isLoadMoreExecuting = YES;
                _isSearchData = NO;
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
                if (!categoryList.count) {
                    btnMap.userInteractionEnabled = YES;
                }
                //  [self getUserUpdateLocation:categoryList andWebMethodType:WebMethodCategoryList];
                
                if (isSearching) {
                    for (NSDictionary *rowData in categoryList) {
                        [searchArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
                    }
                } else {
                    for (NSDictionary *rowData in categoryList) {
                        [userDataArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
                    }
                }
                [self.categoryTableView reloadData];
            }
            
        }else
        {
            isLoadMoreExecuting = YES;

        }
    }];
    
 
}
// in case no data found on screen
-(void)showLabelIfNoDataFound:(NSString *)message{
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.categoryTableView.bounds.size.width,  self.categoryTableView.bounds.size.height)];
    if([message isEqualToString:@""]){
        noDataLabel.text             = message;
    }else{
        noDataLabel.text             = KNSLOCALIZEDSTRING(message);

    }
    noDataLabel.textColor        = [UIColor whiteColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.categoryTableView.backgroundView = noDataLabel;
    btnMap.userInteractionEnabled = YES;
    [self.categoryTableView reloadData];

}
-(void)methodForListAfterFilter:(NSMutableArray *)listArray andPaginationInformation:(CCPagination *)pageInformation {
    [userDataArray removeAllObjects];
    
    isFromFilter = YES;
    _isSearchData = NO;
    if (listArray.count > 0) {

        userDataArray = listArray;
//        [self getUserUpdateLocation:listArray andWebMethodType:-1];
        pagination = pageInformation;
        [self showLabelIfNoDataFound:@""];

        [self.categoryTableView reloadData];

    }else {
        userDataArray = listArray;
        [self showLabelIfNoDataFound:@"No record found."];
        [self.categoryTableView reloadData];
    }
}

-(void)changeInTheServiceProviderDetail:(RowDataModal *)serviceProviderDetail {
    NSInteger selectedIndex = serviceProviderDetail.selectedServiceProviderIndex;
    [userDataArray replaceObjectAtIndex:selectedIndex withObject:serviceProviderDetail];
}



@end
