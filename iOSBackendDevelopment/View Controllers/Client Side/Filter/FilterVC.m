//
//  FilterVC.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 30/03/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "FilterVC.h"
#import "JASidePanelController.h"
#import "MacroFile.h"
#import "OptionsPickerSheetView.h"
#import "UserInfo.h"
#import "AppUtilityFile.h"
#import "HeaderFile.h"
#import "ADCircularMenu.h"


static NSString *CellIdentifier = @"SignUpTableViewCell";

@interface FilterVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ADCircularMenuDelegate>
{
    ADCircularMenu *circularMenuVC;
    CCPagination *pagination;
}
@property (weak, nonatomic) IBOutlet UILabel *filterByRatingLabel;

@property (strong, nonatomic) IBOutlet UITableView *filterTableView;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UILabel *lblFilter;

@property (weak, nonatomic) IBOutlet UIButton *applyFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet DXStarRatingView *fiveStarView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *fourStarView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *threeStarView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *twoStarView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *oneStarView;
@property (weak, nonatomic) IBOutlet UIButton *fiveCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *threeCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneCheckBtn;

@end

@implementation FilterVC
{
    NSMutableArray *priceArray,*distanceArray,*ratingsArray,*jobsArray;
     UserInfo *modalObject;
}

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

-(void)initialSetup {
    
    _lblFilter.text = KNSLOCALIZEDSTRING(@"Filter");
      [self.applyFilterBtn setTitle:KNSLOCALIZEDSTRING(@"Apply Filters") forState:UIControlStateNormal] ;
    
    _filterByRatingLabel.text = KNSLOCALIZEDSTRING(@"Filter by Ratings");
    //Register TableView Cell
    [self.filterTableView registerNib:[UINib nibWithNibName:@"SignUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"SignUpTableViewCell"];
    

    
    //Set Header and Footer of TableView
    [self.filterTableView setTableFooterView:self.footerView];
    [self.filterTableView setTableHeaderView:self.headerView];
    
    //Bounce table vertical if required
    [self.filterTableView setAlwaysBounceVertical:NO];
    
    //Initalise the Arrays
    priceArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Low to High"),KNSLOCALIZEDSTRING(@"High to Low"),nil];
    distanceArray = [[NSMutableArray alloc]initWithObjects:@"10",@"20",@"30",@"40",@"50",@"75",@"100",@"150",@"250",@"500",@"1000",@"All",nil];
//    ratingsArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Low to High"),KNSLOCALIZEDSTRING(@"High to Low"),nil];
    ratingsArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"1 Star"),KNSLOCALIZEDSTRING(@"2 Star"),KNSLOCALIZEDSTRING(@"3 Star"),KNSLOCALIZEDSTRING(@"4 Star"),KNSLOCALIZEDSTRING(@"5 Star"),KNSLOCALIZEDSTRING(@"Any"),nil];

    jobsArray = [[NSMutableArray alloc]initWithObjects:@"<10",@"11-100",@"101-200",@"201-300",@">300",nil];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    modalObject.isAvailability = NO;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        [_backButton setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(15, 20, 0, 0)];
    }
    [self.fiveStarView setStars:5];
    [self.fiveStarView setUserInteractionEnabled:NO];
    [self.fourStarView setStars:4];
     [self.fourStarView setUserInteractionEnabled:NO];
    [self.threeStarView setStars:3];
     [self.threeStarView setUserInteractionEnabled:NO];
    [self.twoStarView setStars:2];
     [self.twoStarView setUserInteractionEnabled:NO];
    [self.oneStarView setStars:1];
     [self.oneStarView setUserInteractionEnabled:NO];
    modalObject.strFilterByRatings = @"";
}

