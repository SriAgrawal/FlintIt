//
//  SignUpVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "SignUpVC.h"
#import "UserInfo.h"
#import "SignUpTableViewCell.h"
#import "GenderTableViewCell.h"
#import "TermsVC.h"
#import "AppUtilityFile.h"
#import "MZSelectableLabel.h"
#import "MacroFile.h"
#import "MobileRegistrationVC.h"
#import "OptionsPickerSheetView.h"
#import "AlertView.h"
#import "NSDictionary+NullChecker.h"
#import "UIImage+CC.h"
#import <CoreLocation/CoreLocation.h>
#import "CountryNamesAndPhoneNumberPrefix.h"
#import "TableViewWithMultipleSelection.h"
#import "BDVCountryNameAndCode.h"

static NSString *CellIdFirst = @"SignUpTableViewCell";
static NSString *CellIdSecond = @"GenderTableViewCell";

@interface SignUpVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CountryNameAndPhonePrefixDelegate>
{
    UserInfo *modalObject;
    CountryNamesAndPhoneNumberPrefix *prefix;
    NSMutableArray *countryArray,*selectedDataArray;
  
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineLabelWidthConstraint;

@property (assign)BOOL isEmailField;
@property (assign)BOOL isPhoneNoField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineLabelCenterXConstraint;

@property (weak, nonatomic) IBOutlet UITableView *signUpTableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *cameraImageView;

@property (weak, nonatomic) IBOutlet UIButton *choosePhotoButton;

@property (weak, nonatomic) IBOutlet MZSelectableLabel *lblTermAndCondition;
@property (weak, nonatomic) IBOutlet MZSelectableLabel *lblLogin;

@property (weak, nonatomic) IBOutlet UILabel *lblSignUp;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (strong, nonatomic) CountryNamesAndPhoneNumberPrefix *phonePrefix;

@end

@implementation SignUpVC

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

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self setCurrentCountryDetails];
    
    [self.signUpTableView reloadData];
    
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
                     [self.signUpTableView reloadData];
                 }
             }
     }];
}

-(void)didGetPhonePrefix:(NSString *)phonePrefix forCountry:(NSString *)countryCode {
    modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",phonePrefix];
}

-(void)failedToGetPhonePrefix {
    
}

#pragma mark - Helper method

