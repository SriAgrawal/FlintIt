//
//  LoginVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 23/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"
#import "NSString+CC.h"
#import <Crashlytics/Crashlytics.h>


static NSString *identifier = @"LoginCell";
static NSString * const kClientId = @"653984298938-kssncv9bvjh9b2281ok92i9sj5mm22ju.apps.googleusercontent.com";
//emailID=qc1.mobiloitte@gmail.com
//password=Mobiloitte123@


@interface LoginVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,GIDSignInDelegate,GIDSignInUIDelegate,FBSDKGraphRequestConnectionDelegate,MBProgressHUDDelegate>
{
    UserInfo *modalObject;
    MBProgressHUD *HUD;
    NSString *mymobileNO;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underLineLabelCenterXConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineLabelCenterXConstantArabic;

@property (weak, nonatomic) IBOutlet UITableView *loginTableView;

@property (strong, nonatomic) IBOutlet UIView *loginHeader;
@property (strong, nonatomic) IBOutlet UIView *loginFooter;

@property (weak, nonatomic) IBOutlet UIButton *rememberButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *googlePlusButton;

@property (weak, nonatomic) IBOutlet UIView *lowerView;

@property (weak, nonatomic) IBOutlet MZSelectableLabel *lblSignUp;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblChooseRole;

@property (weak, nonatomic) IBOutlet UIButton *btnChooseRole;
@property (weak, nonatomic) IBOutlet UIButton *login_Button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineLabelWidthConstraint;

@end

@implementation LoginVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        NSMutableDictionary *dict = [NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"];
        
        if ([[dict valueForKey:@"isRemember"] isEqualToString:@"YES"] && [[NSUSERDEFAULT valueForKey:@"userID"] integerValue]) {
            [self.rememberButton setSelected:YES];
            modalObject.strEmail = [dict valueForKey:@"userEmail"];
            modalObject.strPassword = [dict valueForKey:@"userPassword"];
        }else {
            [self.rememberButton setSelected:NO];
            modalObject.strEmail = [NSString string];
            modalObject.strPassword = [NSString string];
        }
    }else {
        if ([[NSUSERDEFAULT valueForKey:@"userID"] integerValue]) {
            NSMutableDictionary *dict = [NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"];
            
            if ([[dict valueForKey:@"isRemember"] isEqualToString:@"YES"]) {
                [self.rememberButton setSelected:YES];
                modalObject.strEmail = [dict valueForKey:@"userEmail"];
                modalObject.strPassword = [dict valueForKey:@"userPassword"];
            }else {
                [self.rememberButton setSelected:NO];
                modalObject.strEmail = [NSString string];
                modalObject.strPassword = [NSString string];
            }
        }

    }
    
    // set data from remember me
    if ([[NSUSERDEFAULT valueForKey:@"remeberCheck"] isEqualToString:@"YES"]) {
        
        NSMutableDictionary * userDict = [NSUSERDEFAULT valueForKey:@"rememberUserData"];
        [self.rememberButton setSelected:YES];
        modalObject.strEmail = [userDict valueForKey:@"userEmail"];
        modalObject.strPassword = [userDict valueForKey:@"userPassword"];
    }
    
//    [self checkLocationStatus];
    [self.loginTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    if (SCREEN_WIDTH >320) {
        _loginTableView.scrollEnabled = NO;
    }
    [self.login_Button setTitle:KNSLOCALIZEDSTRING(@"Log In") forState:UIControlStateNormal] ;
    [self.rememberButton setTitle:KNSLOCALIZEDSTRING(@"Remember me") forState:UIControlStateNormal] ;
    [self.btnChooseRole setTitle:KNSLOCALIZEDSTRING(@"Choose Your Role") forState:UIControlStateNormal] ;
    [self.forgotButton setTitle:KNSLOCALIZEDSTRING(@"Forgot password?") forState:UIControlStateNormal] ;
    _orLabel.text = KNSLOCALIZEDSTRING(@"OR");
    _lblSignUp.text = KNSLOCALIZEDSTRING(@"If YOU ARE NEW USER Sign Up?");
    _lblChooseRole.text = KNSLOCALIZEDSTRING(@"Login and get your job done with a single tap.");
    [_btnChooseRole setHidden:YES];
    
    //Register tableView Cell
    [self.loginTableView registerNib:[UINib nibWithNibName:@"LoginCell" bundle:nil] forCellReuseIdentifier:@"LoginCell"];
    
    //Set Table Header&Footer
    [self.loginTableView setTableHeaderView:self.loginHeader];
    [self.loginTableView setTableFooterView:self.loginFooter ];
    
    //Bounce table vertical if required
    [self.loginTableView setAlwaysBounceVertical:NO];

    //Set Corner Radius of Button
   // [self.login_Button.layer setCornerRadius:self.login_Button.frame.size.height/2];
    self.login_Button.layer.cornerRadius = 25.0;

    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    
    [self.lowerView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.65]];
    //Set Range and make SignUp tapable
    [self.lblSignUp setSelectableRange:[[self.lblSignUp.attributedText string] rangeOfString:@" Sign Up?"]];
    // "هل انت مستخدم جديد؟ سجل معنا"
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        _underlineLabelCenterXConstantArabic.constant = -55;
        [self.lblSignUp setSelectableRange:[[self.lblSignUp.attributedText string] rangeOfString:@"؟ سجل معنا"]];
    }
    else if ([language isEqualToString:@"es"]) {
        [self.lblSignUp setSelectableRange:[[self.lblSignUp.attributedText string] rangeOfString:@"Suscríbete ?"]];
        _underlineLabelCenterXConstantArabic.constant = -55;
        _underlineLabelWidthConstraint.constant = 90;
        
    }

//    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
//    if ([language isEqualToString:@"ar"])
    
