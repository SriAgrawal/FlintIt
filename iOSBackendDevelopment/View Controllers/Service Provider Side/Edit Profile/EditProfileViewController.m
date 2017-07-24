//
//  EditProfileViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 12/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"

static NSString *CellIdFirst = @"SignUpTableViewCell";
static NSString *CellIdSecond = @"GenderTableViewCell";
static NSString *CellIdThird = @"DescriptionTableViewCell";
static NSString *CellIdFourth = @"CustomTableViewCell";
static NSString *CellIdFifth = @"ScrollTableViewCell";
static NSString *cellIdentifier = @"SignUpCollectionViewCell";

@interface EditProfileViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,CountryNameAndPhonePrefixDelegate>
{
    NSString *status;
    UIImage *docImage;
    CountryNamesAndPhoneNumberPrefix *prefix;
    NSMutableArray *countryArray,*selectedDataArray,*selectedLanguageArray;
    LoginVC *login;
}

@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraImageView;

@property (weak, nonatomic) IBOutlet UIButton *userImageButton;

@property (weak, nonatomic) IBOutlet UITableView *editProfileTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblEditProfile;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (strong, nonatomic) CountryNamesAndPhoneNumberPrefix *phonePrefix;
@property (nonatomic, strong) NSArray *categoryArray;


@end

@implementation EditProfileViewController

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
    // NSLog(@"responseString %@ ",[[responseString JSONValue] valueForKey:@"results"]);
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
                 
                 self.modalObject.strLocation = [NSString stringWithFormat:@"%@, %@",mark.administrativeArea,mark.country];
                 self.modalObject.strAddress = [NSString stringWithFormat:@"%@, %@",mark.locality,mark.subLocality];

                 [self.editProfileTableView reloadData];
             }
         }
     }];
}

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSOperationQueue *locationAndLongituteQueue = [NSOperationQueue new];
    [locationAndLongituteQueue addOperationWithBlock:^{
        [self getAdrressFromLatLong:[[APPDELEGATE latitude] floatValue] lon:[[APPDELEGATE longitude] floatValue]];
    }];

    [self initialSetup];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods
-(void)initialSetup {
    _lblEditProfile.text = KNSLOCALIZEDSTRING(@"Edit Profile");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    
    if ([language isEqualToString:@"ar"])
    {
        [self.btnEdit setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Alloc and set Delegate CountryNamesAndPhoneNumberPrefix
    self.phonePrefix = [[CountryNamesAndPhoneNumberPrefix alloc]initWithDelegate:self];
    
    //Register the tableView Cell
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"SignUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"SignUpTableViewCell"];
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"DescriptionTableViewCell" bundle:nil] forCellReuseIdentifier:@"DescriptionTableViewCell"];
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"GenderTableViewCell" bundle:nil] forCellReuseIdentifier:@"GenderTableViewCell"];
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomTableViewCell"];
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"ScrollTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScrollTableViewCell"];

    //Set Table View Header & Footer
    [self.editProfileTableView setTableHeaderView:self.headerView];
    [self.editProfileTableView setTableFooterView:self.footerView];
    
    //Set Layout of ImageView
    self.userImageButton.layer.cornerRadius = 50.0;
    [self.userImageButton setClipsToBounds:YES];
    [self.cameraImageView.layer setCornerRadius:20];
    
    //Bounce table vertical if required
    [self.editProfileTableView setAlwaysBounceVertical:NO];
    
    //Alloc Modal Class Object
    if (!self.modalObject) {
        self.modalObject = [[UserInfo alloc]init];
        self.modalObject.sampleImageArrayURL = [NSMutableArray array];
        self.modalObject.sampleImageArray = [NSMutableArray array];
        
        [self requestDictForGettingProfileDetail];
    }else {
        [self.userImageButton sd_setBackgroundImageWithURL:self.modalObject.strUploadURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon"]];
        
        if (self.modalObject.strUploadURL) {
            [self.cameraImageView setHidden:YES];
        }
        
        [self getCountryFlagWithCountryDileCode];
    }
    
    //imageArray = [[NSMutableArray alloc]init];
    //[imageArray addObjectsFromArray:self.modalObject.sampleImageArrayURL];
   
    status = @"Profile";
    
    selectedDataArray = [NSMutableArray array];
    selectedLanguageArray = [NSMutableArray array];
    
    prefix = [[CountryNamesAndPhoneNumberPrefix alloc]init];
    countryArray = [NSMutableArray array];
    
    if (self.isComingFromSocialLogin)
        self.btnBack.hidden = YES;
    
    [self countryNameAndPrefix];
    self.categoryArray = [self getCategories];
}

