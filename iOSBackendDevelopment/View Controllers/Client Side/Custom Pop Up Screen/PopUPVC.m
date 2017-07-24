//
//  PopUPVC.m
//  IdeaPlayInterface
//
//  Created by Abhishek Agarwal on 19/04/16.
//  Copyright © 2016 Mobiloitte Technologies. All rights reserved.
//

#import "PopUPVC.h"
#import "AppDelegate.h"
#import "MacroFile.h"
#import "UIViewController+CWPopup.h"
#import "AppUtilityFile.h"

@interface PopUPVC ()<UITextViewDelegate,UITextFieldDelegate>
{
    JobRequest *modalObject;
}

@property (strong, nonatomic) IBOutlet UIView *viewOuter;
@property (strong, nonatomic) IBOutlet UIView *viewOuterPop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYVerticalConstraint;

@property (strong, nonatomic) IBOutlet UITextView *txtView;

@property (strong, nonatomic) IBOutlet UITextField *titleTxtField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTxtField;
@property (strong, nonatomic) IBOutlet UITextField *paidtxtField;

@property (strong, nonatomic) IBOutlet UILabel *lblInstruction;
@property (strong, nonatomic) IBOutlet UILabel *lblTitleService;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblPricePaid;
@property (strong, nonatomic) IBOutlet UILabel *lblOR;

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnCross;
@property (strong, nonatomic) IBOutlet UIButton *btnUse;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *verticalCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *viewOuterHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *viewOuterWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *outerPopWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *outerPopHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *outerPopVerticalCenterConstraint;

@property (weak, nonatomic) IBOutlet UIButton *btnFixedPriceProperty;
@end

@implementation PopUPVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.viewOuter setHidden:YES];
    [self.viewOuterPop setHidden:YES];

    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch;
//    if (self.isCancelRequest) {
//        touch = [[event touchesForView:self.viewOuter] anyObject];
//    }else {
//        touch = [[event touchesForView:self.viewOuterPop] anyObject];
//    }
//    
//    if (touch.tapCount) {
//        
//    }else {
//        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
//    }
//}

#pragma mark - Helper Method

-(void)initialSetup {
    _paidtxtField.placeholder = KNSLOCALIZEDSTRING(@"Price/Hour");
    _lblInstruction.text = KNSLOCALIZEDSTRING(@"Please Give the Reason why do you want to cancel the Job.");
    _lblTitleService.text = KNSLOCALIZEDSTRING(@"Title of the services");
    _lblDescription.text = KNSLOCALIZEDSTRING(@"Description of the Job");
    _lblPricePaid.text = KNSLOCALIZEDSTRING(@"Price to be Paid");
    _lblOR.text = KNSLOCALIZEDSTRING(@"OR");
//      [self.btnUse setTitle:KNSLOCALIZEDSTRING(@"Use 50$") forState:UIControlStateNormal] ;
    NSString * uselabel = KNSLOCALIZEDSTRING(@"Use ");
    NSString *rate = [uselabel stringByAppendingString:[NSString stringWithFormat:@"$%@",self.particularServiceProviderDetailInSendRequest.userPrice] ];

      [self.btnUse setTitle:rate forState:UIControlStateNormal] ;
      [self.btnOK setTitle:KNSLOCALIZEDSTRING(@"OK") forState:UIControlStateNormal] ;

    [_btnCancel setTitle:KNSLOCALIZEDSTRING(@"Cancel Job") forState:UIControlStateNormal];
    //Alloc Modal Class Object
    modalObject = [[JobRequest alloc]init];
    
    //Set Layout of Button,View,TextField and TextView
    self.viewOuter.layer.cornerRadius = 10.0;
    self.viewOuter.clipsToBounds = YES;
    
    self.viewOuterPop.layer.cornerRadius = 10.0;
    self.viewOuterPop.clipsToBounds = YES;
    
    self.txtView.layer.cornerRadius = 10.0;
    self.txtView.clipsToBounds = YES;
    
    self.btnCancel.layer.cornerRadius = 10.0;
    self.btnCancel.clipsToBounds = YES;
    
    self.btnOK.layer.cornerRadius = 10.0;
    self.btnOK.clipsToBounds = YES;
    
    self.titleTxtField.layer.cornerRadius = 20.0;
    self.titleTxtField.clipsToBounds = YES;
    
    self.descriptionTxtField.layer.cornerRadius = 20.0;
    self.descriptionTxtField.clipsToBounds = YES;
    
    self.paidtxtField.layer.cornerRadius = 20.0;
    self.paidtxtField.clipsToBounds = YES;

    addPading(self.titleTxtField);
    addPading(self.paidtxtField);
    addPading(self.descriptionTxtField);

    //Hide one view
    if (self.isCancelRequest) {
        [self.viewOuter setHidden:NO];
    }else {
        [self.viewOuterPop setHidden:NO];
    }
    
    if (SCREEN_HEIGHT == 480) {
        [self.viewOuterHeightConstraint setConstant:300];
        [self.viewOuterWidthConstraint setConstant:250];
        [self.outerPopHeightConstraint setConstant:300];
        [self.outerPopWidthConstraint setConstant:250];

    }else if (SCREEN_HEIGHT == 568) {
        [self.viewOuterHeightConstraint setConstant:300];
        [self.viewOuterWidthConstraint setConstant:250];
        [self.outerPopHeightConstraint setConstant:300];
        [self.outerPopWidthConstraint setConstant:250];
        
    }else if (SCREEN_HEIGHT == 667) {
        [self.viewOuterHeightConstraint setConstant:350];
        [self.viewOuterWidthConstraint setConstant:300];
        [self.outerPopHeightConstraint setConstant:350];
        [self.outerPopWidthConstraint setConstant:300];
        
    }else if (SCREEN_HEIGHT == 736) {
        [self.viewOuterHeightConstraint setConstant:400];
        [self.viewOuterWidthConstraint setConstant:350];
        [self.outerPopHeightConstraint setConstant:300];
        [self.outerPopWidthConstraint setConstant:250];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.viewOuterPop addGestureRecognizer:tap];
    if (SCREEN_WIDTH == 320) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    
}
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification
{

    [self.view layoutIfNeeded];
    _centerYVerticalConstraint.constant = -80.0f;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view layoutIfNeeded];
    _centerYVerticalConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark  -  UIButton Actions