    self.lblSignUp.selectionHandler = ^(NSRange range, NSString *string) {
        
        NSLog(@"lat----%@",[APPDELEGATE latitude]);
        NSLog(@"long----%@",[APPDELEGATE longitude]);
        
        if ([[APPDELEGATE latitude] isEqualToString:@"0.00000000"] && [[APPDELEGATE longitude] isEqualToString:@"0.00000000"]) {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Enable Location Service") andMessage:KNSLOCALIZEDSTRING(@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services") onController:self];


        }else{
            SignUpPopUpViewController *popOver = [[SignUpPopUpViewController alloc]initWithNibName:@"SignUpPopUpViewController" bundle:nil];
            popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            popOver.modalPresentationStyle =  UIModalPresentationFormSheet;
            popOver.delegate = self;
            popOver.isComingFromSocial = NO;
            [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
        }
        
//        if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
//            SignUpVC *signUpObj = [[SignUpVC alloc]initWithNibName:@"SignUpVC" bundle:nil];
//            [self.navigationController pushViewController:signUpObj animated:YES];
//        }else {
//            SignUpViewController *signUpObj = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
//            [self.navigationController pushViewController:signUpObj animated:YES];
//        }
    };
    
    if (SCREEN_WIDTH == 320) {
        [self.forgotButton.titleLabel setFont:APPFONTREGULAR(12)];
        [self.rememberButton.titleLabel setFont:APPFONTREGULAR(12)];
    }
    
    mymobileNO = @"9572147370";
}


//-(void)checkLocationStatus {
//    
//    if ((([INTULocationManager locationServicesState] == INTULocationServicesStateDisabled) || ([INTULocationManager locationServicesState] == INTULocationServicesStateDenied)) && (![[APPDELEGATE str_location] length])) {
//        
//        
//        
//        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to enable your GPS location?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
//            
//            if (index == 0 ) {
//                
//                [self checkLocationStatus];
//                
//                
//                
//            }else if (index == 1){
//                
//                if (& UIApplicationOpenSettingsURLString != NULL) {
//                    
//                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                    
//                    [[UIApplication sharedApplication] openURL:url];
//                    
//                }
//                
//                else {
//                    
//                    // Present some dialog telling the user to open the settings app.
//                    
//                }
//            }
//        }];
//        
//    }
//}