-(void)getCountryFlagWithCountryDileCode{
    
    BDVCountryNameAndCode *countryNameAndCode = [[BDVCountryNameAndCode alloc] init];
    NSString * countryCode = [countryNameAndCode getCountryCodeForDialCode:self.modalObject.strPhonePrefix];
    NSString *imageName = [NSString stringWithFormat:@"CountryPicker.bundle/%@",countryCode];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    UIImage *image = [UIImage imageNamed:imageName];
    self.modalObject.flagImage = image;
}

- (NSArray *)getCategories {
    //Alloc NSMutable Array
    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Bodyguards"),KNSLOCALIZEDSTRING(@"Chefs"),KNSLOCALIZEDSTRING(@"Clean Worker"),KNSLOCALIZEDSTRING(@"Consultation"),KNSLOCALIZEDSTRING(@"Gardener"),KNSLOCALIZEDSTRING(@"Decoration"),KNSLOCALIZEDSTRING(@"Moving"),KNSLOCALIZEDSTRING(@"Painter"),KNSLOCALIZEDSTRING(@"Plumber"),KNSLOCALIZEDSTRING(@"Towing"),KNSLOCALIZEDSTRING(@"Carpenter"),KNSLOCALIZEDSTRING(@"IT"),KNSLOCALIZEDSTRING(@"Exterminator"),KNSLOCALIZEDSTRING(@"Electrician"),KNSLOCALIZEDSTRING(@"Mechanic"),KNSLOCALIZEDSTRING(@"Health"),KNSLOCALIZEDSTRING(@"Beauty"),KNSLOCALIZEDSTRING(@"Tutor"),KNSLOCALIZEDSTRING(@"Tailor"),KNSLOCALIZEDSTRING(@"Snow Shoveling"),KNSLOCALIZEDSTRING(@"Car wash"),KNSLOCALIZEDSTRING(@"Photographer"),KNSLOCALIZEDSTRING(@"Fun & Party"),KNSLOCALIZEDSTRING(@"Black Smithy"),KNSLOCALIZEDSTRING(@"Artist"),KNSLOCALIZEDSTRING(@"Air Cooling"),nil];
    
    NSMutableArray *arrrayCategory = [NSMutableArray array];
    
    NSMutableArray * arrayOfSelection = [NSMutableArray new];
    NSArray * arrayOfSelectionStr = [NSArray new];

    if (self.modalObject.strCategory.length) {
//        arrayOfSelection = [self.modalObject.strCategory componentsSeparatedByString:@","];
        arrayOfSelectionStr = [self.modalObject.strCategory componentsSeparatedByString:@","];

        for (NSString * str in arrayOfSelectionStr) {
            [arrayOfSelection addObject:KNSLOCALIZEDSTRING(str)];
        }
    }

    for (NSString *categoryName in categoryArray) {
        
        CategoryModal *category = [[CategoryModal alloc] init];
        category.categoryName = categoryName;
        // set initial selection status
        
        if([arrayOfSelection containsObject:categoryName]){
            category.selectionStatus = true;
        }else{
            category.selectionStatus = false;
        }
        
        [arrrayCategory addObject:category];
    }
    
    return [arrrayCategory mutableCopy];
}

