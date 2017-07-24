//
//  EditProfileVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "EditProfileVC.h"
#import "SignUpTableViewCell.h"
#import "UserInfo.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"
#import "HeaderFile.h"

static NSString *CellIdentifierFirst = @"SignUpTableViewCell";
static NSString *CellIdentifierSecond = @"GenderTableViewCell";

@interface EditProfileVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CountryNameAndPhonePrefixDelegate>
{
    CountryNamesAndPhoneNumberPrefix *prefix;
    NSMutableArray *countryArray;
    LoginVC *login;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *cameraImageView;
@property (weak, nonatomic) IBOutlet UIButton *userImageButton;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (weak, nonatomic) IBOutlet UITableView *editProfileTableView;

@property (weak, nonatomic) IBOutlet UILabel *lblEditProfile;

@property (strong, nonatomic) CountryNamesAndPhoneNumberPrefix *phonePrefix;

@end

@implementation EditProfileVC

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
                 
                 self.editModalObject.strLocation = [NSString stringWithFormat:@"%@, %@",mark.administrativeArea,mark.country];
                 self.editModalObject.strAddress = [NSString stringWithFormat:@"%@, %@",mark.locality,mark.subLocality];

                 [self.editProfileTableView reloadData];
             }
         }
     }];
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    _lblEditProfile.text = KNSLOCALIZEDSTRING(@"Edit Profile");
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnEdit setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Alloc and set delegate of CountryNamesAndPhoneNumberPrefix
    self.phonePrefix = [[CountryNamesAndPhoneNumberPrefix alloc] initWithDelegate:self];
    
    //Register the tableView Cell
     [self.editProfileTableView registerNib:[UINib nibWithNibName:@"SignUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"SignUpTableViewCell"];
    [self.editProfileTableView registerNib:[UINib nibWithNibName:@"GenderTableViewCell" bundle:nil] forCellReuseIdentifier:@"GenderTableViewCell"];
    
    //Set Table View Header & Footer
    [self.editProfileTableView setTableHeaderView:self.headerView];

    //Set Layout of ImageView
   // [self.userImageButton.layer setCornerRadius:self.userImageButton.frame.size.height/2];
    self.userImageButton.layer.cornerRadius = 50.0;
    [self.userImageButton setClipsToBounds:YES];
    [self.cameraImageView.layer setCornerRadius:20];
    
    //Bounce table vertical if required
    [self.editProfileTableView setAlwaysBounceVertical:NO];
    
    //Alloc Modal Class Object
    if (!self.editModalObject) {
        self.editModalObject = [[UserInfo alloc]init];
        self.editModalObject.strGender = [NSString string];
        self.editModalObject.strUpload = [NSString string];
        
        [self requestDictForGettingProfileDetail];
    }
    else
        [self getCountryFlagWithCountryDileCode];

    [self.userImageButton sd_setBackgroundImageWithURL:self.editModalObject.strUploadURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon"]];

    if (self.editModalObject.strUploadURL) {
        [self.cameraImageView setHidden:YES];
    }
    
    prefix = [[CountryNamesAndPhoneNumberPrefix alloc]init];
    countryArray = [NSMutableArray array];
    [self countryNameAndPrefix];
}

-(void)getCountryFlagWithCountryDileCode{
    
    BDVCountryNameAndCode *countryNameAndCode = [[BDVCountryNameAndCode alloc] init];
    NSString * countryCode = [countryNameAndCode getCountryCodeForDialCode:self.editModalObject.strPhonePrefix];
    NSString *imageName = [NSString stringWithFormat:@"CountryPicker.bundle/%@",countryCode];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    UIImage *image = [UIImage imageNamed:imageName];
    self.editModalObject.flagImage = image;
}

-(void )isAllFieldsVerified {
//     NSMutableDictionary *dict = [NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"];
    if(self.editModalObject.strUsername == nil || [self.editModalObject.strUsername isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the username.") onController:self];
    }
    else if (![self validateNameWithString:self.editModalObject.strUsername]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid username.") onController:self];
    }
    else  if(self.editModalObject.strEmailAddress == nil || [self.editModalObject.strEmailAddress isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the email address.") onController:self];
    } 
    
    //    else if([emailTest evaluateWithObject:self.editModalObject.strEmailAddress] == NO) {
    else if(![_editModalObject.strEmailAddress isValidEmail] ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter a valid email address.") onController:self];
    }
    else if(self.editModalObject.strContact == nil || [self.editModalObject.strContact isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the contact number.") onController:self];
    }
    else if(self.editModalObject.strDistance == nil || [self.editModalObject.strDistance isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please select the distance preference.") onController:self];
    }
    else {
        [self requestDictForEditProfile];
    }

}

-(void)countryNameAndPrefix {
    for (NSDictionary *dic in prefix.countriesList) {
        NSString *country = [NSString stringWithFormat:@"%@  -  %@",[dic objectForKeyNotNull:@"name" expectedObj:@""],[dic objectForKeyNotNull:@"dial_code" expectedObj:@""]];
        [countryArray addObject:country];
    }
    
}


#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 2)
    {
        GenderTableViewCell *cell = (GenderTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdentifierSecond];
        
        cell.maleButton.tag = indexPath.row + 200;
        cell.femaleButton.tag = indexPath.row + 201;
        
        [cell.maleButton addTarget:self action:@selector(maleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.femaleButton addTarget:self action:@selector(femaleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.editModalObject.strGender isEqualToString:@"male"]) {
            [cell.maleButton setSelected:YES];
            [cell.femaleButton setSelected:NO];
        }else if ([self.editModalObject.strGender isEqualToString:@"female"]) {
            [cell.femaleButton setSelected:YES];
            [cell.maleButton setSelected:NO];
        }
        
        NSString * languagestring = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if([languagestring isEqualToString:@"ar"]){
            cell.maleButton.titleEdgeInsets = UIEdgeInsetsZero;
            cell.femaleButton.titleEdgeInsets = UIEdgeInsetsZero;

        }else if ([languagestring isEqualToString:@"es"]) {
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
    else
    {
    SignUpTableViewCell *cell = (SignUpTableViewCell *)[self.editProfileTableView dequeueReusableCellWithIdentifier:CellIdentifierFirst];
         addPading(cell.signUpTextField);
        [cell.signUpTextField setSecureTextEntry:NO];
        [cell.signUpTextField setKeyboardType:UIKeyboardTypeDefault];
        [cell.signUpTextField setReturnKeyType:UIReturnKeyNext];
        [cell.signUpTextField setDelegate:self];
        [cell.signUpTextField setTextAlignment:NSTextAlignmentLeft];
        [cell.imageViewDrop setHidden:YES];
        [cell.pickerButton setHidden:YES];
        [cell.contactPrefixButton setHidden:YES];
        [cell.flagImageView setHidden:YES];

        if(indexPath.row<2)
            [cell.signUpTextField setTag:indexPath.row+100];
        else
            [cell.signUpTextField setTag:(indexPath.row-1)+100];

        NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
        if ([language isEqualToString:@"ar"])
        {
            cell.signUpTextField.textAlignment = NSTextAlignmentRight;
        }

        [cell.signUpTextField setUserInteractionEnabled:YES];

    switch (indexPath.row) {
        case 0:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Username")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

            [cell.signUpTextField setText:self.editModalObject.strUsername];
            break;
            
        case 1:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Age(Year)")]];
            [cell.signUpTextField setText:self.editModalObject.strAge];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.pickerButton addTarget:self action:@selector(addPicker:) forControlEvents:UIControlEventTouchUpInside];
            [cell.imageViewDrop setHidden:NO];
            cell.pickerButton.hidden=NO;
            [cell.signUpTextField setUserInteractionEnabled:NO];
            [self.view endEditing:NO];
            break;
            
        case 3:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Email")]];
            [cell.signUpTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            if ([NSUSERDEFAULT boolForKey:@"isSocialLogin"]) {
                [cell.signUpTextField setUserInteractionEnabled:NO];
            }
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setText:self.editModalObject.strEmailAddress ];
            break;
            
        case 4: {
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Contact No.")]];
            [cell.signUpTextField setText:self.editModalObject.strContact];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [cell.contactPrefixButton setHidden:NO];
            [cell.flagImageView setHidden:NO];
            [cell.flagImageView setImage:self.editModalObject.flagImage];
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 58)];
            cell.signUpTextField.leftView = paddingView;
            cell.signUpTextField.leftViewMode = UITextFieldViewModeAlways;
            [cell.contactPrefixButton addTarget:self action:@selector(addContactPrefixPicker:) forControlEvents:UIControlEventTouchUpInside];
            if ([self.editModalObject.strPhonePrefix length]) {
                [cell.contactPrefixButton setTitle:self.editModalObject.strPhonePrefix forState:UIControlStateNormal];
            }
           }
            break;
            
        case 5:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"State ,Country(Autofill By Location)")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

            if ([self.editModalObject.strLocation length]) {
                [cell.signUpTextField setText:self.editModalObject.strLocation];
            }
            [cell.signUpTextField setUserInteractionEnabled:NO];
//            NSLog(@"State %ld",(long)cell.signUpTextField.tag);
            break;
            
        case 6:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Address")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setText:self.editModalObject.strAddress];
            [cell.signUpTextField setReturnKeyType:UIReturnKeyDone];
            [cell.signUpTextField setUserInteractionEnabled:NO];
//            NSLog(@"Address %ld",(long)cell.signUpTextField.tag);

            break;
            
        case 7:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Distance Preference")]];
            [cell.signUpTextField setText:self.editModalObject.strDistance];
            cell.pickerButton.hidden=NO;
            [cell.imageViewDrop setHidden:NO];
            [cell.pickerButton addTarget:self action:@selector(addDistancePicker:) forControlEvents:UIControlEventTouchUpInside];

            break;
            
        default:
            break;
    }
    return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==2) {
        return 88.0f;
    }else if (indexPath.row == 7) {
        return 60.0f;
    }
    else
    {
            return 60.0f;
    }
}

#pragma mark - OptionsPickerSheetView Methods

-(void)addPicker : (UIButton *) sender {
     [self.view endEditing:YES];
    
    //Initalise the Arrays
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    for(int i =18 ; i<=100 ; ++i)
    {
        [dataArray addObject:[NSString stringWithFormat:@"%d", i]];
    }

    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:dataArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        self.editModalObject.strAge = selectedText;
        [self.editProfileTableView reloadData];
    }];
    
}

-(void)addContactPrefixPicker: (UIButton *) sender {
    [self.view endEditing:YES];
    
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithCountryFlags:^(NSMutableDictionary *selectedDict, NSInteger selectedIndex) {
        
        self.editModalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"dial_code"]];
        self.editModalObject.flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[selectedDict valueForKey:@"code"]]];
        [self.editProfileTableView reloadData];
        
    }];    
}