#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        SignUpTableViewCell *cell = (SignUpTableViewCell *)[self.filterTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell.contactPrefixButton setHidden:YES];
        [cell.signUpTextField setDelegate:self];
        [cell.signUpTextField setRightViewMode:UITextFieldViewModeAlways];
        [cell.signUpTextField setTextAlignment:NSTextAlignmentLeft];
        [cell.signUpTextField setTag:indexPath.row + 10];
        [cell.pickerButton setTag:indexPath.row + 100];
        [cell.imageViewDrop setTag:indexPath.row + 1000];
       if (SCREEN_WIDTH == 320) {
           [cell.signUpTextField setFont:APPFONTREGULAR(12)];
       }else{
           [cell.signUpTextField setFont:[UIFont fontWithName:@"Candara" size:16.0f]];

       }
        addPading(cell.signUpTextField);
       [cell.imageViewDrop setHidden:NO];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        [cell.signUpTextField setTextAlignment:NSTextAlignmentRight];
    }
    
            switch (indexPath.row) {
            case 0:
            {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Filter by Price")]];
                [cell.signUpTextField setText:modalObject.strFilterByPrice];
                [cell.pickerButton addTarget:self action:(@selector(addFilterPricePicker:)) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 1:
            {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Filter by Distance(Kilometer)")]];
                 //[cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:6.0f]];
                [cell.signUpTextField setText:modalObject.strFilterByDistance];
                [cell.pickerButton addTarget:self action:(@selector(addFilterDistancePicker:)) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 2:
            {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Filter by Number of Jobs")]];
               // [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:6.0f]];
                [cell.signUpTextField setText:modalObject.strFilterByJobs];
                [cell.pickerButton addTarget:self action:(@selector(addFilterJobPicker:)) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 3:
            {
               [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Availability")]];
                (modalObject.isAvailability)? (cell.imageViewDrop.image = [UIImage imageNamed:@"check_icon_sel1"]): (cell.imageViewDrop.image = [UIImage imageNamed:@"check_icon1"]);
               [cell.pickerButton addTarget:self action:(@selector(buttonPressed:)) forControlEvents:UIControlEventTouchUpInside];
            
            break;
           }
            default:
                break;
        }
        return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 60.0f;
}

-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}



#pragma mark - OptionsPickerSheetView Methods

-(void)addFilterPricePicker: (id)sender {
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:priceArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strFilterByPrice =KNSLOCALIZEDSTRING(selectedText);
        [self.filterTableView reloadData];
    }];
}

-(void)addFilterDistancePicker: (id)sender {
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:distanceArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strFilterByDistance =KNSLOCALIZEDSTRING(selectedText);
        [self.filterTableView reloadData];
    }];
}

-(void)addFilterRatingPicker: (id)sender {
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:ratingsArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strFilterByRatings =KNSLOCALIZEDSTRING(selectedText);
        [self.filterTableView reloadData];
    }];
}

-(void)addFilterJobPicker: (id)sender {
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:jobsArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strFilterByJobs =KNSLOCALIZEDSTRING(selectedText);
        [self.filterTableView reloadData];
    }];

    
}

#pragma mark - UIButton Action

-(void)buttonPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag: (sender.tag - 100)+1000];
    
    if(sender.selected)
    {
        imageView.image = [UIImage imageNamed:@"check_icon_sel1"];
        modalObject.isAvailability = YES;
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"check_icon1"];
        modalObject.isAvailability = NO;
    }
}
- (IBAction)commonBtnAction:(UIButton *)sender {
    switch (sender.tag) {
        case 5:
        {
            modalObject.strFilterByRatings = @"5";
            sender.selected = !sender.selected;
            self.fourCheckBtn.selected = NO;
            self.threeCheckBtn.selected = NO;
            self.twoCheckBtn.selected = NO;
            self.oneCheckBtn.selected = NO;
        }
            break;
        case 4:
        {
            modalObject.strFilterByRatings = @"4";
            sender.selected = !sender.selected;
            self.fiveCheckBtn.selected = NO;
            self.threeCheckBtn.selected = NO;
            self.twoCheckBtn.selected = NO;
            self.oneCheckBtn.selected = NO;
        }
            break;
        case 3:
        {
            modalObject.strFilterByRatings = @"3";
            sender.selected = !sender.selected;
            self.fourCheckBtn.selected = NO;
            self.fiveCheckBtn.selected = NO;
            self.twoCheckBtn.selected = NO;
            self.oneCheckBtn.selected = NO;
        }
            break;
        case 2:
        {
            modalObject.strFilterByRatings = @"2";
            sender.selected = !sender.selected;
            self.fourCheckBtn.selected = NO;
            self.threeCheckBtn.selected = NO;
            self.fiveCheckBtn.selected = NO;
            self.oneCheckBtn.selected = NO;
        }
            break;
        case 1:
        {
            modalObject.strFilterByRatings = @"1";
            sender.selected = !sender.selected;
            self.fourCheckBtn.selected = NO;
            self.threeCheckBtn.selected = NO;
            self.twoCheckBtn.selected = NO;
            self.fiveCheckBtn.selected = NO;
        }
            break;
        default:
            break;
    }
}