-(void)isAllFieldsVerified {

    if(![TRIM_SPACE(self.modalObject.strUpload) length]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please select the user image.") onController:self];
    }
    else if(self.modalObject.strUsername == nil || [self.modalObject.strUsername isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the username.") onController:self];
    }
    else if ([self validateNameWithString:self.modalObject.strUsername] == NO) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid username.") onController:self];
    }
    else if(![TRIM_SPACE(self.modalObject.strUsername)length]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the username.") onController:self];
    }
    else  if(self.modalObject.strEmailAddress == nil || [self.modalObject.strEmailAddress isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the email address.") onController:self];
    }
    else if(![_modalObject.strEmailAddress isValidEmail]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid email address.") onController:self];
    }
    else if (self.modalObject.strCategory == nil || [self.modalObject.strCategory isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please select the category.") onController:self];
    }
    else if(self.modalObject.strContact == nil || [self.modalObject.strContact isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the contact number.") onController:self];
    }
    else if (self.modalObject.strPrice == nil || [self.modalObject.strPrice isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the price / hour.") onController:self];
    }
    else if (!([self.modalObject.strPrice floatValue] >0)) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Price must be greater than zero.") onController:self];
    }
    else {
        [self requestDictForEditProfile];
    }

}
//else if(![modalObject.strLocation containsString:@","]) {
//    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the location in full format.") onController:self];
//}
-(void)countryNameAndPrefix {
    for (NSDictionary *dic in prefix.countriesList) {
        NSString *country = [NSString stringWithFormat:@"%@  -  %@",[dic objectForKeyNotNull:@"name" expectedObj:@""],[dic objectForKeyNotNull:@"dial_code" expectedObj:@""]];
        [countryArray addObject:country];
    }
    
}

#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 3) {
        DescriptionTableViewCell *cell = (DescriptionTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdThird];
        cell.descriptionTextView.tag = indexPath.row+100 ;
       // cell.descriptionTextView.textColor = [UIColor lightGrayColor];
        [cell.descriptionTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];
        [cell.descriptionTextView setPlaceholder:KNSLOCALIZEDSTRING(@"Description or type a #tag as per your skills without space")];
        [cell.descriptionTextView setText:KNSLOCALIZEDSTRING(self.modalObject.strDescription)];
        
        [cell.descriptionTextView setDelegate:self];
        return cell;
    }
    
    else if(indexPath.row == 5)
    {
        GenderTableViewCell *cell = (GenderTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdSecond];
        
        cell.maleButton.tag = indexPath.row + 500;
        cell.femaleButton.tag = indexPath.row + 501;
        
        [cell.maleButton addTarget:self action:@selector(maleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.femaleButton addTarget:self action:@selector(femaleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.modalObject.strGender isEqualToString:@"male"]) {
            [cell.maleButton setSelected:YES];
            [cell.femaleButton setSelected:NO];
        }else if ([self.modalObject.strGender isEqualToString:@"female"]) {
            [cell.maleButton setSelected:NO];
            [cell.femaleButton setSelected:YES];
        }
        
        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        
        if ([language isEqualToString:@"ar"]){
            [cell.maleButton setTitleEdgeInsets:UIEdgeInsetsZero];
            [cell.femaleButton setTitleEdgeInsets:UIEdgeInsetsZero];

        }else if ([language isEqualToString:@"es"]) {
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
    }
    else if (indexPath.row == 9)
    {
        CustomTableViewCell *cell = (CustomTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdFourth];
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
        if(self.modalObject.strDocumentUploadURL){
            if(docImage)
                [cell.docImageView setImage:docImage];
            else
             [cell.docImageView sd_setImageWithURL:self.modalObject.strDocumentUploadURL placeholderImage:[UIImage imageNamed:@"icon.png"]];
        }
        else {
            [cell.docImageView setImage:docImage];
        }
        return cell;
    }
    else if (indexPath.row == 10)
    {
        ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdFifth];
        // Initialization code
        [cell.lblSampleWork setText:KNSLOCALIZEDSTRING(@"Sample of work:")];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(50.0, 50.0);
        flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        [cell.collectionView setCollectionViewLayout:flowLayout];
        [cell.collectionView setBackgroundColor:[UIColor clearColor]];
        [cell.collectionView registerNib:[UINib nibWithNibName:@"SignUpCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SignUpCollectionViewCell"];
        [cell.collectionView setDelegate:self];
        [cell.collectionView setDataSource:self];
        [cell.btnLeftArrow addTarget:self action:@selector(button_leftAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnRightArrow addTarget:self action:@selector(button_rightAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        SignUpTableViewCell *cell = (SignUpTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdFirst];
        [cell.flagImageView setHidden:YES];
        [cell.signUpTextField setUserInteractionEnabled:YES];
        [cell.signUpTextField setSecureTextEntry:NO];
        [cell.signUpTextField setKeyboardType:UIKeyboardTypeDefault];
        [cell.signUpTextField setReturnKeyType:UIReturnKeyNext];
        [cell.signUpTextField setDelegate:self];
        [cell.signUpTextField setTextAlignment:NSTextAlignmentLeft];
        cell.pickerButton.hidden=YES;
        addPading(cell.signUpTextField);
        [cell.signUpTextField setTag:indexPath.row+100];
        [cell.imageViewDrop setHidden:YES];
        [cell.pickerButton removeTarget:nil
                                 action:NULL
                       forControlEvents:UIControlEventAllEvents];
        [cell.signUpTextField setUserInteractionEnabled:YES];
        [cell.contactPrefixButton setHidden:YES];
        cell.signUpTextField.rightView = nil;
        [cell.signUpTextField setHidden:NO];
        cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        
        if ([language isEqualToString:@"ar"]){
            [cell.signUpTextField setTextAlignment:NSTextAlignmentRight];
        }
          [cell.signUpTextField setUserInteractionEnabled:YES];
        switch (indexPath.row) {
            case 0:
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Username")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:self.modalObject.strUsername];
                break;
                
            case 1:
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Email Address")]];
                if ([NSUSERDEFAULT boolForKey:@"isSocialLogin"]) {
                    [cell.signUpTextField setUserInteractionEnabled:NO];
                }
                 [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.signUpTextField setKeyboardType:UIKeyboardTypeEmailAddress];
                [cell.signUpTextField setText:self.modalObject.strEmailAddress];
//                [cell.signUpTextField setUserInteractionEnabled:NO];

                break;
                
            case 2: {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Category")]];
                [cell.imageViewDrop setHidden:NO];
                
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                cell.signUpTextField.rightView = paddingView;
                cell.signUpTextField.rightViewMode = UITextFieldViewModeAlways;
                
//                [cell.signUpTextField setText:self.modalObject.strCategory];
                
                // CHANGE AS PER LOCALISATION
                NSArray * arrayOfCat = [self.modalObject.strCategory componentsSeparatedByString:@","];
                NSMutableArray * arrayOfLocalisedStr = [NSMutableArray new];
                for (NSString * str in arrayOfCat) {
                    [arrayOfLocalisedStr addObject:KNSLOCALIZEDSTRING(str)];
                }
                NSString * strOfCat =  [arrayOfLocalisedStr componentsJoinedByString:@","];
                [cell.signUpTextField setText:strOfCat];


                [cell.pickerButton addTarget:self action:@selector(addCategoryPicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden= NO;
                
                break;
            }
                
            case 4:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Age")]];
                [cell.signUpTextField setText:self.modalObject.strAge];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.imageViewDrop setHidden:NO];
                [cell.pickerButton addTarget:self action:@selector(addAgePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden = NO;
                break;
            }
                
            case 6:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"State ,Country(Autofill By Location)")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:self.modalObject.strLocation];
                NSLog(@"State %ld",(long)cell.signUpTextField.tag);
                [cell.signUpTextField setUserInteractionEnabled:NO];
                break;
            }
                
            case 7:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Address")]];
                cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [cell.signUpTextField setText:self.modalObject.strAddress];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                NSLog(@"State %ld",(long)cell.signUpTextField.tag);
                [cell.signUpTextField setUserInteractionEnabled:NO];

                break;
            }
                
            case 8: {
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Contact No.")]];
                [cell.signUpTextField setText:self.modalObject.strContact];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
                [cell.contactPrefixButton setHidden:NO];
                [cell.flagImageView setHidden:NO];
                [cell.flagImageView setImage:self.modalObject.flagImage];
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 58)];
                cell.signUpTextField.leftView = paddingView;
                cell.signUpTextField.leftViewMode = UITextFieldViewModeAlways;
                [cell.contactPrefixButton addTarget:self action:@selector(addContactPrefixPicker:) forControlEvents:UIControlEventTouchUpInside];
                if ([self.modalObject.strPhonePrefix length]) {
                    [cell.contactPrefixButton setTitle:self.modalObject.strPhonePrefix forState:UIControlStateNormal];
                }
               }
                break;
                
            case 11:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Price/Hour")]];
                [cell.signUpTextField setText:self.modalObject.strPrice];
                [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
                [cell.imageViewDrop setHidden:YES];
                [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
                 [cell.signUpTextField setReturnKeyType:UIReturnKeyDone];
                NSLog(@"State %ld",(long)cell.signUpTextField.tag);

                break;
            }
                
            case 12:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Language Known")]];
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                cell.signUpTextField.rightView = paddingView;
                cell.signUpTextField.rightViewMode = UITextFieldViewModeAlways;
                [cell.signUpTextField setText:self.modalObject.strLanguage];
                [cell.signUpTextField setHidden:YES];
                [cell.imageViewDrop setHidden:YES];
                [cell.pickerButton addTarget:self action:@selector(addLanguagePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden = YES;

                break;
            }
            case 13:{
                [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Distance Preference")]];
                [cell.signUpTextField setText:self.modalObject.strDistance];
                [cell.imageViewDrop setHidden:NO];
                [cell.pickerButton addTarget:self action:@selector(addDistancePicker:) forControlEvents:UIControlEventTouchUpInside];
                cell.pickerButton.hidden=NO;
                break;
            }
                
                
            default:
                break;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==3) {
        return 100.0f;
    }
    else if(indexPath.row == 5) {
        return 90.0f;
    }
    else if(indexPath.row == 9) {
        return 50.0f;
    }
    else if(indexPath.row == 10) {
        return 100.0f;
    }
    else if(indexPath.row == 12) {
        return 0.0f;
    }
    else
    {
        return 60.0f;
    }

}

-(void)uploadDoc:(UIButton *)btn {
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
    
    if([string isEqualToString:@" "])
    {
        if ((textField.tag == 108 && range.location != 0) || (textField.tag == 100 && range.location != 0) || (textField.tag == 106 && range.location != 0) || (textField.tag == 107 && range.location != 0)) {
            return YES;
        }
        return NO;
    }
    else if (textField.tag == 108) {

            if (![textFieldString isEqualToString:@""]) {
                if ([self validatePhoneNoCharacter:textFieldString] == NO) {
                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter phone no in english.") onController:self];
                    return NO;
                }
            }
            return YES;
    }
    else if (textField.tag == 101){
        {
            if ([textFieldString length]> 60) {
                return NO;
            }
            else{
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
    }else if (textField.tag == 100) {
        if(![string isEqualToString:@""]){
            if ([textFieldString length] >40) {
                return NO;
            }else{
                if ([self validateNameWithString:textFieldString]) {
                    return YES;
                }
                else{
//                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid username.") onController:self];
                    return NO;
                }
            }
        }
        
        return YES;
    }
    else  if (textField.tag == 106 || textField.tag == 107) {
        if(![string isEqualToString:@""]){
        if ([textFieldString length] > 60) {
            return NO;
        }else{
            return YES;
        }
            return YES;
        }
    }
    else  if (textField.tag == 111) {
        if ([textFieldString length] > 6) {
            return NO;
        }else{
            return YES;
        }
    }

    
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag==101)
    {
        UITextView *descriptionTextView=(UITextView *)[self.view viewWithTag:103];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 108) {
        [textField setInputAccessoryView:toolBarForNumberPad(self,KNSLOCALIZEDSTRING(@"Next"))];
    }else if (textField.tag == 111) {
        [textField setInputAccessoryView:toolBarForNumberPad(self,KNSLOCALIZEDSTRING(@"Done"))];
    }else {
        [textField setInputAccessoryView:nil];
    }
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Next"]) {
        UITextField *txtFld = (UITextField*)[self.view viewWithTag:108];
        [[self.view viewWithTag:txtFld.tag+3] becomeFirstResponder];
    }else {
        [self.view endEditing:YES];
    }
}

#pragma mark - UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if ([text isEqualToString:@" "]) {
        UITextView *descriptionTextView = (UITextView *)[self.view viewWithTag:103];
        if ((textView ==  descriptionTextView && range.location != 0)) {
            return YES;
        }
        return NO;
    }
    else if([text isEqualToString:@"\n"]) {
        //[textView resignFirstResponder];
         [[self.view viewWithTag:textView.tag+3] becomeFirstResponder];
        return NO;
    }else if (textView.tag == 103) {
        if(![text isEqualToString:@""]){
        if ([textFieldString length] > 100) {
            return NO;
        }else{
            return YES;
        }
            return YES;
        }
    }
    
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.view layoutIfNeeded];
    switch (textField.tag) {
        case 100:
            [self.modalObject setStrUsername:textField.text];
            break;
        case 101:
            [self.modalObject setStrEmailAddress:textField.text];
            break;
        case 106:
            [self.modalObject setStrLocation:textField.text];
            break;
        case 107:
            [self.modalObject setStrAddress:textField.text];
            break;
        case 108:
            [self.modalObject setStrContact:textField.text];
            break;
        case 111:
            [self.modalObject setStrPrice:textField.text];
            break;
            
        default:
            break;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.view layoutIfNeeded];
    self.modalObject.strDescription = textView.text;
}

-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)maleButtonAction:(UIButton *)sender  {
    UIButton *maleBtn = sender;
    UIButton *femaleBtn = APPBUTTON(maleBtn.tag + 1);
    
    [maleBtn setSelected:YES];
    [femaleBtn setSelected:NO];
    
    self.modalObject.strGender = @"male";
    
    [self.editProfileTableView reloadData];
}

- (void)femaleButtonAction:(UIButton *)sender  {
    UIButton *femaleBtn = sender;
    UIButton *maleBtn = APPBUTTON(femaleBtn.tag - 1);
    
    [femaleBtn setSelected:YES];
    [maleBtn setSelected:NO];
    
    self.modalObject.strGender = @"female";

    [self.editProfileTableView reloadData];
}

-(void)addContactPrefixPicker: (UIButton *) sender {
    [self.view endEditing:YES];
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithCountryFlags:^(NSMutableDictionary *selectedDict, NSInteger selectedIndex) {
        
        self.modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"dial_code"]];
        self.modalObject.flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[selectedDict valueForKey:@"code"]]];
        [self.editProfileTableView reloadData];
    }];
}