-(void)initialSetup {
    // Sign Up and get the right person in the right time for the right job.
     [self.signUpButton setTitle:KNSLOCALIZEDSTRING(@"Sign Up") forState:UIControlStateNormal] ;
    //_lblSignUp.text = KNSLOCALIZEDSTRING(@"Sign Up and get the right person in \n the right time for the right job.");
    _lblSignUp.text = KNSLOCALIZEDSTRING(@"Sign Up and get the right person in the right time for the right job.");
    _lblTermAndCondition.text = KNSLOCALIZEDSTRING(@"BY CREATING AN ACCOUNT, YOU AGREE TO Flink It TERMS OF SERVICES.");
    _titleLabel.text = KNSLOCALIZEDSTRING(@"Sign Up");
    _lblLogin.text = KNSLOCALIZEDSTRING(@"Already have an account? Login");
    
    //Alloc and set delegate of CountryNamesAndPhoneNumberPrefix
    self.phonePrefix = [[CountryNamesAndPhoneNumberPrefix alloc] initWithDelegate:self];
    
    //Register TableView Cell
    [self.signUpTableView registerNib:[UINib nibWithNibName:@"SignUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"SignUpTableViewCell"];
    [self.signUpTableView registerNib:[UINib nibWithNibName:@"GenderTableViewCell" bundle:nil] forCellReuseIdentifier:@"GenderTableViewCell"];
    
    //Set Image Outlet
    // [self.choosePhotoButton.layer setCornerRadius:self.choosePhotoButton.frame.size.width/2];
    self.choosePhotoButton.layer.cornerRadius = 57.5;
    [self.choosePhotoButton setClipsToBounds:YES];
    [self.cameraImageView.layer setCornerRadius:20];

    //Set Table Header&Footer
    [self.signUpTableView setTableHeaderView:self.headerView];
    [self.signUpTableView setTableFooterView:self.footerView];
    
    //Bounce table vertical if required
    [self.signUpTableView setAlwaysBounceVertical:NO];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    modalObject.strGender = [NSString string];
    modalObject.strAge = [NSString string];
    modalObject.strUpload = [NSString string];
    modalObject.strAddress = [NSString string];
    modalObject.strLocation = [NSString string];

    //Set range and make Terms of services and Login tappable
    [self.lblTermAndCondition setSelectableRange:[[self.lblTermAndCondition.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"TERMS OF SERVICES.")]];
    self.lblTermAndCondition.selectionHandler = ^(NSRange range, NSString *string) {
            TermsVC *termObj = [[TermsVC alloc]initWithNibName:@"TermsVC" bundle:nil];
            [self.navigationController pushViewController:termObj animated:YES];
    };
    
    [self.lblLogin setAttributedText:[AppUtilityFile getSimpleMultiAttributedString:KNSLOCALIZEDSTRING(@"Already have an account? Login") firstStr:@"Login" withColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:157.0/255.0 alpha:1] withFont:self.lblLogin.font secondStr:nil withColor:nil withFont:nil]];
    [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@"Login"]];
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        
        [self.lblLogin setAttributedText:[AppUtilityFile getSimpleMultiAttributedString:KNSLOCALIZEDSTRING(@"هل لديك حساب؟ الدخول") firstStr:@" الدخول" withColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:157.0/255.0 alpha:1] withFont:self.lblLogin.font secondStr:nil withColor:nil withFont:nil]];
        [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@" الدخول"]];
        [self.lblTermAndCondition setSelectableRange:[[self.lblTermAndCondition.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"TERMS OF SERVICES.")]];
        _underLineLabelCenterXConstraint.constant = -46;
    }
    
    else if ([language isEqualToString:@"es"]) {
        [self.lblLogin setSelectableRange:[[self.lblLogin.attributedText string] rangeOfString:@"Iniciar sesión"]];
        _underLineLabelCenterXConstraint.constant = 77;
        [self.lblTermAndCondition setSelectableRange:[[self.lblTermAndCondition.attributedText string] rangeOfString:KNSLOCALIZEDSTRING(@"términos de servicios.")]];
        

    }else{
        _underLineLabelCenterXConstraint.constant = 85;

    }
    
    
    self.lblLogin.selectionHandler = ^(NSRange range, NSString *string) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    

    
    prefix = [[CountryNamesAndPhoneNumberPrefix alloc]init];
    countryArray = [NSMutableArray array];
    [self countryNameAndPrefix];
    
}

