//
//  SignUpViewController.m
//  iOSBackendDevelopment
//
//  Created by admin on 11/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"
#import "ScrollTableViewCell.h"
#import "SignUpCollectionViewCell.h"
#import "TableViewWithMultipleSelection.h"
#import "BDVCountryNameAndCode.h"

static NSString *CellIdFirst = @"SignUpTableViewCell";
static NSString *CellIdSecond = @"GenderTableViewCell";
static NSString *CellIdThird = @"DescriptionTableViewCell";
static NSString *CellIdFourth = @"CustomTableViewCell";
static NSString *CellIdFifth = @"ScrollTableViewCell";
static NSString *cellIdentifier = @"SignUpCollectionViewCell";

@interface SignUpViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,CountryNameAndPhonePrefixDelegate,UIGestureRecognizerDelegate>
{
    UserInfo *modalObject;
    NSMutableArray *imageArray,*countryArray,*selectedDataArray,*selectedLanguageArray;
    NSString *status;
    CountryNamesAndPhoneNumberPrefix *prefix;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineLabelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSignUp;
@property (weak, nonatomic) IBOutlet MZSelectableLabel *lbltermsService;
@property (weak, nonatomic) IBOutlet MZSelectableLabel *lblLogin;

@property (weak, nonatomic) IBOutlet UITableView *signUpTableview;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnChoose;

@property (weak, nonatomic) IBOutlet UIButton *cameraImageView;

@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;

@property (strong, nonatomic) CountryNamesAndPhoneNumberPrefix *phonePrefix;
@property (nonatomic, strong) NSArray *categoryArray;

@end

@implementation SignUpViewController

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSOperationQueue *locationAndLongituteQueue = [NSOperationQueue new];
    [locationAndLongituteQueue addOperationWithBlock:^{
        [self getAdrressFromLatLong:[[APPDELEGATE latitude] floatValue] lon:[[APPDELEGATE longitude] floatValue]];
    }];
    
    [self initialSetup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)getAdrressFromLatLong:(CGFloat)lat lon:(CGFloat)lon {
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false",lat,lon];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSURLResponse *response = nil;
    
    NSError *requestError = nil;
    
    NSData *rep = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    
    //    NSData *responseData = [NSURLConnection sendSynchronousRequest:request error:&amp;requestError];
    NSDictionary *JSON;
    if (rep != nil) {
        
        JSON = [NSJSONSerialization JSONObjectWithData:rep options: NSJSONReadingMutableContainers error:nil];
    }
    NSArray *resultArray = [JSON objectForKeyNotNull:@"results" expectedObj:@""];
    NSDictionary *address = [resultArray firstObject];
    
    [ self getCityFromLatLon:[address objectForKeyNotNull:@"formatted_address" expectedObj:@""]];
    [self setCurrentCountryDetails];
}

- (void) getCityFromLatLon:(NSString *)address

{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error) {
             [[AlertView sharedManager] displayInformativeAlertwithTitle:@"Error!" andMessage:@"We are not able to get your coordinate. Please try again." onController:self];
         }else {
             if ([placemarks count]>0)
             {
                 // get the first one
                 CLPlacemark *mark = (CLPlacemark*)[placemarks objectAtIndex:0];
                 //                 NSLog(@"%@", mark.locality);
                 //                 NSLog(@"%@", mark.country);
                 //                 NSLog(@"%@", mark.administrativeArea);
                 //                 NSLog(@"%@",mark.ISOcountryCode);
                 modalObject.strLocation = [NSString stringWithFormat:@"%@, %@",mark.administrativeArea,mark.country];
                 modalObject.strAddress = [NSString stringWithFormat:@"%@",mark.subLocality];

                 [self.signUpTableview reloadData];
             }
         }
     }];
}

//- (void)setCurrentCountryDetails {
//    
//    BDVCountryNameAndCode *countryNameAndCode = [[BDVCountryNameAndCode alloc] init];
//    UIImage *flagOfCurrentLocale = [countryNameAndCode countryFlagForCurrentLocale];
//    
//    NSString *prefixOfCurrentLocale = [countryNameAndCode prefixForCurrentLocale];
//    modalObject.strPhonePrefix = prefixOfCurrentLocale;
//    modalObject.flagImage = flagOfCurrentLocale;
//}

- (void)setCurrentCountryDetails {
    
    NSArray  * arryOfCountryList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BDVCountryNameAndCode" ofType:@"plist"]];
    
    if([APPDELEGATE countryCode]){
        for (NSDictionary  *tempCountryCoer in arryOfCountryList) {
            
            
            if ([[APPDELEGATE countryCode] isEqualToString:[tempCountryCoer objectForKey:@"code"]]) {
                
                modalObject.strPhonePrefix = [tempCountryCoer objectForKey:@"dial_code"];
                NSString *imageName = [NSString stringWithFormat:@"CountryPicker.bundle/%@",[APPDELEGATE countryCode]];
                imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                modalObject.flagImage = [UIImage imageNamed:imageName];;
                
                break;
            }
            
        }
        
        
    }else{
        BDVCountryNameAndCode *countryNameAndCode = [[BDVCountryNameAndCode alloc] init];
        UIImage *flagOfCurrentLocale = [countryNameAndCode countryFlagForCurrentLocale];
        
        NSString *prefixOfCurrentLocale = [countryNameAndCode prefixForCurrentLocale];
        modalObject.strPhonePrefix = prefixOfCurrentLocale;
        modalObject.flagImage = flagOfCurrentLocale;
        
    }
    
}