-(void)isAllFieldVerified {

    if((modalObject.strEmail == nil || [modalObject.strEmail isEqualToString:@""]) &&(modalObject.strPassword == nil || [modalObject.strPassword isEqualToString:@""])) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter email or password.") onController:self];
    }
    else if(modalObject.strEmail == nil || [modalObject.strEmail isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the email address.") onController:self];
    }
    else if(![modalObject.strEmail isValidEmail]) {
        //    else if([emailTest evaluateWithObject:modalObject.strEmail] == NO) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter  a valid email address.") onController:self];
    }
    else if(modalObject.strPassword == nil || [modalObject.strPassword isEqualToString:@""])
    {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the password.") onController:self];
    }
    else if((modalObject.strPassword.length < 6) ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Password must be of atleast 6 characters.") onController:self];
    }
    else if ((![modalObject.strEmail isValidEmail] )  && (modalObject.strPassword.length < 6)) {
        //    else if (([emailTest evaluateWithObject:modalObject.strEmail] == NO)  && (modalObject.strPassword.length < 6)) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Invalid email or Password.") onController:self];
    }
    else {
        [self requestDictForLogin];
    }

}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LoginCell *cell = (LoginCell *)[self.loginTableView dequeueReusableCellWithIdentifier:identifier];
    
     [cell.cellTextField setTag:indexPath.row+100];
    [cell.cellTextField setDelegate:self];
    [cell.cellTextField setReturnKeyType:UIReturnKeyNext];
    [cell.cellTextField setTextAlignment:NSTextAlignmentCenter];
    
    switch (indexPath.row) {
        case 0: {
            [cell.cellTextField setPlaceholder:KNSLOCALIZEDSTRING(@"EMAIL")];
            [cell.cellTextField setText:modalObject.strEmail];
            [cell.cellTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
            [cell.cellTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        }
            break;
        case 1: {
            [cell.cellTextField setPlaceholder:KNSLOCALIZEDSTRING(@"PASSWORD")];
            [cell.cellTextField setText:modalObject.strPassword];
            [cell.cellTextField setReturnKeyType:UIReturnKeyDone];
            [cell.cellTextField setSecureTextEntry:YES];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

#pragma mark - UITextField delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField *passwordField = APPTEXTFIELD(101);
    UITextField *emailTextField = APPTEXTFIELD(100);

    
    if([string isEqualToString:@" "])
    {
        //textFieldString = @"";
        return NO;
    }else{
        if (textField == passwordField) {
            if ([textFieldString length] > 15) {
                return NO;
            }else{

                return YES;
            }
            return YES;

        }
        if (textField == emailTextField)
        {
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
    }
    return YES;
}

- (BOOL)validateEmailCharacter:(NSString *)nameStr {
    //    NSString *emailRegex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
    NSString *emailRegex =@"^[0-9a-zA-Z!-~]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:nameStr];
    return isValid;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.returnKeyType == UIReturnKeyNext) {
        [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        return NO;
    }
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 100:
            [modalObject setStrEmail:textField.text];
            break;
        case 101:
            [modalObject setStrPassword:textField.text];
            break;
        default:
            break;
    }
}

#pragma mark - UIButton's Action

- (IBAction)btnChooseRole:(id)sender {
   // [self.navigationController popViewControllerAnimated:YES];
  
       // [[Crashlytics sharedInstance] crash];

}

- (IBAction)rememberButtonAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
        
        if (btn.selected) {
            [dict setValue:@"YES" forKey:@"isRemember"];
            [NSUSERDEFAULT setValue:@"YES" forKey:@"remeberCheck"];
        }else{
            [dict setValue:@"NO" forKey:@"isRemember"];
            [NSUSERDEFAULT setValue:@"NO" forKey:@"remeberCheck"];


        }
        
        [NSUSERDEFAULT setValue:dict forKey:@"ClientUserInfoDictionary"];
        [NSUSERDEFAULT synchronize];
    }else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];

        if (btn.selected) {
            [dict setValue:@"YES" forKey:@"isRemember"];
            [NSUSERDEFAULT setValue:@"YES" forKey:@"remeberCheck"];

        }else{
            [dict setValue:@"NO" forKey:@"isRemember"];
            [NSUSERDEFAULT setValue:@"NO" forKey:@"remeberCheck"];


        }
        [NSUSERDEFAULT setValue:dict forKey:@"ServiceUserInfoDictionary"];
        [NSUSERDEFAULT synchronize];

    }
}