- (IBAction)btnSocial:(id)sender {
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


- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (IBAction)filterAction:(id)sender {
    [self requestDictForFilter];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForFilter {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    NSString *distance = modalObject.strFilterByDistance;
    [TRIM_SPACE(distance) length]?[distance isEqualToString:@"All"]?(distance = [NSString string]):(distance = [NSString stringWithFormat:@"%f",[modalObject.strFilterByDistance intValue]*0.62137]):(distance = [NSString string]);
    
    NSString *price = modalObject.strFilterByPrice;
    [TRIM_SPACE(price) length]?[price isEqual:@"High to Low"]?(price = @"desc"):(price = @"asc"):(price = [NSString string]);
//    NSString *rating;
//    if([modalObject.strFilterByRatings isEqualToString:@"1 Star"]) {
//        rating = @"1";
//    }else if([modalObject.strFilterByRatings isEqualToString:@"2 Star"]) {
//        rating = @"2";
//    }else if([modalObject.strFilterByRatings isEqualToString:@"3 Star"]) {
//        rating = @"3";
//    }else if([modalObject.strFilterByRatings isEqualToString:@"4 Star"]) {
//        rating = @"4";
//    }else if([modalObject.strFilterByRatings isEqualToString:@"5 Star"]) {
//        rating = @"5";
//    }else {
//        rating = @"";
//    }

//    [TRIM_SPACE(rating) length]?[rating isEqualToString:@"High to Low"]?(rating = @"desc"):(rating = @"asc"):(rating = [NSString string]);

    NSString *numberOfJob;
    [modalObject.strFilterByJobs isEqual: @"<10"]?(numberOfJob = @"0-10"):[modalObject.strFilterByJobs isEqual: @">300"]?(numberOfJob = @"300-"""): (numberOfJob =modalObject.strFilterByJobs);
    
    NSArray *numberOfJobSringArray = [numberOfJob componentsSeparatedByString:@"-"];
    NSString *minNumberOfJob = [[numberOfJobSringArray firstObject] length]?[numberOfJobSringArray firstObject]:(minNumberOfJob = [NSString string]);
    NSString *maxNumberOfJob = [[numberOfJobSringArray lastObject] length]?[numberOfJobSringArray lastObject]:(maxNumberOfJob = [NSString string]);
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:distance forKey:pDistance];
    [requestDict setValue:price forKey:pPrice];
    [requestDict setValue:modalObject.strFilterByRatings forKey:pRating];
    [requestDict setValue:minNumberOfJob forKey:pJobMin];
    [requestDict setValue:maxNumberOfJob forKey:pJobMax];
    [requestDict setValue:(modalObject.isAvailability)?@"1":[NSString string] forKey:pAvailability];
  
    [requestDict setValue:[TRIM_SPACE(self.catagoryName) length]?self.catagoryName:[NSString string] forKey:pCategory];
    ([TRIM_SPACE(self.catagoryName) length])?[requestDict setValue:[NSString string] forKey:pFavourite]:([requestDict setValue:@"1" forKey:pFavourite]);

    [requestDict setValue:@"10" forKey:pPageSize];
    [requestDict setValue:@"1" forKey:pPageNumber];
    [requestDict setValue:@"1" forKey:pGetAll];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/filter_list" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            NSMutableArray *catagoryListAfterFilterArray = [NSMutableArray array];
            NSArray *categoryList = [result objectForKeyNotNull:pProviderList expectedObj:[NSArray array]];
            
            for (NSDictionary *rowData in categoryList) {
                [catagoryListAfterFilterArray addObject:[RowDataModal parseCatagoryList:rowData comingFromServiceTracking:NO]];
            }
            
            pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
            [self.delegate methodForListAfterFilter:catagoryListAfterFilterArray andPaginationInformation:pagination];
            
            [self.navigationController popViewControllerAnimated:YES ];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}


@end