- (void)didGetPhonePrefix:(NSString *)phonePrefix forCountry:(NSString *)countryCode {
    modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",phonePrefix];
}

-(void)failedToGetPhonePrefix {
    
}

#pragma  mark - Helper method

-(void)initialSetup {
    [self.btnSignUp setTitle:KNSLOCALIZEDSTRING(@"Sign Up") forState:UIControlStateNormal] ;
    _lblSignUp.text = KNSLOCALIZEDSTRING(@"Sign Up and get the right person in the right time for the right job.");
    _lbltermsService.text = KNSLOCALIZEDSTRING(@"BY CREATING AN ACCOUNT, YOU AGREE TO Flink It TERMS OF SERVICES.");
    _lblNavTitle.text = KNSLOCALIZEDSTRING(@"Sign Up");
    _lblLogin.text = KNSLOCALIZEDSTRING(@"Already have an account? Login");
    
    //Alloc and set delegate of CountryNamesAndPhoneNumberPrefix
    self.phonePrefix = [[CountryNamesAndPhoneNumberPrefix alloc] initWithDelegate:self];
    
    //Register TableView Cell
    [self.signUpTableview registerNib:[UINib nibWithNibName:@"SignUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"SignUpTableViewCell"];
    [self.signUpTableview registerNib:[UINib nibWithNibName:@"DescriptionTableViewCell" bundle:nil] forCellReuseIdentifier:@"DescriptionTableViewCell"];
    [self.signUpTableview registerNib:[UINib nibWithNibName:@"GenderTableViewCell" bundle:nil] forCellReuseIdentifier:@"GenderTableViewCell"];
    [self.signUpTableview registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomTableViewCell"];
      [self.signUpTableview registerNib:[UINib nibWithNibName:@"ScrollTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScrollTableViewCell"];
    
    //Set Table Header&Footer
    [self.signUpTableview setTableHeaderView:self.headerView];
    [self.signUpTableview setTableFooterView:self.footerView];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    modalObject.strGender = [NSString string];
    modalObject.strAge = [NSString string];
    modalObject.strUpload = [NSString string];
    modalObject.strAddress = [NSString string];
    modalObject.strLocation = [NSString string];
    modalObject.strLanguage = [NSString string];

    //Set Image Outlet
//    [self.btnChoose.layer setCornerRadius:self.btnChoose.frame.size.width/2];
    self.btnChoose.layer.cornerRadius = 57.5;
    [self.btnChoose setClipsToBounds:YES];
    [self.cameraImageView.layer setCornerRadius:20];
    
    //Set range and make Terms of services and Login tappable
    [self.lbltermsService setSelectableRange:[[self.lbltermsService.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"TERMS OF SERVICES.")]];
    self.lbltermsService.selectionHandler = ^(NSRange range, NSString *string) {
        TermsVC *termObj = [[TermsVC alloc]initWithNibName:@"TermsVC" bundle:nil];
        [self.navigationController pushViewController:termObj animated:YES];
    };
    
    [self.lblLogin setAttributedText:[AppUtilityFile getSimpleMultiAttributedString:KNSLOCALIZEDSTRING(@"Already have an account? Login") firstStr:@"Login" withColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:157.0/255.0 alpha:1] withFont:self.lblLogin.font secondStr:nil withColor:nil withFont:nil]];
    [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@"Login"]];
    self.lblLogin.selectionHandler = ^(NSRange range, NSString *string) {
        [self.navigationController popViewControllerAnimated:YES];
    };

    // Manage for Arabic
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@"تسجيل دخول"]];
        _underLineLabelCenterXConstraint.constant = -44;
        [self.lbltermsService setSelectableRange:[[self.lbltermsService.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"TERMS OF SERVICES.")]];

    }
   else if ([language isEqualToString:@"es"]) {
        [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@"Iniciar sesión"]];
        _underLineLabelCenterXConstraint.constant = 77;
        [self.lbltermsService setSelectableRange:[[self.lbltermsService.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"términos de servicios.")]];
   }else{
       _underLineLabelCenterXConstraint.constant = 85;
 
   }

     modalObject.sampleImageArray = [NSMutableArray array];
     imageArray = [NSMutableArray array];
     selectedDataArray = [NSMutableArray array];
     selectedLanguageArray = [NSMutableArray array];

//     UIImage *addMoreImg = [UIImage imageNamed:@"more"] ;
//     addMoreImg.accessibilityIdentifier = @"More button";
//    [imageArray addObject:addMoreImg];
    
   status = @"Profile";
    
    prefix = [[CountryNamesAndPhoneNumberPrefix alloc]init];
    countryArray = [NSMutableArray array];
    [self countryNameAndPrefix];
    
    self.categoryArray = [self getCategories];
  }

