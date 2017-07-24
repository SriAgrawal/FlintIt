//
//  ChangePasswordVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 23/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ChangePasswordVC.h"
#import "LoginCell.h"
#import "UserInfo.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MacroFile.h"
#import "AlertView.h"
#import "NSDictionary+NullChecker.h"

static NSString *identifier = @"LoginCell";

@interface ChangePasswordVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UserInfo *modalObject;
}

@property (weak, nonatomic) IBOutlet UITableView *changePasswordTableview;

@property (strong, nonatomic) IBOutlet UIView *changePasswordFooter;
@property (strong, nonatomic) IBOutlet UIView *changePasswordHeader;

@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *lblChangePassword;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@end

@implementation ChangePasswordVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    _lblChangePassword.text = KNSLOCALIZEDSTRING(@"Change Password");
    [self.changePasswordButton setTitle:KNSLOCALIZEDSTRING(@"Change Password") forState:UIControlStateNormal] ;
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    }

    
    //Register the TableView Cell
    [self.changePasswordTableview registerNib:[UINib nibWithNibName:@"LoginCell" bundle:nil] forCellReuseIdentifier:@"LoginCell"];
    
    //Set Table Header&Footer
    [self.changePasswordTableview setTableHeaderView:self.changePasswordHeader];
    [self.changePasswordTableview setTableFooterView:self.changePasswordFooter];
    
    //Set Layout of Button
    //[self.changePasswordButton.layer setCornerRadius:self.changePasswordButton.frame.size.height/2];
    self.changePasswordButton.layer.cornerRadius = 25.0;

    //Alloc the modal class object
    modalObject = [[UserInfo alloc]init];
    
    //Table vertical bounce if required
    [self.changePasswordTableview setAlwaysBounceVertical:NO];
}

#pragma mark - UITableView DataSource and Delegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LoginCell *cell = (LoginCell *)[self.changePasswordTableview dequeueReusableCellWithIdentifier:identifier];
    
    [cell.cellTextField setSecureTextEntry:YES];
    [cell.cellTextField setReturnKeyType:UIReturnKeyNext];
    [cell.cellTextField setTag:indexPath.row+1000];
    [cell.cellTextField setDelegate:self];
    [cell.cellTextField setTextAlignment:NSTextAlignmentLeft];
    addPading(cell.cellTextField);

    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        cell.cellTextField.textAlignment = NSTextAlignmentRight;
    }

    switch (indexPath.row) {
        case 0:
            [cell.cellTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Enter Old Password")]];
            [cell.cellTextField setText:modalObject.strOldPassword];
            break;
            
        case 1:
            [cell.cellTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Enter New Password")]];
            [cell.cellTextField setText:modalObject.strNewPassword];
            break;
            
        case 2:
            [cell.cellTextField setAttributedPlaceholder:[self changePlaceholderColor:[UIColor blackColor] :KNSLOCALIZEDSTRING(@"Confirm New Password")]];
            [cell.cellTextField setText:modalObject.strConfirmPassword];
            cell.cellTextField.returnKeyType = UIReturnKeyDone;
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
    
        if ([textFieldString length] > 15) {
            return NO;
        }else{
            return YES;
        }

    return YES;
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
    [self.view layoutIfNeeded];
    switch (textField.tag) {
        case 1000:
            [modalObject setStrOldPassword:textField.text];
            break;
        case 1001:
            [modalObject setStrNewPassword:textField.text];
            break;
        case 1002:
            [modalObject setStrConfirmPassword:textField.text];
            break;
        default:
            break;
    }
}

-(NSAttributedString *) changePlaceholderColor : (UIColor *) color : (NSString *) text {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: color}];
}

#pragma mark - UIButton's Action

- (IBAction)changePasswordButtonAction:(id)sender {
    [self.view endEditing:YES];

    if(modalObject.strOldPassword == nil || [modalObject.strOldPassword isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the old password.") onController:self];
    }
    else if((modalObject.strOldPassword.length < 6) ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Old Password must be of atleast 6 characters.") onController:self];
    }
    else if(modalObject.strNewPassword == nil || [modalObject.strNewPassword isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please enter the new password.") onController:self];
    }
    else if((modalObject.strNewPassword.length < 6) ) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"New Password must be of atleast 6 characters.") onController:self];
    }
    else if([modalObject.strNewPassword isEqualToString:modalObject.strOldPassword]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"New password and old password should not be same.") onController:self];
    }
    else if(modalObject.strConfirmPassword == nil || [modalObject.strConfirmPassword isEqualToString:@""]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Please confirm the new password.") onController:self];
    }
    else if(![modalObject.strConfirmPassword isEqualToString:modalObject.strNewPassword]) {
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"New password and confirm new password should be same.") onController:self];
    }
    else {
        [self requestDictForChangePassword];
        }

}

- (IBAction)menuAction:(id)sender {
    [self.view endEditing:YES];
    [self.sidePanelController showLeftPanelAnimated:YES];
}

#pragma mark - Service Implementation Methods

-(void)requestDictForChangePassword {

    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:modalObject.strOldPassword  forKey:pCurrentPassword];
    [requestDict setObject:modalObject.strNewPassword forKey:pNewPassword];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/change_password" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            

            
            [[AlertView sharedManager] presentAlertWithTitle:@"" message:[result objectForKeyNotNull:pResponseMsg expectedObj:@""] andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"OK")] onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                if ([[NSUSERDEFAULT valueForKey:@"remeberCheck"] isEqualToString:@"YES"]) {
                    NSLog(@"data ---------%@",[NSUSERDEFAULT valueForKey:@"rememberUserData"]);
                    NSMutableDictionary * userDict = [NSMutableDictionary new];
                    [userDict setValue:[[NSUSERDEFAULT valueForKey:@"rememberUserData"] valueForKey:@"userEmail"] forKey:@"userEmail"];
                    [userDict setValue:modalObject.strNewPassword forKey:@"userPassword"];
                    [NSUSERDEFAULT setValue:userDict forKey:@"rememberUserData"];
                    [NSUSERDEFAULT synchronize];
                    NSLog(@"data ---------%@",[NSUSERDEFAULT valueForKey:@"rememberUserData"]);
                }
                    modalObject.strOldPassword = [NSString string];
                    modalObject.strNewPassword = [NSString string];
                    modalObject.strConfirmPassword = [NSString string];
                
                    [self.changePasswordTableview reloadData];
            }];
        }
    }];
    
}

@end