- (IBAction)cancelJobBtnAction:(id)sender {
    [self.view endEditing:YES];
    if ([TRIM_SPACE(_txtView.text) length]) {
        [self requestDictForCancelJobRequest];
    }else {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please give some reason.") onController:[APPDELEGATE navController]];
    }
   
}

- (IBAction)crossBtnAction:(id)sender {
    [self.view endEditing:YES];

    [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
}

- (IBAction)okBtnAction:(id)sender {
    [self.view endEditing:YES];
    if (self.isCancelRequest) {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
    }else {
        if ([TRIM_SPACE(modalObject.jobTitle)  length] == 0) {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the job title.") onController:self];
        }else if ([TRIM_SPACE(modalObject.pricePaid)  length] == 0 && ![self.btnFixedPriceProperty isSelected]) {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please either enter the price or select the default price rate.") onController:self];
        }else
           [self requestDictForJobRequest];
    }
}

#pragma mark - UIText View Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat constraintValue;
    
    if (SCREEN_HEIGHT == 480) {
        constraintValue = -100;
    }else if (SCREEN_HEIGHT == 568) {
        constraintValue  = -80;
    }else if (SCREEN_HEIGHT == 667) {
        constraintValue = -70;
    }else {
        constraintValue = -50;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.verticalCenterConstraint setConstant:constraintValue];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([text isEqualToString:@" "]) {
        if ((textView == _txtView && range.location != 0)) {
            return YES;
        }
        return NO;
    }else if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else if (textView ==  _txtView) {
        if (![text isEqualToString:@""]) {
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

#pragma mark -***************** Button Action & Selector Method ****************-
- (void)doneClicked:(UIButton *)doneBtn {
    [self.view endEditing:YES];
    [self.paidtxtField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 102) {
        [self.btnFixedPriceProperty setSelected:NO];
    }
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexible,doneButton, nil]];

    self.paidtxtField.inputAccessoryView = keyboardDoneButtonView;
    
//    if (SCREEN_WIDTH == 320) {
//        [self.view layoutIfNeeded];
//        _centerYVerticalConstraint.constant = -80.0f;
//        [UIView animateWithDuration:0.5 animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    }
//    else {
//        [self.view layoutIfNeeded];
//        _infoLabelCenterYConstraint.constant = -80.0f;
//        [UIView animateWithDuration:0.5 animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    }
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
////    if (textField == _phoneNumberTextField) {
////        userObj.strCustomerMobileNumber = TRIM_SPACE(_phoneNumberTextField.text);
////    }
////    else {
////        userObj.strCustomerFullName = TRIM_SPACE(_fullNameTextField.text);
////    }
////    
////    [self.view layoutIfNeeded];
////    _infoLabelCenterYConstraint.constant = 0.0f;
////    [UIView animateWithDuration:0.5 animations:^{
////        [self.view layoutIfNeeded];
////    }];
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField returnKeyType] == UIReturnKeyNext) {
        
        [[self.view viewWithTag:textField.tag+1] becomeFirstResponder];
        return NO;
    }
    else
        [textField resignFirstResponder];
    
    return YES;
}