- (NSArray *)getCategories {
    //Alloc NSMutable Array
//    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"All"),KNSLOCALIZEDSTRING(@"Bodyguards"),KNSLOCALIZEDSTRING(@"Chefs"),KNSLOCALIZEDSTRING(@"Clean Worker"),KNSLOCALIZEDSTRING(@"Consultation"),KNSLOCALIZEDSTRING(@"Gardener"),KNSLOCALIZEDSTRING(@"Decoration"),KNSLOCALIZEDSTRING(@"Moving"),KNSLOCALIZEDSTRING(@"Painter"),KNSLOCALIZEDSTRING(@"Plumber"),KNSLOCALIZEDSTRING(@"Towing"),KNSLOCALIZEDSTRING(@"Carpenter"),KNSLOCALIZEDSTRING(@"IT"),KNSLOCALIZEDSTRING(@"Exterminator"),KNSLOCALIZEDSTRING(@"Electrician"),KNSLOCALIZEDSTRING(@"Mechanic"),KNSLOCALIZEDSTRING(@"Health"),KNSLOCALIZEDSTRING(@"Beauty"),KNSLOCALIZEDSTRING(@"Tutor"),KNSLOCALIZEDSTRING(@"Tailor"),KNSLOCALIZEDSTRING(@"Snow Shoveling"),KNSLOCALIZEDSTRING(@"Car wash"),KNSLOCALIZEDSTRING(@"Photographer"),KNSLOCALIZEDSTRING(@"Fun & Party"),KNSLOCALIZEDSTRING(@"Black Smithy"),KNSLOCALIZEDSTRING(@"Artist"),KNSLOCALIZEDSTRING(@"Air Cooling"),nil];
    
        NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Bodyguards"),KNSLOCALIZEDSTRING(@"Chefs"),KNSLOCALIZEDSTRING(@"Clean Worker"),KNSLOCALIZEDSTRING(@"Consultation"),KNSLOCALIZEDSTRING(@"Gardener"),KNSLOCALIZEDSTRING(@"Decoration"),KNSLOCALIZEDSTRING(@"Moving"),KNSLOCALIZEDSTRING(@"Painter"),KNSLOCALIZEDSTRING(@"Plumber"),KNSLOCALIZEDSTRING(@"Towing"),KNSLOCALIZEDSTRING(@"Carpenter"),KNSLOCALIZEDSTRING(@"IT"),KNSLOCALIZEDSTRING(@"Exterminator"),KNSLOCALIZEDSTRING(@"Electrician"),KNSLOCALIZEDSTRING(@"Mechanic"),KNSLOCALIZEDSTRING(@"Health"),KNSLOCALIZEDSTRING(@"Beauty"),KNSLOCALIZEDSTRING(@"Tutor"),KNSLOCALIZEDSTRING(@"Tailor"),KNSLOCALIZEDSTRING(@"Snow Shoveling"),KNSLOCALIZEDSTRING(@"Car wash"),KNSLOCALIZEDSTRING(@"Photographer"),KNSLOCALIZEDSTRING(@"Fun & Party"),KNSLOCALIZEDSTRING(@"Black Smithy"),KNSLOCALIZEDSTRING(@"Artist"),KNSLOCALIZEDSTRING(@"Air Cooling"),nil];
    NSMutableArray *arrrayCategory = [NSMutableArray array];
    
    for (NSString *categoryName in categoryArray) {
        
        CategoryModal *category = [[CategoryModal alloc] init];
        category.categoryName = categoryName;
        // set initial selection status
        category.selectionStatus = false;
        [arrrayCategory addObject:category];
    }
    
    return [arrrayCategory mutableCopy];
}

