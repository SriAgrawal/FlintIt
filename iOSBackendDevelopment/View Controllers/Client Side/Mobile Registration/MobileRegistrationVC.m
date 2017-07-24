//
//  MobileRegistrationVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "MobileRegistrationVC.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "AlertView.h"
#import "NSDictionary+NullChecker.h"

@interface MobileRegistrationVC ()<UITextFieldDelegate>
{
    UserInfo *modalObject;
}
@property (weak, nonatomic) IBOutlet UILabel *lblMobileRegistration;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *textFieldView;
 
@property (weak, nonatomic) IBOutlet UIButton *reSendButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UITableView *mobileRegistrationTableView;

@property (weak, nonatomic) IBOutlet UITextField *OTPtextField;

@property (weak, nonatomic) IBOutlet UILabel *lblOTP;

@end

@implementation MobileRegistrationVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
    //Call API to save user info on Mongo Dtabase.
    [self requestDictForSignUpOnMongoDb];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods

-(void)initialSetup {
    
    [self.confirmButton setTitle:KNSLOCALIZEDSTRING(@"Confirm") forState:UIControlStateNormal] ;
    [self.reSendButton setTitle:KNSLOCALIZEDSTRING(@"Re-send OTP") forState:UIControlStateNormal];
    _lblOTP.text = KNSLOCALIZEDSTRING(@"Enter OTP sent to your Mobile Device.");
    _lblMobileRegistration.text = KNSLOCALIZEDSTRING(@"Mobile Registration");
    
    //Add Back Button on conditions
    if (self.isComingFromLogin) {
        [self.btnBack setHidden:NO];
    }else {
        [self.btnBack setHidden:YES];
    }
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Set Table Header&Footer
    [self.mobileRegistrationTableView setTableHeaderView:self.headerView];
    [self.mobileRegistrationTableView setTableFooterView:self.footerView];
    
   
    
    self.reSendButton.layer.cornerRadius = 25.0;
    self.confirmButton.layer.cornerRadius = 25.0;
    self.textFieldView.layer.cornerRadius = 25.0;
    self.OTPtextField.layer.cornerRadius = 15.0;

    //Set bounce vertical if required
    [self.mobileRegistrationTableView setAlwaysBounceVertical:NO];
    
    //Set Textfield Placeholder Color
    [self.OTPtextField setPlaceholder:KNSLOCALIZEDSTRING(@"Example 2356")];
    [self.OTPtextField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.lblOTP setAttributedText:[AppUtilityFile getAttributedToAdjustLineSpacingWithAllignment:self.lblOTP.text withSpacing:10]];
    
    [self.OTPtextField setTag:100];
    [self.OTPtextField setDelegate:self];
    
    [self.OTPtextField setFont:[UIFont fontWithName:@"System" size:15.0f]];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
}

#pragma mark - UITextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField *OTPField = APPTEXTFIELD(100);
    if([string isEqualToString:@" "])
    {
        //textFieldString = @"";
        return NO;
    }
    else if (textField == OTPField) {
        if ([textFieldString length] > 4) {
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:KNSLOCALIZEDSTRING(@"Done")
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.OTPtextField.inputAccessoryView = keyboardDoneButtonView;
}

-(void)doneClicked:(UIButton *)doneBtn {
    [self.OTPtextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 100:
            [modalObject setStrOTP:textField.text];
            break;
        default:
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIButton Action

- (IBAction)backButtonAction:(id)sender {
    if (self.isComingFromLogin) {
        [self.navigationController popViewControllerAnimated:YES];

    }else {
       [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)confirmButton:(id)sender {
    [self.view endEditing:YES];
    
    if(modalObject.strOTP == nil || [modalObject.strOTP isEqualToString:@""]) {
         [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the OTP.") onController:self];
    }
//    }else if(![TRIM_SPACE(modalObject.strOTP)  isEqualToString:self.otpNumber]) {
//        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the correct OTP Number.") onController:self];
//    }
    else {
        [self requestDictForVerifyOTP];
    }
}

- (IBAction)reSendButton:(id)sender {
    [self requestDictForResentOTP];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForResentOTP {
  
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/send_otp" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            self.otpNumber = [result objectForKeyNotNull:pOTP expectedObj:@""];
            [[AlertView sharedManager] displayInformativeAlertwithTitle:[NSString string] andMessage:[result objectForKeyNotNull:pResponseMsg expectedObj:@""] onController:self.navigationController];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
}

-(void)requestDictForVerifyOTP {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [requestDict setValue:@"ios" forKey:pDeviceType];
    [requestDict setValue:[self.OTPtextField.text length]?self.OTPtextField.text:[NSString string] forKey:pOTP];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/otp_verification" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]] ;
                [dict setValue:@"YES" forKey:@"isOTPVerified"];

                [NSUSERDEFAULT setValue:dict forKey:@"ClientUserInfoDictionary"];
                [NSUSERDEFAULT synchronize];
            }else {
                NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]] ;
                [dict setValue:@"YES" forKey:@"isOTPVerified"];
                [NSUSERDEFAULT setValue:dict forKey:@"ServiceUserInfoDictionary"];
                [NSUSERDEFAULT synchronize];
            }
            
            [self.navigationController pushViewController:(UIViewController *)[APPDELEGATE addRevealView] animated:YES];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
}

-(void)requestDictForSignUpOnMongoDb {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:self.modalObject.strUsername forKey:pUserName];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:@"userId"];
    NSDictionary *dictUserDefault;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictUserDefault = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictUserDefault = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    
    [requestDict setValue:self.modalObject.strEmailAddress forKey:pEmailID];
    [requestDict setValue:self.modalObject.strGender forKey:pGender];
    [requestDict setValue:[dictUserDefault valueForKey:@"profileimage"] forKey:pProfileImage];
    [requestDict setValue:self.modalObject.strAge forKey:pAge];
    [requestDict setValue:[NSUSERDEFAULT boolForKey:@"isClientSide"]?[NSString stringWithFormat:@"1"]:[NSString stringWithFormat:@"2"]  forKey:pUserType];
    [requestDict setObject:@"ios" forKey:@"deviceType"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"registerDevice" WithComptionBlock:^(id result, NSError *error) {
       
        
    }];
    
}

@end