-(void)addCategoryPicker : (id) sender {
    [self.view endEditing:YES];
    //Alloc NSMutable Array
//    NSMutableArray *categoryArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"All"),KNSLOCALIZEDSTRING(@"Bodygaurds"),KNSLOCALIZEDSTRING(@"Chefs"),KNSLOCALIZEDSTRING(@"Clean Worker"),KNSLOCALIZEDSTRING(@"Consultation"),KNSLOCALIZEDSTRING(@"Gardener"),KNSLOCALIZEDSTRING(@"Decoration"),KNSLOCALIZEDSTRING(@"Moving"),KNSLOCALIZEDSTRING(@"Painter"),KNSLOCALIZEDSTRING(@"Plumber"),KNSLOCALIZEDSTRING(@"Towing"),KNSLOCALIZEDSTRING(@"Carpenter"),KNSLOCALIZEDSTRING(@"IT"),KNSLOCALIZEDSTRING(@"Exterminator"),KNSLOCALIZEDSTRING(@"Electrician"),KNSLOCALIZEDSTRING(@"Mechanic"),KNSLOCALIZEDSTRING(@"Health"),KNSLOCALIZEDSTRING(@"Beauty"),KNSLOCALIZEDSTRING(@"Tutor"),KNSLOCALIZEDSTRING(@"Tailor"),KNSLOCALIZEDSTRING(@"Snow Shoveling"),KNSLOCALIZEDSTRING(@"Car wash"),KNSLOCALIZEDSTRING(@"Photographer"),KNSLOCALIZEDSTRING(@"Fun & Party"),KNSLOCALIZEDSTRING(@"Black Smithy"),KNSLOCALIZEDSTRING(@"Artist"),KNSLOCALIZEDSTRING(@"Air Cooling"),nil];
//
//    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithOptions:categoryArray andSelectedDataInfo:selectedDataArray andCompletionBlock:^(NSMutableArray *selectedText, NSMutableArray *selectedIndex) {
//        selectedDataArray = selectedText;
//        NSString *result = [selectedDataArray componentsJoinedByString:@","];
//        self.modalObject.strCategory = result;
//        [self.editProfileTableView reloadData];
//    }];
    
//    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithData:self.categoryArray andCompletionBlock:^(NSArray *updatedModals) {
//        self.categoryArray = updatedModals;
//        
//        if (self.categoryArray.count && self.categoryArray[0]) {
//            CategoryModal *allCategory = self.categoryArray[0];
//            
//            if (allCategory.selectionStatus) {
//                _modalObject.strCategory = allCategory.categoryName;
//            } else {
//                
//                NSMutableArray *arrayCategoryName = [NSMutableArray array];
//                
//                int index = 0;
//                
//                for (CategoryModal *category in self.categoryArray) {
//                    
//                    if (index && category.selectionStatus) {
//                        [arrayCategoryName addObject:category.categoryName];
//                    }
//                    
//                    index++;
//                }
//                
//                NSString *result = [arrayCategoryName componentsJoinedByString:@","];
//                _modalObject.strCategory = result;
//            }
//        }
//        
//        [self.editProfileTableView reloadData];
//        
//    }];
//    
//    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithData:self.categoryArray andCompletionBlock:^(NSArray *updatedModals) {
//        self.categoryArray = updatedModals;
//        
//        if (self.categoryArray.count && self.categoryArray[0]) {
// 
//            NSMutableArray *arrayCategoryName = [NSMutableArray array];
//            
//            for (CategoryModal *category in self.categoryArray) {
//                
//                if (category.selectionStatus) {
//                    [arrayCategoryName addObject:category.categoryName];
//                }
//                
//            }
//            
//            NSString *result = [arrayCategoryName componentsJoinedByString:@","];
//            _modalObject.strCategory = result;
//        }
//        
//        [self.editProfileTableView reloadData];
//        
//    }];
    
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
            _modalObject.strCategory = result;
            //            }
        }
        
        [self.editProfileTableView reloadData];
        
    }];
}