-(void)isAllFieldVerified {
    if(![TRIM_SPACE(modalObject.strUpload) length]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please select the user image.") onController:self];
    }
    else if(modalObject.strUsername == nil || [modalObject.strUsername isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the username.") onController:self];
    }
    else if ([self validateNameWithString:modalObject.strUsername] == NO) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid username.") onController:self];
    }
    else if(![TRIM_SPACE(modalObject.strUsername)length]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the username.") onController:self];
    }
    else  if(modalObject.strEmailAddress == nil || [modalObject.strEmailAddress isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the email address.") onController:self];
    }
    //    else if([emailTest evaluateWithObject:modalObject.strEmailAddress] == NO) {
    
    else if(![modalObject.strEmailAddress isValidEmail]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid email address.") onController:self];
    }
    else if(modalObject.strPswrd == nil || [modalObject.strPswrd isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the password.") onController:self];
    }
    else if(modalObject.strPswrd.length < 6 ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Password must be of atleast 6 characters.") onController:self];
    }
    else if(modalObject.strConfirmPswrd == nil || [modalObject.strConfirmPswrd isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the confirm password.") onController:self];
    }
    else if(![modalObject.strConfirmPswrd isEqualToString:modalObject.strPswrd]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Password and confirm password should be same.") onController:self];
    }
    else if (modalObject.strCategory == nil || [modalObject.strCategory isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please select the category.") onController:self];
    }
    else if(modalObject.strContact == nil || [modalObject.strContact isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the contact number.") onController:self];
    }
    else if (modalObject.strPrice == nil || [modalObject.strPrice isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the price / hour.") onController:self];
    }
    else if (!([modalObject.strPrice floatValue] >0)) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Price must be greater than zero.") onController:self];
    }
    else {
        [self requestDictForSignUp];
    }

}

-(void)countryNameAndPrefix {
    for (NSDictionary *dic in prefix.countriesList) {
        NSString *country = [NSString stringWithFormat:@"%@  -  %@",[dic objectForKeyNotNull:@"name" expectedObj:@""],[dic objectForKeyNotNull:@"dial_code" expectedObj:@""]];
        [countryArray addObject:country];
    }
    
}

#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 5) {
         DescriptionTableViewCell *cell = (DescriptionTableViewCell *)[self.signUpTableview dequeueReusableCellWithIdentifier:CellIdThird];
        cell.descriptionTextView.tag = indexPath.row+100 ;
        cell.descriptionTextView.placeholder = KNSLOCALIZEDSTRING(@"Description or type a #tag as per your skills without space");
        [cell.descriptionTextView setDelegate:self];
        return cell;
    } else if(indexPath.row == 7) {
        GenderTableViewCell *cell = (GenderTableViewCell *)[self.signUpTableview dequeueReusableCellWithIdentifier:CellIdSecond];
        
        cell.maleButton.tag = indexPath.row + 700;
        cell.femaleButton.tag = indexPath.row + 701;
        
        [cell.maleButton addTarget:self action:@selector(maleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.femaleButton addTarget:self action:@selector(femaleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // set button when arabic
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"]) {
            
            cell.maleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.femaleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }else if ([language isEqualToString:@"es"]) {
           _underLineLabelWidthConstraint.constant= 80;
            cell.maleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
            cell.maleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
            cell.femaleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            if (SCREEN_WIDTH == 320) {
                cell.maleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
                cell.maleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
                cell.femaleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
                cell.femaleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
            }
        }

        
        return cell;
    } else if (indexPath.row == 11)
    {
        CustomTableViewCell *cell = (CustomTableViewCell *)[self.signUpTableview dequeueReusableCellWithIdentifier:CellIdFourth];
        [cell.btnUpload setTitle:KNSLOCALIZEDSTRING(@"Upload your Exp Doc.") forState:UIControlStateNormal] ;
        [cell.btnUpload addTarget:self action:@selector(uploadDoc:) forControlEvents:UIControlEventTouchUpInside];
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"]) {
            cell.btnUpload.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
        if([cell.docImageView.image isEqual:[UIImage imageNamed:@"icon.png"]])
        {
            [cell.zoomOutButton setHidden:YES];
        }
        else {
            [cell.zoomOutButton setHidden:NO];
        }
            return cell;
    } else if (indexPath.row == 12)
    {
        ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.signUpTableview dequeueReusableCellWithIdentifier:CellIdFifth];
        cell.lblSampleWork.text = KNSLOCALIZEDSTRING(@"Sample of work:");
        // Initialization code
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(50.0, 50.0);
        //flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
       // [cell.collectionView setCollectionViewLayout:flowLayout];
        [cell.collectionView setBackgroundColor:[UIColor clearColor]];
        [cell.collectionView registerNib:[UINib nibWithNibName:@"SignUpCollectionViewCell" bundle:nil]                         forCellWithReuseIdentifier :@"SignUpCollectionViewCell"];
        [cell.collectionView setDelegate:self];
        [cell.collectionView setDataSource:self];
        [cell.btnLeftArrow addTarget:self action:@selector(button_leftAction:) forControlEvents:UIControlEventTouchUpInside];
      [cell.btnRightArrow addTarget:self action:@selector(button_rightAction:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    } else
    {
        SignUpTableViewCell *cell = (SignUpTableViewCell *)[self.signUpTableview dequeueReusableCellWithIdentifier:CellIdFirst];
        
        [cell.signUpTextField setSecureTextEntry:NO];
        [cell.signUpTextField setKeyboardType:UIKeyboardTypeDefault];
        [cell.signUpTextField setReturnKeyType:UIReturnKeyNext];
        [cell.signUpTextField setDelegate:self];
        [cell.signUpTextField setTextAlignment:NSTextAlignmentLeft];
        cell.pickerButton.hidden=YES;
        addPading(cell.signUpTextField);
        [cell.imageViewDrop setHidden:YES];
        [cell.pickerButton setTag:indexPath.row+10];
        [cell.pickerButton removeTarget:nil
                                            action:NULL
                                            forControlEvents:UIControlEventAllEvents];
        [cell.signUpTextField setUserInteractionEnabled:YES];
        [cell.signUpTextField setTag:indexPath.row+100];
        [cell.contactPrefixButton setHidden:YES];
        [cell.signUpTextField setHidden:NO];
        [cell.flagImageView setHidden:YES];
        cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"])        {
            cell.signUpTextField.textAlignment = NSTextAlignmentRight;
        }
        
        switch (indexPath.row) {
            case 0:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Username")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:modalObject.strUsername];
            }
                break;
                
            case 1:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Email Address")]];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.signUpTextField setKeyboardType:UIKeyboardTypeEmailAddress];
                [cell.signUpTextField setText:modalObject.strEmailAddress];
            }
                break;
                
            case 2:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Password")]];
                [cell.signUpTextField setSecureTextEntry:YES];
                [cell.signUpTextField setText:modalObject.strPswrd];
            }
                break;
                
            case 3:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Confirm Password")]];
                [cell.signUpTextField setSecureTextEntry:YES];
                [cell.signUpTextField setText:modalObject.strConfirmPswrd];
            }
                break;
                
            case 4:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Category")]];
                [cell.imageViewDrop setHidden:NO];
                UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                [cell.signUpTextField setRightViewMode:UITextFieldViewModeAlways];
                cell.signUpTextField.rightView = view;
                [cell.signUpTextField setText:modalObject.strCategory];
                [cell.pickerButton addTarget:self action:@selector(addCategoryPicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden=NO;
            }
                break;
                
            case 6:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Age")]];
                [cell.signUpTextField setText:modalObject.strAge];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.imageViewDrop setHidden:NO];
                [cell.pickerButton addTarget:self action:@selector(addAgePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden=NO;
            }
                break;
                
            case 8:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"State ,Country(Autofill By Location)")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:modalObject.strLocation];
                [cell.signUpTextField setUserInteractionEnabled:NO];

            }
                break;
                
            case 9:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Address")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:modalObject.strAddress];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.signUpTextField setUserInteractionEnabled:NO];

            }
                break;
                
            case 10: {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Contact No.")]];
                [cell.signUpTextField setText:modalObject.strContact];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                  [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
                [cell.contactPrefixButton setHidden:NO];
                [cell.flagImageView setHidden:NO];

                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 58)];
                cell.signUpTextField.leftView = paddingView;
                [cell.flagImageView setImage:modalObject.flagImage];
                cell.signUpTextField.leftViewMode = UITextFieldViewModeAlways;
                [cell.contactPrefixButton addTarget:self action:@selector(addContactPrefixPicker:) forControlEvents:UIControlEventTouchUpInside];
                if ([modalObject.strPhonePrefix length]) {
                    [cell.contactPrefixButton setTitle:modalObject.strPhonePrefix forState:UIControlStateNormal];
                }
               }
                break;
   
            case 13:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Price/Hour")]];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
                 [cell.signUpTextField setReturnKeyType:UIReturnKeyDone];
                [cell.signUpTextField setText:modalObject.strPrice];
            }
                break;
    
            case 14:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Language Known")]];
                UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                [cell.signUpTextField setRightViewMode:UITextFieldViewModeAlways];
                cell.signUpTextField.rightView = view;
                [cell.signUpTextField setText:modalObject.strLanguage];
                [cell.signUpTextField setHidden:YES];
                [cell.imageViewDrop setHidden:YES];
                [cell.pickerButton addTarget:self action:@selector(addLanguagePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden = YES;
            }
                break;
                
            case 15:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Distance Preference")]];
                [cell.signUpTextField setText:modalObject.strDistance];
                [cell.imageViewDrop setHidden:NO];
                [cell.pickerButton addTarget:self action:@selector(addDistancePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden = NO;
            }
                
                break;
    
            default:
                break;
        }
        return cell;
    }
}