- (IBAction)forgotPassButtonAction:(id)sender {
    ForgotPasswordVC *forgotObj = [[ForgotPasswordVC alloc]initWithNibName:@"ForgotPasswordVC" bundle:nil];
    [self.navigationController pushViewController:forgotObj animated:YES];
}

- (IBAction)loginButtonAction:(id)sender {
    [self.view endEditing:YES];
       [self isAllFieldVerified];
   }

-(void)methodForNavigateToHome {
    [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
}

- (IBAction)twitterButtonAction:(id)sender {    
    if ([APPDELEGATE isReachable]) {
        [self addHud];
        //  NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [self removeHud];

        [[Twitter sharedInstance] logInWithMethods:TWTRLoginMethodWebBased completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
            if (session) {
                NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
                
                TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
                
                [self addHud];
                [client loadUserWithID:userID completion:^(TWTRUser *user, NSError *error) {
                    [self removeHud];
                    if(user){
                        NSString *urlString = [[NSString alloc]initWithString:user.profileImageLargeURL];
                        //                         NSURL *url = [[NSURL alloc]initWithString:urlString];
                        //                         NSData *pullTwitterPP = [[NSData alloc]initWithContentsOfURL:url];
                        //                         UIImage *profImage = [UIImage imageWithData:pullTwitterPP];
                        NSString *imageStr = [urlString getBase64StringFromURI];
                        NSString *str = [[user.name lowercaseString]stringByReplacingOccurrencesOfString:@" " withString:@""];
                        modalObject.strEmail =([NSString stringWithFormat:@"%@@twyst.com",str]);
                        modalObject.strUsername = [user valueForKey:@"name"];
                        modalObject.strUserID = [user valueForKey:@"userID"];
                        modalObject.strUpload = imageStr;
                        modalObject.strSocialType = @"twitter";
                        
                        [self callAPIForSocialLogin:modalObject andUserType:[NSString string]];
                    }
                }];
            }
            else {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        }];
    }else{
        
    }
}

- (IBAction)facebookButtonAction:(id)sender {
        [[SocialHelper sharedManager] getFacebookInfoWithCompletionHandler:^(NSDictionary *dict, NSString *error) {
        
            if (!error) {
                if (dict) {
                    NSDictionary *dict_pic = [dict objectForKeyNotNull:@"picture" expectedObj:[NSDictionary dictionary]];
                     NSDictionary *dict_data = [dict_pic objectForKeyNotNull:@"data" expectedObj:[NSDictionary dictionary]];
                    NSString *imgStr = [dict_data valueForKey:@"url"];
                    
                    NSString *imageStr = [imgStr getBase64StringFromURI];
                    
                    modalObject.strEmail = ([[dict valueForKey:@"email"] length])?([dict valueForKey:@"email"]):([NSString stringWithFormat:@"%@.%@%@@gmail.com",[dict valueForKey:@"first_name"],[dict valueForKey:@"last_name"],[dict valueForKey:@"id"]]);
                    modalObject.strUsername = [dict valueForKey:@"name"];
                    modalObject.strUserID = [dict valueForKey:@"id"];
                    modalObject.strUpload = imageStr;
                    modalObject.strSocialType = @"facebook";
                    
                    [self callAPIForSocialLogin:modalObject andUserType:[NSString string]];
                }else{
                    if (error) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"Error in login to facebook.") onController:self.navigationController];
                    }
                }
            }else{
            }
        }];
    }