-(void)addAgePicker : (id) sender {
    [self.view endEditing:YES];
    //Alloc NSMutable Array
    NSMutableArray *ageArray = [[NSMutableArray alloc]init];
    for(int i =18 ; i<=100 ; ++i)
    {
        [ageArray   addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:ageArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        if (selectedText.length) {
            self.modalObject.strAge = KNSLOCALIZEDSTRING(selectedText);
        }
        [self.editProfileTableView reloadData];
    }];
}

-(void)addLanguagePicker : (id) sender {
    [self.view endEditing:YES];
    //Alloc NSMutable Array
    NSMutableArray *languageArray =[[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"English"), KNSLOCALIZEDSTRING(@"Spanish"),KNSLOCALIZEDSTRING(@"Arabic"),nil];
    [[TableViewWithMultipleSelection sharedTableViewWithMultipleSelection] addTableViewWithOptions:languageArray andSelectedDataInfo:selectedLanguageArray andCompletionBlock:^(NSMutableArray *selectedText, NSMutableArray *selectedIndex) {
        selectedLanguageArray = selectedText;
        NSString *result = [selectedLanguageArray componentsJoinedByString:@", "];
        self.modalObject.strLanguage = result;
        [self.editProfileTableView reloadData];
    }];
}

-(void)addDistancePicker : (id) sender {
    [self.view endEditing:YES];
    //Alloc NSMutable Array
   NSMutableArray *distanceArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Km"),KNSLOCALIZEDSTRING(@"Miles"), nil];
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:distanceArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        self.modalObject.strDistance =KNSLOCALIZEDSTRING(selectedText);
        [self.editProfileTableView reloadData];
    }];
}