-(void)button_leftAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.signUpTableview];
    NSIndexPath *indexPath = [self.signUpTableview indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.signUpTableview cellForRowAtIndexPath:indexPath];

    if (modalObject.sampleImageArray.count) {
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:YES];
    }
    
    
    
}
-(void)button_rightAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.signUpTableview];
    NSIndexPath *indexPath = [self.signUpTableview indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.signUpTableview cellForRowAtIndexPath:indexPath];
    if (modalObject.sampleImageArray.count) {
        NSInteger section=[cell.collectionView numberOfSections]-1;
        NSInteger item = [cell.collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        [cell.collectionView scrollToItemAtIndexPath:lastIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionRight
                                            animated:YES];
    }
    
    
   
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==5) {
        return 100.0f;
    } else if(indexPath.row == 7) {
        return 88.0f;
    } else if(indexPath.row == 11) {
        return 50.0f;
    } else if(indexPath.row == 12) {
        return 100.0f;
    }
    else if(indexPath.row == 14) {
        return 0.0f;
    }
    else {
        return 60.0f;
    }
}


-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)maleButtonAction:(UIButton *)sender  {
    UIButton *maleBtn = sender;
    UIButton *femaleBtn = APPBUTTON(maleBtn.tag + 1);
    
    [maleBtn setSelected:YES];
    [femaleBtn setSelected:NO];
    
     modalObject.strGender = @"male";
    
    [self.signUpTableview reloadData];
}

- (void)femaleButtonAction:(UIButton *)sender  {
    UIButton *femaleBtn = sender;
    UIButton *maleBtn = APPBUTTON(femaleBtn.tag - 1);
    
    [femaleBtn setSelected:YES];
    [maleBtn setSelected:NO];
    
    modalObject.strGender = @"female";

    [self.signUpTableview reloadData];
}

-(void)addContactPrefixPicker: (UIButton *) sender {
    [self.view endEditing:YES];
    
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithCountryFlags:^(NSMutableDictionary *selectedDict, NSInteger selectedIndex) {
        
        modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"dial_code"]];
        modalObject.flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[selectedDict valueForKey:@"code"]]];
        [self.signUpTableview reloadData];
    }];
}

-(void)addCategoryPicker : (UIButton *) sender {
     [self.view endEditing:YES];
    
    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithData:self.categoryArray andCompletionBlock:^(NSArray *updatedModals) {
        self.categoryArray = updatedModals;
        
        if (self.categoryArray.count && self.categoryArray[0]) {
//            CategoryModal *allCategory = self.categoryArray[0];
//
//            if (allCategory.selectionStatus) {
//                modalObject.strCategory = allCategory.categoryName;
//            } else {
            
                NSMutableArray *arrayCategoryName = [NSMutableArray array];
                
//                int index = 0;
            
                for (CategoryModal *category in self.categoryArray) {
                    
                    if (category.selectionStatus) {
                        [arrayCategoryName addObject:category.categoryName];
                    }
                    
//                    index++;
                }
                
                NSString *result = [arrayCategoryName componentsJoinedByString:@","];
                modalObject.strCategory = result;
//            }
        }
        
        [self.signUpTableview reloadData];
        
    }];
    
    