-(void)isAllFieldVerified {
    if(modalObject.strUsername == nil || [modalObject.strUsername isEqualToString:@""]) {
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
    else if(![modalObject.strEmailAddress isValidEmail] ) {
        //    else if([emailTest evaluateWithObject:modalObject.strEmailAddress] == NO) {
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
    else if(modalObject.strContact == nil || [modalObject.strContact isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the contact number.") onController:self];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if(indexPath.row == 5)
       {
            GenderTableViewCell *cell = (GenderTableViewCell *)[self.signUpTableView dequeueReusableCellWithIdentifier:CellIdSecond];
           
           cell.maleButton.tag = indexPath.row + 500;
           cell.femaleButton.tag = indexPath.row + 501;
           
           [cell.maleButton addTarget:self action:@selector(maleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
           [cell.femaleButton addTarget:self action:@selector(femaleButtonAction:) forControlEvents:UIControlEventTouchUpInside];

           
           // set button when arabic
           NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
           if ([language isEqualToString:@"ar"]) {

            cell.maleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.femaleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
           }  else if ([language isEqualToString:@"es"]) {
               _underLineLabelWidthConstraint.constant = 80;
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
    SignUpTableViewCell *cell = (SignUpTableViewCell *)[self.signUpTableView dequeueReusableCellWithIdentifier:CellIdFirst];
   
    [cell.signUpTextField setSecureTextEntry:NO];
    [cell.signUpTextField setKeyboardType:UIKeyboardTypeDefault];
    [cell.signUpTextField setReturnKeyType:UIReturnKeyNext];
    [cell.signUpTextField setDelegate:self];
    [cell.signUpTextField setTextAlignment:NSTextAlignmentLeft];
        
    [cell.pickerButton setHidden:YES];
    [cell.imageViewDrop setHidden:YES];
    [cell.signUpTextField setUserInteractionEnabled:YES];
    [cell.contactPrefixButton setHidden:YES];
    [cell.flagImageView setHidden:YES];

    addPading(cell.signUpTextField);

    [cell.signUpTextField setTag:indexPath.row+100];
        
            NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            if ([language isEqualToString:@"ar"])        {
            cell.signUpTextField.textAlignment = NSTextAlignmentRight;
        }
        
    switch (indexPath.row) {
        case 0:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Username")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            [cell.signUpTextField setText:modalObject.strUsername];
            break;
            
        case 1:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Email Address")]];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            [cell.signUpTextField setText:modalObject.strEmailAddress];
               break;
            
        case 2:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Password")]];
            [cell.signUpTextField setSecureTextEntry:YES];
            [cell.signUpTextField setText:modalObject.strPswrd];
               break;
            
        case 3:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Confirm Password")]];
            [cell.signUpTextField setSecureTextEntry:YES];
            [cell.signUpTextField setText:modalObject.strConfirmPswrd];
                break;
    
        case 4:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Age")]];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setUserInteractionEnabled:NO];
            [cell.signUpTextField setText:modalObject.strAge];
            cell.pickerButton.tag = 1000;
            [cell.pickerButton addTarget:self action:@selector(addPicker:) forControlEvents:UIControlEventTouchUpInside];
            [cell.imageViewDrop setHidden:NO];
            [cell.pickerButton setHidden:NO];
                break;
            
        case 6:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"State ,Country(Autofill By Location)")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            [cell.signUpTextField setText:modalObject.strLocation];
            [cell.signUpTextField setUserInteractionEnabled:NO];

               break;
            
        case 7:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Address")]];
            cell.signUpTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            [cell.signUpTextField setText:modalObject.strAddress];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.signUpTextField setUserInteractionEnabled:NO];

              break;
            
        case 8: {
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Contact No.")]];
            [cell.signUpTextField setText:modalObject.strContact];
            [cell.signUpTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.contactPrefixButton setHidden:NO];
            [cell.flagImageView setHidden:NO];
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 58)];
            cell.signUpTextField.leftView = paddingView;
            cell.signUpTextField.leftViewMode = UITextFieldViewModeAlways;
            [cell.contactPrefixButton addTarget:self action:@selector(addContactPrefixPicker:) forControlEvents:UIControlEventTouchUpInside];
            if ([modalObject.strPhonePrefix length]) {
                [cell.contactPrefixButton setTitle:modalObject.strPhonePrefix forState:UIControlStateNormal];
            }
            [cell.flagImageView setImage:modalObject.flagImage];
            [cell.signUpTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [cell.signUpTextField setReturnKeyType:UIReturnKeyDone];
            cell.pickerButton.tag = 2000;
            [cell.pickerButton addTarget:self action:@selector(addDistancePicker:) forControlEvents:UIControlEventTouchUpInside];

            break;
        }
        case 9:
            [cell.signUpTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Distance Preference")]];
            [cell.signUpTextField setText:modalObject.strDistance];
            [cell.signUpTextField setUserInteractionEnabled:NO];
             [cell.pickerButton setHidden:NO];
            [cell.imageViewDrop setHidden:NO];
            cell.pickerButton.tag = 3000;
             [cell.pickerButton addTarget:self action:@selector(addDistancePicker:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
            default:
               break;
    }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==5)
        return 88.0f;
    else
        return 60.0f;
}

#pragma mark - OptionsPickerSheetView Methods

-(void)addPicker : (UIButton *) sender {
    [self.view endEditing:YES];
    
    if (sender.tag == 1000) {
        //Initalise the Arrays
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        for(int i =18 ; i<=100 ; ++i)
        {
            [dataArray addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:dataArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
            modalObject.strAge = KNSLOCALIZEDSTRING(selectedText);
            [self.signUpTableView reloadData];
        }];
    }
}

-(void)addContactPrefixPicker: (UIButton *) sender {
    [self.view endEditing:YES];
    
    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithCountryFlags:^(NSMutableDictionary *selectedDict, NSInteger selectedIndex) {
        
        modalObject.strPhonePrefix = [NSString stringWithFormat:@"%@",[selectedDict valueForKey:@"dial_code"]];
        modalObject.flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",[selectedDict valueForKey:@"code"]]];
        [self.signUpTableView reloadData];

    }];
    
//    [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:countryArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
//       NSString *needle = [selectedText componentsSeparatedByString:@"-  "][1];
//        modalObject.strPhonePrefix = needle;
//        [self.signUpTableView reloadData];
//    }];
    
}

-(void)addDistancePicker : (UIButton *) sender {
    [self.view endEditing:YES];
    
    if (sender.tag == 2000 || sender.tag == 3000) {
        //Initalise the Arrays
        NSMutableArray *distanceArray = [[NSMutableArray alloc]initWithObjects:KNSLOCALIZEDSTRING(@"Km"),KNSLOCALIZEDSTRING(@"Miles"), nil];
        
        [[OptionsPickerSheetView sharedPicker] showPickerSheetWithOptions:distanceArray AndComplitionblock: ^(NSString *selectedText, NSInteger selectedIndex) {
            modalObject.strDistance = KNSLOCALIZEDSTRING(selectedText);
            [self.signUpTableView reloadData];
        }];
    }

}


//- (IBAction)emailTextFieldBeginEdit:(id)sender {
//    
//    _isEmailField = YES;
//}
//
//- (IBAction)emailTextFieldEndEdit:(id)sender {
//    _isEmailField = NO;
//}
//#pragma mark - UITextInputMode
//- (UITextInputMode *) textInputMode {
//    if(_isEmailField) {
//        _isEmailField = YES;
//
//        for (UITextInputMode *inputMode in [UITextInputMode activeInputModes]) {
//            
//            if([inputMode.primaryLanguage isEqualToString:@"en-US"]) {
//                return inputMode;
//            }
//        }
//    }
//    NSLog(@"%@",[super textInputMode]);
//    return [super textInputMode];
//}

#pragma mark - UITextField delegate methods

//client
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if([string isEqualToString:@" "])
    {
        UITextField *userNameTextField = APPTEXTFIELD(100);
        UITextField *AddressTextField = APPTEXTFIELD(107);
        UITextField *countryField = APPTEXTFIELD(106);
//        UITextField *emailField = APPTEXTFIELD(101);


        
        if ((textField ==  userNameTextField && range.location != 0) || (textField == AddressTextField && range.location != 0)|| (textField == countryField && range.location != 0)) {
            return YES;
        }
        return NO;
    }else
    {
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
       else if (textField.tag == 102) {
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
        else  if (textField.tag == 106 || textField.tag == 107) {
            if(![string isEqualToString:@""]) {
                if ([textFieldString length] > 60) {
                    return NO;
                }else{
                    return YES;
                }
            }
            return YES;
        }
        else  if (textField.tag == 108) {

                if (![textFieldString isEqualToString:@""]) {
                    if ([self validatePhoneNoCharacter:textFieldString] == NO) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter phone no in english.") onController:self];
                        return NO;
                    }
                }
                return YES;
        }
    }
    
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    
//    if (textField.tag == 101 && !_isEmailField) {
//        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter email in english.") onController:self];
//        _isEmailField = YES;
//    }else if(textField.tag == 108 && !_isPhoneNoField)
//    {
//        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter phone no in english numbers.") onController:self];
//        _isPhoneNoField = YES;
//    }
//    return YES;
//}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 108) {
        [textField setInputAccessoryView:toolBarForNumberPad(self,KNSLOCALIZEDSTRING(@"Done"))];
    }else {
        [textField setInputAccessoryView:nil];
    }
}

-(void)doneWithNumberPad:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField returnKeyType] == UIReturnKeyNext) {
        if (textField.tag == 103) {
            [[self.view viewWithTag:textField.tag+3] becomeFirstResponder];
        }else
            [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        
        return NO;
    }
    else
        [textField resignFirstResponder];

    return YES;
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
        case 106:
            [modalObject setStrLocation:textField.text];
            break;
        case 107:
            [modalObject setStrAddress:textField.text];
            break;
        case 108:
            [modalObject setStrContact:textField.text];
            break;
        
        default:
            break;
    }
}

-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

#pragma mark - UIButton Action

- (IBAction)signUpAction:(id)sender {
    [self.view endEditing:YES];
//    QBUUser *currentUser = [QBUUser user];
//    currentUser.ID = 56;
//    currentUser.password = @"chatUser1pass";
//    
//    // connect to Chat
////    [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
//    
//    }];

    [self isAllFieldVerified];
    
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action For Email Validation

- (BOOL) validateNameWithString:(NSString *)nameStr {
//    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
//    NSString *emailRegex;
//    if ([language isEqualToString:@"ar"]) {
//        emailRegex =@"^[a-zA-Z\u0600-\u06FF\\s.]+$";
//    }else if ([language isEqualToString:@"es"]) {
//        emailRegex =@"[À-ÿA-Za-z.]+([ '-][a-zA-Z]+)*$";
//    }else{
//        emailRegex =@"^[a-zA-Z\\s.]+$";
//    }
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    BOOL isValid = [emailTest evaluateWithObject:nameStr];
//    return isValid;
    
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
- (void)maleButtonAction:(UIButton *)sender  {
    UIButton *maleBtn = sender;
    UIButton *femaleBtn = APPBUTTON(maleBtn.tag + 1);
    
    [maleBtn setSelected:YES];
    [femaleBtn setSelected:NO];
    
    modalObject.strGender = @"male";
    [self.signUpTableView reloadData];
}

- (void)femaleButtonAction:(UIButton *)sender  {
    UIButton *femaleBtn = sender;
    UIButton *maleBtn = APPBUTTON(femaleBtn.tag - 1);
    
    [femaleBtn setSelected:YES];
    [maleBtn setSelected:NO];

    modalObject.strGender = @"female";

    [self.signUpTableView reloadData];
}

- (IBAction)choosePhoto:(id)sender {
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
    
    switch ([popup tag]) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        [[AlertView sharedManager]displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Device has no camera.") onController:self];
//                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                              message:KNSLOCALIZEDSTRING(@"Device has no camera.")
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
    //[self.choosePhotoButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.choosePhotoButton setImage:image forState:UIControlStateNormal];

    modalObject.strUpload = [image getBase64String];
    [self.cameraImageView setHidden:YES];

    NSURL *imagePath = [editingInfo objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *imageName = [imagePath lastPathComponent];
    NSLog(@"%@",imageName);
    modalObject.strImageType = imageName;

    [picker dismissViewControllerAnimated:YES completion:nil];
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
    [requestDict setValue:modalObject.strUpload forKey:pProfileImage];
//    [requestDict setValue:[modalObject.strImageType length]?modalObject.strImageType:@"" forKey:@"image_type"];
    
    [requestDict setValue:[NSString string] forKey:pCategory];
    [requestDict setValue:[NSString string] forKey:pPrice];
    [requestDict setValue:[NSString string] forKey:pDescription];
    [requestDict setValue:[NSString string] forKey:pExperienceDocument];
    [requestDict setValue:[NSArray array] forKey:pImage];
    [requestDict setValue:[NSString string] forKey:pLanguage];
    [requestDict setValue:[NSArray array] forKey:pDescriptionArray];

    NSMutableArray *stateAndCountry = [AppUtilityFile getSubstringBeforeAndAfterTheFirstComma:modalObject.strLocation];
    [requestDict setValue:([stateAndCountry count] >= 1)?[stateAndCountry firstObject]:[NSString string] forKey:pState];
    [requestDict setValue:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string] forKey:pCountry];
    
    [self.phonePrefix getPhonePrefixForCountry:([stateAndCountry count] >= 2)?[stateAndCountry lastObject]:[NSString string]];
    
    [requestDict setValue:([modalObject.strPhonePrefix length]) ? modalObject.strPhonePrefix : @"+1" forKey:pCountryCode];
    
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];


    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/signup" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [NSUSERDEFAULT setValue:[result objectForKeyNotNull:pUserId expectedObj:@""] forKey:@"userID"];
            NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
            
            [userInfoDict setValue:modalObject.strEmailAddress forKey:@"userEmail"];
            [userInfoDict setValue:modalObject.strPswrd forKey:@"userPassword"];
            [userInfoDict setValue:@"NO" forKey:@"isOTPVerified"];
            [userInfoDict setValue:@"NO" forKey:@"isRemember"];
            [userInfoDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
            [userInfoDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"user_icon" forKey:@"profileimage" ];
            
            [NSUSERDEFAULT setValue:userInfoDict forKey:@"ClientUserInfoDictionary"];
            
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