- (IBAction)googlePlusButonAction:(id)sender {
    [self addHud];
    [[GIDSignIn sharedInstance] disconnect];
    
    [self removeHud];
    
      [[GIDSignIn sharedInstance] signIn];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    [self removeHud];
    if (user) {
        NSString *userId = user.userID;
        NSString *fullName = user.profile.name;
        NSString *email = user.profile.email;
        NSString *imageStr;
        
        if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
        {
            //NSUInteger dimension = round(thumbSize.width * [[UIScreen mainScreen] scale]);
            NSString *imageURL = [[user.profile imageURLWithDimension:0] absoluteString];
            imageStr = [imageURL getBase64StringFromURI];
        }
        
        modalObject.strEmail = ([email length])?email:[NSString stringWithFormat:@"%@@gmail.com",fullName];    modalObject.strUsername = fullName;
        modalObject.strUserID = userId;
        modalObject.strUpload = imageStr;
        modalObject.strSocialType = @"google";
        
        [self callAPIForSocialLogin:modalObject andUserType:[NSString string]];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
    [self removeHud];
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    [self removeHud];

}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [self removeHud];

    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self removeHud];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addHud {
    //add HUD to the passed view controller's view
    [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] animated:YES];
    
    
}

-(void)removeHud {
    
    [MBProgressHUD hideHUDForView:[APPDELEGATE window] animated:YES];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForLogin {
    
  
 
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:modalObject.strEmail forKey:pEmailID];
    [requestDict setValue:modalObject.strPassword  forKey:pPassword];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/login" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            // added to remember
            if ([[NSUSERDEFAULT valueForKey:@"remeberCheck"] isEqualToString:@"YES"]) {
                NSMutableDictionary * rememberDict = [NSMutableDictionary new];
                [rememberDict setValue:modalObject.strEmail forKey:@"userEmail"];
                [rememberDict setValue:modalObject.strPassword forKey:@"userPassword"];
                [NSUSERDEFAULT setValue:rememberDict forKey:@"rememberUserData"];
                [NSUSERDEFAULT synchronize];
            }
            
            
            [NSUSERDEFAULT setBool:0 forKey:@"isSocialLogin"];
            BOOL isNumberVerified = [[result objectForKeyNotNull:pStatus expectedObj:@""] boolValue];
            NSString *OTPNumber = [result objectForKeyNotNull:pOTP expectedObj:@""];
            NSString *regiteredUserType = [result objectForKeyNotNull:pUserType expectedObj:@""];
            if ([TRIM_SPACE(regiteredUserType)  isEqualToString:@"1"]) {
                [NSUSERDEFAULT setBool:YES forKey:@"isClientSide"];
            }else {
                [NSUSERDEFAULT setBool:NO forKey:@"isClientSide"];
            }
            [NSUSERDEFAULT setValue:[result objectForKeyNotNull:pUserId expectedObj:@""] forKey:@"userID"];

            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
                [clientDict setValue:modalObject.strEmail forKey:@"userEmail"];
                [clientDict setValue:modalObject.strPassword forKey:@"userPassword"];
                [clientDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
                [clientDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
                [clientDict setValue:(isNumberVerified)?@"YES":@"NO" forKey:@"isOTPVerified"];
                [NSUSERDEFAULT setValue:clientDict forKey:@"ClientUserInfoDictionary"];
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[clientDict valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];
            }
            else {
                NSMutableDictionary *serviceDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
                [serviceDict setValue:modalObject.strEmail forKey:@"userEmail"];
                [serviceDict setValue:modalObject.strPassword forKey:@"userPassword"];
                [serviceDict setValue:(isNumberVerified)?@"YES":@"NO" forKey:@"isOTPVerified"];
                [serviceDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
                [serviceDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
                [NSUSERDEFAULT setValue:serviceDict forKey:@"ServiceUserInfoDictionary"];
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[serviceDict valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];
            }
            [NSUSERDEFAULT synchronize];
            if (isNumberVerified) {
                [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
                [self requestDictForSignUpOnMongoDb:result];
            }else {
                MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                registrationObj.isComingFromLogin = YES;
                registrationObj.delegate = self;
                registrationObj.otpNumber = OTPNumber;
                [self.navigationController pushViewController:registrationObj animated:YES];
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}

-(void)callAPIForSocialLogin:(UserInfo *)obj andUserType:(NSString *)userType {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[APPDELEGATE latitude] forKey:pLattitue];
    [requestDict setValue:[APPDELEGATE longitude] forKey:pLongitute];
    [requestDict setValue:modalObject.strEmail forKey:pEmailID];
    [requestDict setValue:modalObject.strUsername forKey:pUserName];
    [requestDict setValue:modalObject.strUserID forKey:pSocialID];
    [requestDict setValue:modalObject.strSocialType forKey:pSocialType];
    
    [requestDict setValue:modalObject.strUpload forKey:pProfileImage];
    [requestDict setValue:userType forKey:pUserType];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setObject:@"ios" forKey:pDeviceType];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/social_login" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            [NSUSERDEFAULT setBool:1 forKey:@"isSocialLogin"];
            [NSUSERDEFAULT setValue:[result objectForKeyNotNull:pUserId expectedObj:@""] forKey:@"userID"];
            
            BOOL isNumberVerified = [[result objectForKeyNotNull:pStatus expectedObj:@""] boolValue];
            NSString *phoneNumberString = [result objectForKeyNotNull:pContactNumber expectedObj:@""];
            NSString *regiteredUserType = [result objectForKeyNotNull:pUserType expectedObj:@""];
            
            if ([TRIM_SPACE(regiteredUserType)  isEqualToString:@"1"]) {
                [NSUSERDEFAULT setBool:YES forKey:@"isClientSide"];
            }else if ([TRIM_SPACE(regiteredUserType)  isEqualToString:@"2"]){
                [NSUSERDEFAULT setBool:NO forKey:@"isClientSide"];
            }
            
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
                [clientDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username" ];
                [clientDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
                [clientDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"userEmail"];
                //  [clientDict setValue:modalObject.strEmail forKey:@"userEmail"];
                //                            [clientDict setValue:modalObject.strPassword forKey:@"userPassword"];
                //                [clientDict setValue:@"YES" forKey:@"isOTPVerified"];
                
                [clientDict setValue:(isNumberVerified)?@"YES":@"NO" forKey:@"isOTPVerified"];

                [NSUSERDEFAULT setValue:clientDict forKey:@"ClientUserInfoDictionary"];
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[clientDict valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];
                
            }else {
                NSMutableDictionary *serviceDict = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
                [serviceDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"username"];
                [serviceDict setValue:[[result objectForKeyNotNull:@"profile_image"] length]?[result objectForKeyNotNull:@"profile_image"]:@"" forKey:@"profileimage" ];
                [serviceDict setValue:[result objectForKeyNotNull:@"user_name"] forKey:@"userEmail"];
                //[serviceDict setValue:modalObject.strEmail forKey:@"userEmail"];
                //[serviceDict setValue:modalObject.strPassword forKey:@"userPassword"];
                //[serviceDict setValue:(isNumberVerified)?@"NO":@"YES" forKey:@"isOTPVerified"];
                //                [serviceDict setValue:@"YES" forKey:@"isOTPVerified"];
                
                [serviceDict setValue:(isNumberVerified)?@"YES":@"NO" forKey:@"isOTPVerified"];
                [NSUSERDEFAULT setValue:serviceDict forKey:@"ServiceUserInfoDictionary"];
                UIImageView *imgView = [[UIImageView alloc] init];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[serviceDict valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];
            }
            
            if ([TRIM_SPACE(regiteredUserType) length]) {
                if ([TRIM_SPACE(phoneNumberString) length])   {
                    if ([[result objectForKeyNotNull:pStatus expectedObj:@""] boolValue]) {
                        [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];
                        [self requestDictForSignUpOnMongoDb:result];
                        
                    }else{
                        MobileRegistrationVC *registrationObj = [[MobileRegistrationVC alloc]initWithNibName:@"MobileRegistrationVC" bundle:nil];
                        registrationObj.isComingFromLogin = NO;
                        registrationObj.otpNumber = [result objectForKeyNotNull:pOTP expectedObj:@""];
                        [self.navigationController pushViewController:registrationObj animated:YES];
                    }
                }
                else    {
                    modalObject = [UserInfo parseResponseForProfileDetail:result];
                    [self requestDictForSignUpOnMongoDb:result];
                    
                    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                        EditProfileVC *editObj = [[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
                        editObj.editModalObject = modalObject;
                        editObj.isComingFromSocialLogin = YES;
                        [self.navigationController pushViewController:editObj animated:YES];
                    }else {
                        EditProfileViewController *editObj = [[EditProfileViewController alloc]initWithNibName:@"EditProfileViewController" bundle:nil];
                        editObj.modalObject = modalObject;
                        editObj.isComingFromSocialLogin = YES;
                        [self.navigationController pushViewController:editObj animated:YES];
                    }
                    
                }
            }else {
                SignUpPopUpViewController *popOver = [[SignUpPopUpViewController alloc]initWithNibName:@"SignUpPopUpViewController" bundle:nil];
                popOver.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                popOver.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                popOver.modalPresentationStyle =  UIModalPresentationFormSheet;
                popOver.delegate = self;
                popOver.isComingFromSocial = YES;
                [self.navigationController presentPopupViewController:popOver animated:YES WithAlpha:0.1 completion:nil];
            }
            
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}

-(void)requestDictForSignUpOnMongoDb:(NSDictionary *)response {
    
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[response objectForKeyNotNull:@"user_name"] forKey:pUserName];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    NSDictionary *dictUserDefault;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictUserDefault = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictUserDefault = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    
    [requestDict setValue:modalObject.strEmail forKey:pEmailID];
    [requestDict setValue:[response objectForKeyNotNull:@"gender"] forKey:pGender];
    [requestDict setValue:[dictUserDefault valueForKey:@"profileimage"] forKey:pProfileImage];
    [requestDict setValue:[response objectForKeyNotNull:@"age"] forKey:pAge];
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setObject:@"ios" forKey:@"deviceType"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"registerDevice" WithComptionBlock:^(id result, NSError *error) {
        
    }];

}



-(void)callSignUpServiceAgain:(BOOL)isComingFromSocialLogin {
    if (isComingFromSocialLogin) {
        NSString *userType = [NSUSERDEFAULT boolForKey:@"isClientSide"]?@"1":@"2";
        [self callAPIForSocialLogin:modalObject andUserType:userType];
    }else {
        if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
            SignUpVC *sisnUpAsClientObj = [[SignUpVC alloc]initWithNibName:@"SignUpVC" bundle:nil];
            [self.navigationController pushViewController:sisnUpAsClientObj
                                                 animated:YES];
        }else {
            SignUpViewController *sisnUpAsServiceObj = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
            [self.navigationController pushViewController:sisnUpAsServiceObj
                                                 animated:YES];
        }
    }
}

@end