//        [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithOptions:self.categoryArray andSelectedDataInfo:selectedDataArray andCompletionBlock:^(NSMutableArray *selectedText, NSMutableArray *selectedIndex) {
//            selectedDataArray = selectedText;
//            NSString *result = [selectedDataArray componentsJoinedByString:@","];
//           modalObject.strCategory = result;
//           [self.signUpTableview reloadData];
//        }];
}

-(void)addAgePicker : (UIButton *) sender {
     [self.view endEditing:YES];
    //Alloc NSMutable Array
    NSMutableArray *ageArray = [[NSMutableArray alloc]init];
    for(int i =18 ; i<=100 ; ++i)
    {
        [ageArray   addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:ageArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strAge = KNSLOCALIZEDSTRING(selectedText);
        [self.signUpTableview reloadData];
    }];
}

-(void)addLanguagePicker : (UIButton *) sender {
     [self.view endEditing:YES];
      //Alloc NSMutable Array
     NSMutableArray *languageArray =[[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"English"),KNSLOCALIZEDSTRING(@"Spanish"),KNSLOCALIZEDSTRING(@"Arabic"),nil];
    
    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithOptions:languageArray andSelectedDataInfo:selectedLanguageArray andCompletionBlock:^(NSMutableArray *selectedText, NSMutableArray *selectedIndex) {
        selectedLanguageArray = selectedText;
        NSString *result = [selectedLanguageArray componentsJoinedByString:@", "];
        modalObject.strLanguage = result;
        [self.signUpTableview reloadData];
    }];
    
}

-(void)addDistancePicker : (UIButton *) sender {
    [self.view endEditing:YES];
    //Alloc NSMutable Array
    NSMutableArray *distanceArrray =[[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Km"), KNSLOCALIZEDSTRING(@"Miles"),nil];
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:distanceArrray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        modalObject.strDistance = KNSLOCALIZEDSTRING(selectedText);
        [self.signUpTableview reloadData];
    }];
}

-(void)uploadDoc:(UIButton *)btn {
    [self.view endEditing:YES];
    status  = @"Document";
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                           KNSLOCALIZEDSTRING(@"Take Photo"),
                           KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    [popup setTag:1];
    [popup showInView:self.view];
}

