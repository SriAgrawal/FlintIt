//
//  ReportProfileVC.m
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import "ReportProfileVC.h"
#import "MacroFile.h"
#import "ADCircularMenu.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MessagesVC.h"
#import "EmailListViewController.h"
#import "ServiceTrackingVC.h"
#import "AppUtilityFile.h"
#import "HeaderFile.h"

@interface ReportProfileVC ()<ADCircularMenuDelegate,UITextViewDelegate>
{
    ADCircularMenu *circularMenuVC;
    UserInfo *modalObject;
}

@property (strong, nonatomic) IBOutlet UITableView *reportProfileTableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITextView *reportTextView;

@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UILabel *lblReportProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblPleaseWrite;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation ReportProfileVC

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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Helper Methods

-(void)initialSetup
{
    _lblReportProfile.text = KNSLOCALIZEDSTRING(@"Report Profile");
    _lblPleaseWrite.text = KNSLOCALIZEDSTRING(@"Please write the description of your Report");
     [self.reportButton setTitle:KNSLOCALIZEDSTRING(@"Report") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Set table Header View
    [self.reportProfileTableView setTableHeaderView:self.headerView];
    [self.reportProfileTableView setAlwaysBounceVertical:NO];
    
    //Set layout of button and textView
    [self.reportButton.layer setCornerRadius:25];
    [self.reportTextView.layer setCornerRadius:20];
    
    //Set content inset in textView
    [self.reportTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];

    //Add Gesture
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignKeyboard)];
    [self.view addGestureRecognizer:singleTapGesture];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
}

-(void)resignKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - UIButton Actions

- (IBAction)socialAction:(id)sender {
    circularMenuVC = nil;
    
    //use 3 or 7 or 12 for symmetric look (current implementation supports max 12 buttons)
    NSArray *arrImageName = [[NSArray alloc] initWithObjects:
                             @"chat_icon",
                             @"mail_icon",
                             @"tracker_icon",
                             nil];
    
    circularMenuVC = [[ADCircularMenu alloc] initWithMenuButtonImageNameArray:arrImageName
                                                     andCornerButtonImageName:@"global_icon"];
    circularMenuVC.delegateCircularMenu = self;
    [circularMenuVC show];
}

#pragma mark - Delegate Method Of ADCircularMenu

- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[MessagesVC class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[MessagesVC class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[MessagesVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[MessagesVC class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            if (isNotFound) {
                MessagesVC *messageObject = [[MessagesVC alloc]initWithNibName:@"MessagesVC" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:messageObject animated:YES];
            }
        }
            break;
        case 1:{
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[EmailListViewController class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[EmailListViewController class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[EmailListViewController class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[EmailListViewController class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            if (isNotFound) {
                EmailListViewController *emailObject = [[EmailListViewController alloc]initWithNibName:@"EmailListViewController" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:emailObject animated:YES];
            }
        }
            break;
        case 2: {
            BOOL isNotFound = YES;
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[JASidePanelController class]]) {
                    JASidePanelController *sidePanelObj = (JASidePanelController *)controller;
                    if ([[sidePanelObj centerPanel] isKindOfClass:[ServiceTrackingVC class]]) {
                        isNotFound = NO;
                        
                        if (![self isKindOfClass:[ServiceTrackingVC class]])
                            [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }else if ([controller isKindOfClass:[ServiceTrackingVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
                    isNotFound = NO;
                    
                    if (![self isKindOfClass:[ServiceTrackingVC class]])
                        [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
            
            if (isNotFound) {
                ServiceTrackingVC *serviceTrackingObject = [[ServiceTrackingVC alloc]initWithNibName:@"ServiceTrackingVC" bundle:nil];
                THREEOPTIONSCOMINGFROM = Social;
                [self.navigationController pushViewController:serviceTrackingObject animated:YES];
            }
        }
            break;
        default:
            break;
    }
    // NSLog(@"Circular Button : Clicked button at index : %d",buttonIndex);
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reportAction:(id)sender {
    [self.view endEditing:YES];
    if ([TRIM_SPACE(modalObject.strDescription) length]) {
        [self requestDictForReport];
    }else{
    [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Alert") andMessage:KNSLOCALIZEDSTRING(@"Please enter report description.") onController:self];

    }
    
   }

#pragma mark - UITextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([text isEqualToString:@" "]) {
        if ((textView == _reportTextView && range.location != 0)) {
            return YES;
        }
        return NO;
    }else if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else if (textView == _reportTextView) {
        if (![text isEqualToString:@""]) {
            if ([textFieldString length] > 500) {
                return NO;
            }else{
                return YES;
            }
        }
        return YES;
        
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    CGFloat constantValue;
    
    if (SCREEN_HEIGHT == 480) {
        constantValue = -50;
    }else if (SCREEN_HEIGHT == 568) {
        constantValue = 10;
    }else {
        constantValue = 10;
    }
    
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.topConstraint setConstant:constantValue];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
  //  [self.view endEditing:YES];
    modalObject.strDescription = self.reportTextView.text;
//    [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.topConstraint setConstant:10];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForReport {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:_particularReportDetail.jobID forKey:pJobId];
    [requestDict setValue:_particularReportDetail.userID forKey:pReportID];
    [requestDict setValue:modalObject.strDescription forKey:pDescription];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/report_data" WithComptionBlock:^(id result, NSError *error) {
    
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
}


@end