-(void)addDistancePicker : (UIButton *) sender {
     [self.view endEditing:YES];
    
      //Initalise the Arrays
    NSMutableArray *distanceArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Km"),KNSLOCALIZEDSTRING(@"Miles"), nil];
    
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:distanceArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
        self.editModalObject.strDistance =KNSLOCALIZEDSTRING(selectedText);
        [self.editProfileTableView reloadData];
    }];
}

#pragma mark - UITextField delegate methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField *emailTextField = APPTEXTFIELD(102);
    UITextField *contactField = APPTEXTFIELD(103);
    UITextField *userNameTextField = APPTEXTFIELD(100);
    UITextField *countryField = APPTEXTFIELD(104);
    UITextField *addressTextField = APPTEXTFIELD(105);

    if([string isEqualToString:@" "])
    {
        if ((textField ==  userNameTextField && range.location != 0)|| (textField == countryField && range.location != 0)|| (textField == addressTextField && range.location != 0)) {
            return YES;
        }
        return NO;
    }
    else if (textField == contactField) {

            if (![textFieldString isEqualToString:@""]) {
                if ([self validatePhoneNoCharacter:textFieldString] == NO) {
                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter phone no in english.") onController:self];
                    return NO;
                }
            }
            return YES;
    }
    else if (textField == emailTextField) {
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
   else if (textField == userNameTextField) {
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
   else  if (textField.tag == 104 || textField.tag == 105) {
       if(![string isEqualToString:@""]){
       if ([textFieldString length] > 60) {
           return NO;
       }else{
           return YES;
       }
   }
       return YES;
   }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 100){
       [[self.view viewWithTag:textField.tag+2] becomeFirstResponder];
    }
    else{
    if([textField returnKeyType] == UIReturnKeyNext) {
        [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        return NO;
    }
    else
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 103) {
        [textField setInputAccessoryView:toolBarForNumberPad(self, @"Done")];
    }else {
        [textField setInputAccessoryView:nil];
    }
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
//    UITextField *txtFld = (UITextField*)[self.view viewWithTag:103];
//    [[self.view viewWithTag:txtFld.tag+1] becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
     [self.view layoutIfNeeded];
    switch (textField.tag) {
        case 100:
            [self.editModalObject setStrUsername:textField.text];
            break;
        case 101:
            [self.editModalObject setStrAge:textField.text];
            break;
        case 102:
            [self.editModalObject setStrEmailAddress:textField.text];
            break;
        case 103:
            [self.editModalObject setStrContact:textField.text];
            break;
        case 104:
            [self.editModalObject setStrLocation:textField.text];
            break;
        case 105:
            [self.editModalObject setStrAddress:textField.text];
            break;
        case 106:
            [self.editModalObject setStrDistance:textField.text];
            break;
        default:
            break;
    }
}

-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

#pragma mark  - UIButton's Action

- (void)maleButtonAction:(UIButton *)sender  {
    UIButton *maleBtn = sender;
    UIButton *femaleBtn = APPBUTTON(maleBtn.tag + 1);
    
    [maleBtn setSelected:YES];
    [femaleBtn setSelected:NO];
    
    self.editModalObject.strGender = @"male";
    
    [self.editProfileTableView reloadData];
}

- (void)femaleButtonAction:(UIButton *)sender  {
    UIButton *femaleBtn = sender;
    UIButton *maleBtn = APPBUTTON(femaleBtn.tag - 1);
    
    [femaleBtn setSelected:YES];
    [maleBtn setSelected:NO];
    
    self.editModalObject.strGender = @"female";

    [self.editProfileTableView reloadData];
}

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButton:(id)sender {
    [self.view endEditing:YES];
//    NSString *emailReg = @"[A-Z0-9a-z._]+@[A-Za-z]+\\.[A-Za-z]{2,3}";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    [self isAllFieldsVerified];
   }

//- (BOOL) validateNameWithString:(NSString *)nameStr {
//    NSString *emailRegex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    BOOL isValid = [emailTest evaluateWithObject:nameStr];
//    return isValid;
//}

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

- (IBAction)userImageButton:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                           KNSLOCALIZEDSTRING(@"Take Photo"),
                           KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Device has no camera") onController:self];
//                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                              message:KNSLOCALIZEDSTRING(@"Device has no camera")
//                                                                             delegate:nil
//                                                                    cancelButtonTitle:KNSLOCALIZEDSTRING(@"OK")
//                                                                    otherButtonTitles: nil];
//                        [myAlertView show];
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
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [self.userImageButton setBackgroundImage:image forState:UIControlStateNormal];
    self.editModalObject.strUpload = [image getBase64String];
    [self.cameraImageView setHidden:YES];
    NSURL *imagePath = [editingInfo objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *imageName = [imagePath lastPathComponent];
    NSLog(@"%@",imageName);
    self.editModalObject.strImageType = imageName;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)didGetPhonePrefix:(NSString *)phonePrefix forCountry:(NSString *)countryCode {
    //self.editModalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",phonePrefix];
}

-(void)failedToGetPhonePrefix {
    
}

#pragma mark - Service Implementation Methods

-(void)requestDictForEditProfile {

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:self.editModalObject.strUsername forKey:pUserName];
    [requestDict setValue:self.editModalObject.strEmailAddress forKey:pEmailID];
    [requestDict setValue:self.editModalObject.strAge forKey:pAge];
    [requestDict setValue:self.editModalObject.strAddress forKey:pAddress];
    [requestDict setValue:self.editModalObject.strContact forKey:pContactNumber];
    
    [requestDict setValue:([self.editModalObject.strDistance length] ? self.editModalObject.strDistance : KNSLOCALIZEDSTRING(@"Km")) forKey:pDistancePreference];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:self.editModalObject.strGender forKey:pGender];
    [requestDict setValue:self.editModalObject.strUpload forKey:pProfileImage];