#pragma mark - UITextField delegate methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([string isEqualToString:@" "]) {
        UITextField *userNameTextField = APPTEXTFIELD(100);
        UITextField *AddressTextField = APPTEXTFIELD(109);
        UITextField *countryTextField = APPTEXTFIELD(108);

        
        if ((textField ==  userNameTextField && range.location != 0) || (textField == AddressTextField && range.location != 0)|| (textField == countryTextField && range.location != 0)) {
            return YES;
        }
        return NO;    }
    else{
        
        if (textField.tag == 100) {
            if(![string isEqualToString:@""]){
                if ([textFieldString length] >40) {
                    return NO;
                }else{
                    if ([self validateNameWithString:textFieldString]) {
                        return YES;
                    }
                    else{
//                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid username.") onController:self];
                        return NO;
                    }
                }
            }
            
            return YES;
        }
        if (textField.tag == 102) {
            if ([textFieldString length] > 15) {
                return NO;
            }else{
                return YES;
            }
        }
        else  if (textField.tag == 103) {
            if ([textFieldString length] > 15) {
                return NO;
            }else{
                return YES;
            }
        }
        else  if (textField.tag == 101) {
            if ([textFieldString length] > 60) {
                return NO;
            }else{
                if (![textFieldString isEqualToString:@""]) {
                    if ([self validateEmailCharacter:textFieldString] == NO) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter email in english.") onController:self];
                        return NO;
                    }else{
                        return YES;
                    }
                }
                return YES;
            }
        }

        else  if (textField.tag == 110) {

                if (![textFieldString isEqualToString:@""]) {
                    if ([self validatePhoneNoCharacter:textFieldString] == NO) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter phone no in english.") onController:self];
                        return NO;
                    }
                }
                return YES;
        }
        else  if (textField.tag == 108 || textField.tag == 109) {
            if(![string isEqualToString:@""]){
            if ([textFieldString length] > 60) {
                return NO;
            }else{
                return YES;
            }
                return YES;
            }
        }
        else  if (textField.tag == 113) {
            if ([textFieldString length] > 6) {
                return NO;
            }else{
                return YES;
            }
        }
    }
    return YES;
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 110) {
        [textField setInputAccessoryView:toolBarForNumberPad(self,KNSLOCALIZEDSTRING(@"Next"))];
    }else if (textField.tag  == 113){
        [textField setInputAccessoryView:toolBarForNumberPad(self,KNSLOCALIZEDSTRING(@"Done"))];
    }else {
        [textField setInputAccessoryView:nil];
    }
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender {
    
    if ([sender.title isEqualToString:@"Next"]) {
        UITextField *txtFld = (UITextField*)[self.view viewWithTag:110];
        [[self.view viewWithTag:txtFld.tag+3] becomeFirstResponder];
    }else {
        [self.view endEditing:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag==103)
    {
        UITextView *descriptionTextView=(UITextView *)[self.view viewWithTag:105];
        [descriptionTextView becomeFirstResponder];
        return NO;
    }
    else{
        if([textField returnKeyType] == UIReturnKeyNext) {
            [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
            return NO;
        }
        else{
            [textField resignFirstResponder];
        }
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if ([text isEqualToString:@" "]) {
        UITextView *descriptionTextView = (UITextView *)[self.view viewWithTag:105];
        
        if ((textView ==  descriptionTextView && range.location != 0)) {
            return YES;
        }
        return NO;
    }else if([text isEqualToString:@"\n"]) {
        //[textView resignFirstResponder];
        [[self.view viewWithTag:textView.tag+3] becomeFirstResponder];
        return NO;
    }else if (textView.tag == 105) {
        if(![text isEqualToString:@""]){
        if ([textFieldString length] > 100) {
            return NO;
        }else{
            return YES;
        }
    }
        return YES;
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [modalObject setStrDescription:textView.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
     [self.view layoutIfNeeded];
    switch (textField.tag) {
        case 100:
            [modalObject setStrUsername:textField.text];
            break;
        case 101:
            [modalObject setStrEmailAddress:textField.text];
            break;
        case 102:
            [modalObject setStrPswrd:textField.text];
            break;
        case 103:
            [modalObject setStrConfirmPswrd:textField.text];
            break;
        case 108:
            [modalObject setStrLocation:textField.text];
            break;
        case 109:
            [modalObject setStrAddress:textField.text];
            break;
        case 110:
            [modalObject setStrContact:textField.text];
            break;
        case 113:
            [modalObject setStrPrice:textField.text];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIButton Action Methods

- (IBAction)btnSignUp:(id)sender {
    [self.view endEditing:YES];
//    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z]+\\.[A-Za-z]{2,4}";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    [self isAllFieldVerified];
   }

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action For Email Validation

//- (BOOL) validateNameWithString:(NSString *)nameStr {
//    NSString *emailRegex = @"^[a-zA-Z\u0600-\u06FF\\s]+$";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    BOOL isValid = [emailTest evaluateWithObject:nameStr];
//    return isValid;
//}

- (BOOL) validateNameWithString:(NSString *)nameStr {
    //    NSString *emailRegex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
    
//    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
//    NSString *emailRegex;
//    if ([language isEqualToString:@"ar"]) {
//        emailRegex =@"^[a-zA-Z\u0600-\u06FF\\s]+$";
//    }else if ([language isEqualToString:@"es"]) {
//        emailRegex =@"[À-ÿA-Za-z]+([ '-][a-zA-Z]+)*$";
//    }else{
//        emailRegex =@"^[a-zA-Z\\s]+$";
//    }
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    NSString *emailRegex;
    if ([language isEqualToString:@"ar"]) {
        emailRegex =@"^[a-zA-Z\u0600-\u06FF\\s]+$";
    }else if ([language isEqualToString:@"es"]) {
        emailRegex =@"[À-ÿA-Za-z]+([ '-][a-zA-Z]+)*$";
    }else{
        emailRegex =@"^[a-zA-Z\\s]+$";
    }
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:nameStr];
    return isValid;
}

- (BOOL)validateEmailCharacter:(NSString *)nameStr {
    //    NSString *emailRegex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
    NSString *emailRegex =@"^[0-9a-zA-Z!-~]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:nameStr];
    return isValid;
}

-(BOOL)validatePhoneNoCharacter:(NSString *)phoneNoStr{
    NSString *emailRegex =@"^[0-9]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:phoneNoStr];
    return isValid;
}

- (IBAction)btnChoose:(id)sender {
    [self.view endEditing:YES];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                            KNSLOCALIZEDSTRING(@"Take Photo"),
                            KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    [popup setTag:1];
    [popup showInView:self.view];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Device has no camera.") onController:[APPDELEGATE navController]];
//                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                      message:KNSLOCALIZEDSTRING(@"Device has no camera.")
//                                                                     delegate:nil
//                                                            cancelButtonTitle:KNSLOCALIZEDSTRING(@"OK")
//                                                            otherButtonTitles: nil];
//                [myAlertView show];
            }else
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:NULL];
            }
            break;
        case 1:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        }break;
        case 2: {
            status = @"Profile";
        }break;
        default:
            break;
    }
}


#pragma mark - UICollectionView Delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [imageArray count] + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SignUpCollectionViewCell *cell =(SignUpCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"SignUpCollectionViewCell" forIndexPath:indexPath];
    [cell.deleteButton setHidden:NO];
    [cell.zoomButton setHidden:NO];

    cell.deleteButton.tag = indexPath.row;
    if (indexPath.row == 0) {
        UIImage *addMoreImg = [UIImage imageNamed:@"more"] ;
        addMoreImg.accessibilityIdentifier = @"More button";
        cell.sampleImageView.image = addMoreImg;
        [cell.deleteButton setHidden:YES];
        [cell.zoomButton setHidden:YES];
    }else {
        cell.sampleImageView.image = [imageArray objectAtIndex:indexPath.row-1];
        [cell.deleteButton addTarget:self action:@selector(deleteSampleImage:) forControlEvents:UIControlEventTouchUpInside];
    }
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    SignUpCollectionViewCell * cell = (SignUpCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([cell.sampleImageView.image.accessibilityIdentifier isEqualToString:@"More button"]) {
        status = @"Sample";
                UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                               KNSLOCALIZEDSTRING(@"Take Photo"),
                          KNSLOCALIZEDSTRING(@"Choose Photo"),
                                nil];
        [popup setTag:1];
        [popup showInView:self.view];
    }
}