- (IBAction)btnChoosePhoto:(id)sender {
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

#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    if([status isEqualToString:@"Sample"])  {
        ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.editProfileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
        
        image.accessibilityIdentifier = @"Other";
        [self.modalObject.sampleImageArrayURL addObject:image];
        [self.modalObject.sampleImageArray addObject:[image getBase64String]];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [cell.collectionView reloadData];
        }];
    } else if ([status isEqualToString:@"Document"]) {
        CustomTableViewCell *docCell = (CustomTableViewCell *)[self.editProfileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
        
        [docCell.docImageView setImage:image];
        docImage = image;
        self.modalObject.strDocumentUpload = [image getBase64String];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self.editProfileTableView reloadData];
    }else  {
        [self.userImageButton setBackgroundImage:image forState:UIControlStateNormal];
        self.modalObject.strUpload = [image getBase64String];
        [self.cameraImageView setHidden:YES];
        NSURL *imagePath = [editingInfo objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSString *imageName = [imagePath lastPathComponent];
        NSLog(@"%@",imageName);
        self.modalObject.strImageType = imageName;
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

#pragma mark - UICollectionView Delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.modalObject.sampleImageArrayURL count] + 1;
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
        if ([[self.modalObject.sampleImageArrayURL objectAtIndex:indexPath.row-1] isKindOfClass:[UIImage class]]) {
            cell.sampleImageView.image = [self.modalObject.sampleImageArrayURL objectAtIndex:indexPath.row-1];
            [cell.deleteButton addTarget:self action:@selector(deleteSampleImage:) forControlEvents:UIControlEventTouchUpInside];
        }else {
            
            //
            [cell.sampleImageView sd_setImageWithURL:[self.modalObject.sampleImageArrayURL objectAtIndex:indexPath.row-1] placeholderImage:nil];
            [cell.deleteButton addTarget:self action:@selector(deleteSampleImage:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
  
    return cell;
}


-(void)button_leftAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.editProfileTableView];
    NSIndexPath *indexPath = [self.editProfileTableView indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.editProfileTableView cellForRowAtIndexPath:indexPath];
    
    if (_modalObject.sampleImageArray.count) {
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:YES];
    }
    
    
    
}
-(void)button_rightAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.editProfileTableView];
    NSIndexPath *indexPath = [self.editProfileTableView indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.editProfileTableView cellForRowAtIndexPath:indexPath];
    if (_modalObject.sampleImageArray.count) {
        NSInteger section=[cell.collectionView numberOfSections]-1;
        NSInteger item = [cell.collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        [cell.collectionView scrollToItemAtIndexPath:lastIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionRight
                                            animated:YES];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SignUpCollectionViewCell * cell = (SignUpCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell.sampleImageView.image.accessibilityIdentifier isEqualToString:@"More button"]) {
        status = @"Sample";
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
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
            ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.editProfileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
            [self.modalObject.sampleImageArrayURL removeObjectAtIndex:sender.tag-1];
            [self.modalObject.sampleImageArray removeObjectAtIndex:sender.tag-1];

            [cell.collectionView reloadData];
        }
    }];

}


