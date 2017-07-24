//
//  SignUpPopUpViewController.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 12/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//


//  SignUpPopUpViewController.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 12/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
#import "SignUpPopUpViewController.h"
#import "AppDelegate.h"
#import "MacroFile.h"
#import "UIViewController+CWPopup.h"
#import "AppUtilityFile.h"
#import "HeaderFile.h"

@interface SignUpPopUpViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpAsClientButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpAsServiceProviderButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewVerticalConstraint;

@property (weak, nonatomic) IBOutlet UIView *viewOuter;

@end

@implementation SignUpPopUpViewController

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:self.viewOuter]anyObject];
    
    if (touch.tapCount) {
        
    }else {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

-(void)initialSetup {
    
    self.viewOuter.layer.cornerRadius = 10.0;
    self.viewOuter.clipsToBounds = YES;
    
     if (SCREEN_HEIGHT == 480) {
         
         //[self.viewHeightConstraint setConstant:300];
         [self.viewWidthConstraint setConstant:260];
  
     }else if (SCREEN_HEIGHT == 568) {
         
         //[self.viewHeightConstraint setConstant:300];
         [self.viewWidthConstraint setConstant:260];
         
     }else if (SCREEN_HEIGHT == 667) {
         
         //[self.viewHeightConstraint setConstant:300];
         [self.viewWidthConstraint setConstant:300];
         
     }else if (SCREEN_HEIGHT == 736) {
         
        // [self.viewHeightConstraint setConstant:300];
         [self.viewWidthConstraint setConstant:360];
         
     }
    
    [_signUpAsClientButton setTitle:KNSLOCALIZEDSTRING(@"Sign Up As Client") forState:UIControlStateNormal];
    [_signUpAsServiceProviderButton setTitle:KNSLOCALIZEDSTRING(@"Sign Up As Service Provider") forState:UIControlStateNormal];

}

#pragma mark  -  UIButton Actions

- (IBAction)cancelButton:(id)sender {
     [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
}

- (IBAction)SignUpAsClientButtonAction:(id)sender {
    [NSUSERDEFAULT setValue:@"YES" forKey:@"isClientSide"];
    [self.delegate callSignUpServiceAgain:self.isComingFromSocial];
    [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpAsServiceACtion:(id)sender {
    [NSUSERDEFAULT setValue:@"NO" forKey:@"isClientSide"];
    [self.delegate callSignUpServiceAgain:self.isComingFromSocial];
    [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
}

@end