-(void)textFieldDidEndEditing:(UITextField *)textField {
    CGFloat constraintValue;
        switch (textField.tag) {
            case 100:
                [modalObject setJobTitle:textField.text];
                break;
            case 101:
                [modalObject setJobDecription:textField.text];
                break;
            case 102:{
                [modalObject setPricePaid:textField.text];
//                if (SCREEN_WIDTH == 320) {
//                    [self.view layoutIfNeeded];
//                    _centerYVerticalConstraint.constant = 0.0f;
//                    [UIView animateWithDuration:0.5 animations:^{
//                        [self.view layoutIfNeeded];
//                    }];
//                }
            }
                break;
            default:
                break;
        }
   
    if (SCREEN_HEIGHT == 480) {
        constraintValue = -100;
    }else if (SCREEN_HEIGHT == 568) {
        constraintValue  = -80;
    }else if (SCREEN_HEIGHT == 667) {
        constraintValue = -70;
    }else {
        constraintValue = -50;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.outerPopVerticalCenterConstraint setConstant:constraintValue];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
    
}


#pragma mark - UITextField delegate methods

//client
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([string isEqualToString:@" "])
    {
        if ((textField ==  _titleTxtField && range.location != 0) || (textField == _descriptionTxtField && range.location != 0)|| (textField == _paidtxtField && range.location != 0)) {
            return YES;
        }
        return NO;
    }else
    {
        if (textField.tag == 100) {
            if ([textFieldString length] > 50) {
                if ([string isEqualToString:@""]){
                    return YES;
                }
                return NO;
            }else{
                return YES;
            }
        }
        else if (textField.tag == 101) {
            if ([textFieldString length] > 100) {
                if ([string isEqualToString:@""]){
                    return YES;
                }
                return NO;
            }else{
                return YES;
            }
        }
        else if (textField.tag == 102) {
            if ([textFieldString length] > 6) {
                if ([string isEqualToString:@""]){
                    return YES;
                }
                return NO;
            }else{
                return YES;
            }
        }
    }
    
    return YES;
}
- (IBAction)checkboxAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        modalObject.pricePaid = self.particularServiceProviderDetailInSendRequest.userPrice;
    }else  {
        modalObject.pricePaid = [NSString string];
    }
    
    UITextField *txtfield = APPTEXTFIELD(102);
    (btn.selected)?[txtfield setText:[NSString string]]:[txtfield setText:txtfield.text];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForJobRequest {
    

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
    [requestDict setValue:self.particularServiceProviderDetailInSendRequest.userID forKey:pServicePrividerID];
    [requestDict setValue:modalObject.jobTitle forKey:pJobName];
    [requestDict setValue:modalObject.jobDecription.length?modalObject.jobDecription:@"" forKey:pJobDescription];
    [requestDict setValue:modalObject.pricePaid forKey:pPrice];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/job_request" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [self.delegate comingFromSendRequestWithJobId:[result objectForKeyNotNull:@"job_id"]];
            [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
        
    }];
    
}

-(void)requestDictForCancelJobRequest {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:self.particularServiceProviderDetailInSendRequest.clientID forKey:pClientID];
    [requestDict setValue:_particularServiceProviderDetailInSendRequest.jobID forKey:pJobId];
    [requestDict setValue:_particularServiceProviderDetailInSendRequest.ServiceProviderId forKey:pServicePrividerID];
    [requestDict setValue:_txtView.text forKey:pCancelRegion];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/cancel_job_request" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            [self.navigationController dismissPopupViewControllerAnimated:YES completion:^{
                [self.delegate comingFromRequest];
            }];
        }else
        {            
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Error!") message:error.localizedDescription andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self.navigationController dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                [self.navigationController dismissPopupViewControllerAnimated:YES completion:^{
                    [self.delegate comingFromRequest];
                }];
//                if ([[result objectForKeyNotNull:@"response_message"] isEqualToString:KNSLOCALIZEDSTRING(@"Job already canceled.")]) {
//                    [self.navigationController dismissPopupViewControllerAnimated:YES completion:^{
//                        [self.delegate comingFromRequest];
//                    }];
//                }
            }];
  
        }
    }];

}

-(void)dealloc{
    if (SCREEN_WIDTH == 320) {
        [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidHideNotification];
        [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidShowNotification];
    }
}


@end