#pragma mark - UIButton Actions

- (IBAction)editButtonAction:(id)sender {
    [self.view endEditing:YES];
    //    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z]+\\.[A-Za-z]{2,4}";
    //    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    [self isAllFieldsVerified];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action For Email Validation

//- (BOOL) validateNameWithString:(NSString *)nameStr {
//    NSString *emailRegex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
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

-(void)didGetPhonePrefix:(NSString *)phonePrefix forCountry:(NSString *)countryCode {
   // self.modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",phonePrefix];
}

-(void)failedToGetPhonePrefix {
    
}

#pragma mark - Service Implementation Methods

-(void)requestDictForGettingProfileDetail {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_profile" WithComptionBlock:^(id result, NSError *error) {
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            
            self.modalObject = [UserInfo parseResponseForProfileDetail:result];
            [self.userImageButton sd_setBackgroundImageWithURL:self.modalObject.strUploadURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon"]];
            
            [self.cameraImageView setHidden:YES];
            [self getCountryFlagWithCountryDileCode];
            // newly added
            self.categoryArray = [self getCategories];
            [self.editProfileTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
        
    }];
   
}

-(void)requestDictForEditProfile {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:self.modalObject.strUsername forKey:pUserName];
    [requestDict setValue:self.modalObject.strEmailAddress forKey:pEmailID];
    [requestDict setValue:self.modalObject.strAge forKey:pAge];
    [requestDict setValue:self.modalObject.strAddress forKey:pAddress];
    [requestDict setValue:self.modalObject.strContact forKey:pContactNumber];
    [requestDict setValue:([self.modalObject.strDistance length] ? self.modalObject.strDistance : KNSLOCALIZEDSTRING(@"Km")) forKey:pDistancePreference];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:self.modalObject.strGender forKey:pGender];
    [requestDict setValue:self.modalObject.strLanguage forKey:pLanguage];
    [requestDict setValue:self.modalObject.strCategory forKey:pCategory];
    [requestDict setValue:self.modalObject.strPrice forKey:pPrice];
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

    [requestDict setValue:self.modalObject.strUpload forKey:pProfileImage];