-(void)deleteSampleImage:(UIButton *)sender {
    
    [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Do you want to delete this sample image?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK"),KNSLOCALIZEDSTRING(@"Cancel")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
        if(index == 0)
        {
            ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.signUpTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:12 inSection:0]];
            [imageArray removeObjectAtIndex:sender.tag-1];
            [cell.collectionView reloadData];
        }
    }];
   
}

#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    if([status isEqualToString:@"Sample"])  {
        status = @"Profile";
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.signUpTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:12 inSection:0]];
           image.accessibilityIdentifier = @"Other";
       [imageArray addObject:image];
            [modalObject.sampleImageArray addObject:[image getBase64String]];

     [picker dismissViewControllerAnimated:YES completion:^{
         [cell.collectionView reloadData];
     }];
    } else if ([status isEqualToString:@"Document"]) {
        status = @"Profile";
        CustomTableViewCell *docCell = (CustomTableViewCell *)[self.signUpTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]];

        [docCell.docImageView setImage:image];
        modalObject.strDocumentUpload = [image getBase64String];

        [picker dismissViewControllerAnimated:YES completion:nil];
        [self.signUpTableview reloadData];
    } else  {
        [self.btnChoose setImage:image forState:UIControlStateNormal];

        //[self.btnChoose setBackgroundImage:image forState:UIControlStateNormal];
        modalObject.strUpload = [image getBase64String];
        NSURL *imagePath = [editingInfo objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSString *imageName = [imagePath lastPathComponent];
        NSLog(@"%@",imageName);
        modalObject.strImageType = imageName;
        [self.cameraImageView setHidden:YES];
       [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForSignUp {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:modalObject.strUsername forKey:pUserName];
    [requestDict setValue:modalObject.strPswrd forKey:pPassword];
    [requestDict setValue:modalObject.strEmailAddress forKey:pEmailID];
    [requestDict setValue:modalObject.strAge forKey:pAge];
    [requestDict setValue:modalObject.strAddress forKey:pAddress];
    [requestDict setValue:modalObject.strContact forKey:pContactNumber];
    [requestDict setValue:([modalObject.strDistance length] ? modalObject.strDistance : KNSLOCALIZEDSTRING(@"Km")) forKey:pDistancePreference];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:modalObject.strGender forKey:pGender];
    [requestDict setValue:modalObject.strLanguage forKey:pLanguage];
    [requestDict setValue:modalObject.strCategory forKey:pCategory];
    [requestDict setValue:modalObject.strPrice forKey:pPrice];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    
    [requestDict setValue:modalObject.strUpload forKey:pProfileImage];
//    [requestDict setValue:modalObject.strImageType.length?modalObject.strImageType:@"" forKey:@"image_type"];
    [requestDict setValue:([TRIM_SPACE(modalObject.strDescription) length])?modalObject.strDescription:[NSString string] forKey:pDescription];
    
    NSMutableArray *subString = [AppUtilityFile getSubstringInArrayFromString:modalObject.strDescription];
    [requestDict setValue:[subString count]?subString:[NSArray array] forKey:pDescriptionArray];
    
    [requestDict setValue:([modalObject.strDocumentUpload length])?modalObject.strDocumentUpload:[NSString string] forKey:pExperienceDocument];
    [requestDict setValue:modalObject.sampleImageArray forKey:pImage];
    
    NSMutableArray *stateAndCountry = [AppUtilityFile getSubstringBeforeAndAfterTheFirstComma:modalObject.strLocation];
    [requestDict setValue:([stateAndCountry count] >= 1)?[stateAndCountry firstObject]:[NSString string] forKey:pState];
    [requestDict setValue:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string] forKey:pCountry];
    
    [self.phonePrefix getPhonePrefixForCountry:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string]];
    
    [requestDict setValue:([modalObject.strPhonePrefix length])?modalObject.strPhonePrefix:@"+1" forKey:pCountryCode];
    
    
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/signup" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [NSUSERDEFAULT setValue:[result objectForKeyNotNull:pUserId expectedObj:@""] forKey:@"userID"];
            //NSString *OTPNumber = [response objectForKeyNotNull:pOTP expectedObj:@""];
            
            NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
            
            [userInfoDict setValue:modalObject.strEmailAddress forKey:@"userEmail"];
            [userInfoDict setValue:modalObject.strPswrd forKey:@"userPassword"];
            [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
            [userInfoDict setValue:@"NO" forKey:@"isRemember"];
            [userInfoDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
            [userInfoDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"user_icon" forKey:@"profileimage" ];
            
            [NSUSERDEFAULT setValue:userInfoDict forKey:@"ServiceUserInfoDictionary"];
            [NSUSERDEFAULT synchronize];
            
            UIImageView *imgView = [[UIImageView alloc] init];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[userInfoDict valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];

            MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
            registrationObj.isComingFromLogin = NO;
            registrationObj.otpNumber = [result objectForKeyNotNull:pOTP expectedObj:@""];
            registrationObj.modalObject = modalObject;
            [self.navigationController pushViewController:registrationObj animated:YES];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
    
}


@end



