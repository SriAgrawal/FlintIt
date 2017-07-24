//
//  StatusAvailableBusyVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "StatusAvailableBusyVC.h"
#import "UIViewController+CWPopup.h"
#import "MacroFile.h"
#import "HeaderFile.h"

@interface StatusAvailableBusyVC ()
{
    UserInfo *modalObject;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *viewOuter;

@property (weak, nonatomic) IBOutlet UIButton *availableProperty;
@property (weak, nonatomic) IBOutlet UIButton *busyProperty;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation StatusAvailableBusyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self requestDictForSendStatus];
}

#pragma mark - Helper Method

-(void)initialSetup  {
    //Set Layout of BView
    self.viewOuter.layer.cornerRadius = 10.0;
    self.viewOuter.clipsToBounds = YES;
    [_statusLabel setText:KNSLOCALIZEDSTRING(@"Please Select your Status")];
    if (SCREEN_WIDTH == 320) {
        [self.outerViewWidthConstraint setConstant:250];
        
    }else if (SCREEN_HEIGHT == 667) {
        [self.outerViewWidthConstraint setConstant:300];
        
    }else {
        [self.outerViewWidthConstraint setConstant:350];
    }
    [_availableProperty setTitle:KNSLOCALIZEDSTRING(@"Available") forState:UIControlStateNormal] ;
    [_busyProperty setTitle:KNSLOCALIZEDSTRING(@"Busy") forState:UIControlStateNormal];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"]){
        _availableProperty.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _busyProperty.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

        _availableProperty.titleEdgeInsets = UIEdgeInsetsZero;
        _busyProperty.titleEdgeInsets = UIEdgeInsetsZero;

    }
    
    [self requestDictForGetStatus];
}

- (IBAction)btnAvailableAction:(UIButton *)sender {
    [self.busyProperty setSelected:NO];
    [self.availableProperty setSelected:YES];
}

- (IBAction)btnBusyAction:(UIButton *)sender {
    [self.availableProperty setSelected:NO];
    [self.busyProperty setSelected:YES];
    
}

- (IBAction)crossAction:(id)sender {
    [self requestDictForSendStatus];
}


/*********************** Service Implementation Methods ****************/

-(void)requestDictForGetStatus {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/get_availablity" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            [self.availableProperty setSelected:[[result objectForKeyNotNull:pAvailability expectedObj:@""] boolValue]];
            [self.busyProperty setSelected:![[result objectForKeyNotNull:pAvailability expectedObj:@""] boolValue]];;

        }else
        {
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Error!") message:error.localizedDescription andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self.navigationController dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                if(index == 0)
                {
                    [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
    
}

-(void)requestDictForSendStatus {
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:([self.availableProperty isSelected])?@"1":@"0"  forKey:pAvailability];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Notification/change_availability_status" WithComptionBlock:^(id result, NSError *error) {
        if (!error) {
            [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];

        }else
        {
            [[AlertView sharedManager] presentAlertWithTitle:KNSLOCALIZEDSTRING(@"Error!") message:error.localizedDescription andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self.navigationController dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                if(index == 0)
                {
                    [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
    
}

@end
