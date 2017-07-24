//
//  SelectLanguageVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 22/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//
#import "SelectLanguageVC.h"
#import "LoginVC.h"
#import "SignUpVC.h"
#import "MacroFile.h"
#import "OptionsPickerSheetView.h"
#import "SignUpViewController.h"

@interface SelectLanguageVC ()

//Button Outlet
@property (weak, nonatomic) IBOutlet UIButton *btnPropertyClientLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnPropertyClientSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnPropertyServiceProviderLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnPropertyServiceProviderSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnPropertyOptionLanguage;

//Label Outlet
@property (weak, nonatomic) IBOutlet UILabel *lblSelectLanguage;
@property (weak, nonatomic) IBOutlet UILabel   *orLabel;

@end

@implementation SelectLanguageVC
{
    NSMutableArray *dataArray;
}


#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    if (SCREEN_WIDTH == 320) {
        [self setLayoutONDifferentDevices];
    }
    
    [self initialSetUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetUp {
    [self.btnPropertyClientLogin setTitle:KNSLOCALIZEDSTRING(@"Login As Client") forState:UIControlStateNormal] ;
    [self.btnPropertyClientSignUp setTitle:KNSLOCALIZEDSTRING(@"Sign Up As Client") forState:UIControlStateNormal] ;
    [self.btnPropertyServiceProviderLogin setTitle:KNSLOCALIZEDSTRING(@"Login As Service Provider") forState:UIControlStateNormal] ;
    [self.btnPropertyServiceProviderSignUp setTitle:KNSLOCALIZEDSTRING(@"Sign Up As Service Provider") forState:UIControlStateNormal] ;
    _orLabel.text = KNSLOCALIZEDSTRING(@"OR");
    
    [self.btnPropertyClientLogin.layer setCornerRadius:25.0];
    [self.btnPropertyClientSignUp.layer setCornerRadius:25.0];
    [self.btnPropertyServiceProviderLogin.layer setCornerRadius:25.0];
    [self.btnPropertyServiceProviderSignUp.layer setCornerRadius:25.0];
    [self.btnPropertyOptionLanguage.layer setCornerRadius:25.0];
    
    dataArray = [[NSMutableArray alloc]initWithObjects:@"English",@"Spanish",@"Arabic", nil];
}

-(void)setLayoutONDifferentDevices {
    //For iphone 4 and 5
    [self.btnPropertyOptionLanguage.titleLabel setFont:APPFONTBOLD(16)];
    [self.lblSelectLanguage setFont:APPFONTBOLD(16)];
    [self.btnPropertyServiceProviderSignUp.titleLabel setFont:APPFONTREGULAR(14)];
    [self.btnPropertyServiceProviderLogin.titleLabel setFont:APPFONTREGULAR(14)];
    [self.btnPropertyClientSignUp.titleLabel setFont:APPFONTREGULAR(14)];
    [self.btnPropertyClientLogin.titleLabel setFont:APPFONTREGULAR(14)];
}

#pragma mark - UIButton's Action

- (IBAction)loginAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isClientSide"];

    LoginVC *loginObj = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    [self.navigationController pushViewController:loginObj animated:YES];
}

- (IBAction)signUpAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isClientSide"];
    
    LoginVC *loginObj = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    SignUpVC *signInObj = [[SignUpVC alloc]initWithNibName:@"SignUpVC" bundle:nil];
    
    NSArray *controllerArray = [[NSArray alloc]initWithObjects:self,loginObj,signInObj,nil];
    [self.navigationController  setViewControllers:controllerArray animated:YES];
}

- (IBAction)loginServiceProviderAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isClientSide"];
    
    LoginVC *loginObj = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    [self.navigationController pushViewController:loginObj animated:YES];
}

- (IBAction)signUpServiceProviderAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isClientSide"];

    LoginVC *loginObj = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    SignUpViewController *signUpObj = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
    
    NSArray *controllerArray = [[NSArray alloc]initWithObjects:self,loginObj,signUpObj,nil];
    [self.navigationController setViewControllers:controllerArray animated:YES];
}

- (IBAction)selectLanguageAction:(id)sender {
    [[OptionsPickerSheetView sharedPicker]showPickerSheetWithOptions:dataArray AndComplitionblock:^(NSString *selectedText, NSInteger selectedIndex) {
        [self.btnPropertyOptionLanguage setTitle:selectedText forState:UIControlStateNormal];
    }];
}

@end
