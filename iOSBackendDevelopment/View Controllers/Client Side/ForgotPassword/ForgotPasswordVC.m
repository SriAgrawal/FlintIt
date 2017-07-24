//
//  ForgotPasswordVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "AppUtilityFile.h"
#import "UserInfo.h"
#import "AlertView.h"
#import "MacroFile.h"
#import "NSDictionary+NullChecker.h"

@interface ForgotPasswordVC ()<UITextFieldDelegate>
{
    UserInfo *modalObject;
}


@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UITableView *forgotPasswordTableView;

@property (weak, nonatomic) IBOutlet UILabel *lblAboutRecovery;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmation;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *lblForgot;
@property (weak, nonatomic) IBOutlet UILabel *lblEnterEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblForgotPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@end

@implementation ForgotPasswordVC

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

-(void)initialSetup {
    
   // [_emailTextField setPlaceholder:KNSLOCALIZEDSTRING(@"EMAIL")];
    _lblForgot.text = KNSLOCALIZEDSTRING(@"Forgot your Password?");
    _lblForgotPassword.text = KNSLOCALIZEDSTRING(@"Forgot Password");
    _lblAboutRecovery.text = KNSLOCALIZEDSTRING(@"No Need to Worry just type in your E-Mail we will get back to you.");
    _lblEnterEmail.text = KNSLOCALIZEDSTRING(@"Enter Your Email ID");
    _lblConfirmation.text = KNSLOCALIZEDSTRING(@"A Code will be sent to your Email ID.Login with the Code and Change your Password.");
    [self.submitButton setTitle:KNSLOCALIZEDSTRING(@"Submit") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }

    
    //Set TableView Header&Footer View
    [self.forgotPasswordTableView setTableHeaderView:self.headerView];
    [self.forgotPasswordTableView setTableFooterView:self.footerView];
    [self.forgotPasswordTableView setAlwaysBounceVertical:NO];
    
    //Set Layout TextField and Button
    [self.emailTextField.layer setCornerRadius:self.emailTextField.frame.size.height/2];
  //  [self.submitButton.layer setCornerRadius:self.submitButton.frame.size.height/2];
    self.submitButton.layer.cornerRadius = 25.0;
    self.emailTextField.layer.cornerRadius = 25.0;

    
    //Set space between Label Text
    [self.lblAboutRecovery setAttributedText:[AppUtilityFile getAttributedToAdjustLineSpacingWithAllignment:self.lblAboutRecovery.text withSpacing:5]];
    [self.lblConfirmation setAttributedText:[AppUtilityFile getAttributedToAdjustLineSpacingWithAllignment:self.lblConfirmation.text withSpacing:5]];
    
    //Add pading in the search field
    addPading(self.emailTextField);
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    
    [self.emailTextField setTag:100];
    self.emailTextField.delegate=self;
    
    [self.emailTextField setFont:[UIFont fontWithName:@"System" size:15.0f]];

    
    if (SCREEN_HEIGHT == 480) {
        [_lblAboutRecovery setFont:APPFONTREGULAR(14)];
        [_lblConfirmation setFont:APPFONTREGULAR(14)];
    }else if (SCREEN_HEIGHT == 568) {
        [_lblAboutRecovery setFont:APPFONTREGULAR(14)];
        [_lblConfirmation setFont:APPFONTREGULAR(14)];

    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 100:
            [modalObject setStrEmail:textField.text];
            break;
        default:
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helper Method

- (IBAction)submitButton:(id)sender {
    [self.view endEditing:YES];
    NSString *emailReg = @"[A-Z0-9a-z._]+@[A-Za-z]+\\.[A-Za-z]{2,3}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    
    if(modalObject.strEmail == nil || [modalObject.strEmail isEqualToString:@""]) {
         [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the email address.") onController:self];
    }
    else if([emailTest evaluateWithObject:modalObject.strEmail] == NO) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the valid email address.") onController:self];
    }
    else {
        [self requestDictForForgotPassword];
    }

}


- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([string isEqualToString:@" "])
    {
        return NO;
    }else if (textField == _emailTextField) {
        if ([textFieldString length] > 60) {
            return NO;
        }else{
            return YES;
        }
    }
    else{
        
        return YES;
    }
}

#pragma mark - Service Implementation Methods

-(void)requestDictForForgotPassword {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:modalObject.strEmail forKey:pEmailID];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/forgot_password" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]) message:KNSLOCALIZEDSTRING([result objectForKeyNotNull:pData expectedObj:@""]) andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                if(index == 0)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
    }];
    
}


@end