//    [requestDict setValue:self.editModalObject.strImageType.length?self.editModalObject.strImageType:@"" forKey:@"image_type"];
    
    [requestDict setValue:[NSString string] forKey:pCategory];
    [requestDict setValue:[NSString string] forKey:pPrice];
    [requestDict setValue:[NSString string] forKey:pDescription];
    [requestDict setValue:[NSString string] forKey:pExperienceDocument];
    [requestDict setValue:[NSArray array] forKey:pImage];
    [requestDict setValue:[NSString string] forKey:pLanguage];
    [requestDict setValue:[NSArray array] forKey:pDescriptionArray];
    
    NSMutableArray *stateAndCountry = [AppUtilityFile getSubstringBeforeAndAfterTheFirstComma:self.editModalObject.strLocation];
    [requestDict setValue:([stateAndCountry count] >= 1)?[stateAndCountry firstObject]:[NSString string] forKey:pState];
    [requestDict setValue:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string] forKey:pCountry];
    
    [self.phonePrefix getPhonePrefixForCountry:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string]];
    
    [requestDict setValue:([self.editModalObject.strPhonePrefix length])?self.editModalObject.strPhonePrefix:@"+1" forKey:pCountryCode];
    
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/edit_profile" WithComptionBlock:^(id result, NSError *error) {
        
    [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            self.editModalObject = [UserInfo parseResponseForProfileDetail:result];
            BOOL isNumberVerified = [[result objectForKeyNotNull:pStatus expectedObj:@""] boolValue];
            
//            NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
//            [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
//            [userInfoDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
//            
//            [NSUSERDEFAULT setValue:userInfoDict forKey:@"ClientUserInfoDictionary"];
            
            NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
            NSLog(@"updated data ------%@",clientDict);

            [clientDict setValue:[result objectForKeyNotNull:@"email"] forKey:@"userEmail"];
            [clientDict setValue:[clientDict objectForKeyNotNull:@"userPassword"] forKey:@"userPassword"];
            [clientDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
            [clientDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
            [clientDict setValue:[clientDict objectForKeyNotNull:@"isOTPVerified"] forKey:@"isOTPVerified"];
            [NSUSERDEFAULT setValue:clientDict forKey:@"ClientUserInfoDictionary"];
            NSLog(@"updated data ------%@",clientDict);
            [NSUSERDEFAULT synchronize];
            
            if (self.isComingFromSocialLogin) {
                if (isNumberVerified) {
                    [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
                }else {
                    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                    [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
                    [NSUSERDEFAULT setValue:userInfoDict forKey:@"ClientUserInfoDictionary"];
                    
                    MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                    registrationObj.isComingFromLogin = YES;
                    registrationObj.delegate = self;
                    [self.navigationController pushViewController:registrationObj animated:YES];
                }
                
            }else {
                if (isNumberVerified) {
                    [self.delegate methodForUpdateClientDetail:self.editModalObject];
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                    [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
                    [NSUSERDEFAULT setValue:userInfoDict forKey:@"ClientUserInfoDictionary"];
                    
                    MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                    registrationObj.isComingFromLogin = YES;
                    registrationObj.delegate = self;
                    [self.navigationController pushViewController:registrationObj animated:YES];
                    
                }
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:error.localizedDescription onController:self];

        }
        
    }];
   
}


-(void)requestDictForGettingProfileDetail {
   
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_profile" WithComptionBlock:^(id result, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            self.editModalObject = [UserInfo parseResponseForProfileDetail:result];
            [self getCountryFlagWithCountryDileCode];
            [self.editProfileTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:error.localizedDescription onController:self];
        }
    }];
    
}


-(void)methodForNavigateToHome {
    [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
}

@end