//    [requestDict setValue:self.modalObject.strImageType.length?self.modalObject.strImageType:@"" forKey:@"image_type"];
    
    [requestDict setValue:([TRIM_SPACE(self.modalObject.strDescription) length])?self.modalObject.strDescription:[NSString string] forKey:pDescription];
    
    NSMutableArray *subString = [AppUtilityFile getSubstringInArrayFromString:self.modalObject.strDescription];
    [requestDict setValue:[subString count]?subString:[NSArray array] forKey:pDescriptionArray];
    
    [requestDict setValue:([self.modalObject.strDocumentUpload length])?self.modalObject.strDocumentUpload:[NSString string] forKey:pExperienceDocument];
    [requestDict setValue:self.modalObject.sampleImageArray forKey:pImage];
    
    NSMutableArray *stateAndCountry = [AppUtilityFile getSubstringBeforeAndAfterTheFirstComma:self.modalObject.strLocation];
    [requestDict setValue:([stateAndCountry count] >= 1)?[stateAndCountry firstObject]:[NSString string] forKey:pState];
    [requestDict setValue:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string] forKey:pCountry];
    
    [self.phonePrefix getPhonePrefixForCountry:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string]];

    [requestDict setValue:([self.modalObject.strPhonePrefix length])?self.modalObject.strPhonePrefix:@"+1" forKey:pCountryCode];

    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
   
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/edit_profile" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if (!error) {
            self.modalObject = [UserInfo parseResponseForProfileDetail:result];
            BOOL isNumberVerified = [[result objectForKeyNotNull:pStatus expectedObj:@""] boolValue];
            
//            NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
//            [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
//            [userInfoDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
//            
//            [NSUSERDEFAULT setValue:userInfoDict forKey:@"ServiceUserInfoDictionary"];
            
            NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
            NSLog(@"updated data ------%@",clientDict);
            
            [clientDict setValue:[result objectForKeyNotNull:@"email"] forKey:@"userEmail"];
            [clientDict setValue:[clientDict objectForKeyNotNull:@"userPassword"] forKey:@"userPassword"];
            [clientDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
            [clientDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
            [clientDict setValue:[clientDict objectForKeyNotNull:@"isOTPVerified"] forKey:@"isOTPVerified"];
            [NSUSERDEFAULT setValue:clientDict forKey:@"ServiceUserInfoDictionary"];
            NSLog(@"updated data ------%@",clientDict);
            [NSUSERDEFAULT synchronize];
            
            
            
            
            
            if (self.isComingFromSocialLogin) {
                if (isNumberVerified) {
                    [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
                }else {
                    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                    [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
                    [NSUSERDEFAULT setValue:userInfoDict forKey:@"ServiceUserInfoDictionary"];
                    [NSUSERDEFAULT synchronize];
                    MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                    registrationObj.isComingFromLogin = YES;
                    registrationObj.delegate = self;
                    [self.navigationController pushViewController:registrationObj animated:YES];
                    
                }
                
            }else {
                if (isNumberVerified) {
//                    [self.delegate methodForUpdateDetail:self.modalObject];
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                    [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
                    [NSUSERDEFAULT setValue:userInfoDict forKey:@"ServiceUserInfoDictionary"];
                    
                    MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                    registrationObj.isComingFromLogin = YES;
                    registrationObj.delegate = self;
                    [self.navigationController pushViewController:registrationObj animated:YES];
                }
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}

@end
