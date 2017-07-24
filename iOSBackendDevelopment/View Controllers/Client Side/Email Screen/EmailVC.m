//
//  EmailVC.m
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import "EmailVC.h"
#import "MacroFile.h"
#import "HeaderFile.h"
#import "UserInfo.h"

@interface EmailVC ()<UITextViewDelegate>
{
    UserInfo *modalObject;
   
}

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITableView *emailTableView;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (strong, nonatomic) IBOutlet UITextView *emailBodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailTo;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceProviderName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;

@end

@implementation EmailVC

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

-(void)resignKeyboard:(id)gestureSender {
    [self.view endEditing:YES];
}

#pragma mark - Helper Method

-(void)initialSetup {
    [_lblCount setText:[NSString stringWithFormat:@"1000 %@",KNSLOCALIZEDSTRING(@"Characters")]];
    _lblEmail.text = KNSLOCALIZEDSTRING(@"Email");
    _lblEmailTo.text = KNSLOCALIZEDSTRING(@"Email To :");
    _lblServiceProviderName.text = KNSLOCALIZEDSTRING(@"Service Provider Name");
    [self.sendButton setTitle:KNSLOCALIZEDSTRING(@"Send") forState:UIControlStateNormal] ;

    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        self.emailBodyTextView.textAlignment = NSTextAlignmentRight;
        [self.emailBodyTextView setTextContainerInset:UIEdgeInsetsMake(0, 15, 0, 15)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    if ([self.particularDetail isKindOfClass:[RowDataModal class]]) {
        RowDataModal *messageDetail = self.particularDetail;
        self.lblServiceProviderName.text = messageDetail.userName;
    }else {
        EmailDataModal *messageDetail = self.particularDetail;
        self.lblServiceProviderName.text = messageDetail.userName;
    }
    
    //Set TableView Header
    [self.emailTableView setTableHeaderView:self.headerView];
    
    //Bounce table vertical if required
    [self.emailTableView setAlwaysBounceVertical:NO];
    
    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];
    
    //Set Layout Of Button and TextView
    [self.sendButton.layer setCornerRadius:25];
    [self.emailBodyTextView.layer setCornerRadius:20];
    [self.emailBodyTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];
    [self.emailBodyTextView setDelegate:self];
    
    UITapGestureRecognizer *gestureObj = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignKeyboard:)];
    [self.emailTableView addGestureRecognizer:gestureObj];
}

#pragma mark - UITextField delegate methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    NSString *newString = [self.emailBodyTextView.text stringByReplacingCharactersInRange:range withString:text];
    if ([text isEqualToString:@" "]) {
      
        if ((textView ==  _emailBodyTextView && range.location != 0)) {
            return YES;
        }
        return NO;
    }
    else if(newString.length <= 1000) {
//        [_lblCount setText:[NSString stringWithFormat:@"%lu Characters",(1000 - ((unsigned long)newString.length))]];
        [_lblCount setText:[NSString stringWithFormat:@"%lu ",(1000 - ((unsigned long)newString.length))]];
       _lblCount.text = [_lblCount.text stringByAppendingString:KNSLOCALIZEDSTRING(@"Characters")];
        NSLog(@"%@",_lblCount.text);
        return YES;
    } else {
        return NO;
    }

    return YES;
    

}


-(void)textViewDidEndEditing:(UITextView *)textView {
    modalObject.strMessage = self.emailBodyTextView.text;
}


#pragma mark - UIButton Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
    [self.view endEditing:YES];

    if ([TRIM_SPACE(modalObject.strMessage) length]) {
        [self requestDictForEmailSending];

    }else{
        
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Alert") andMessage:KNSLOCALIZEDSTRING(@"Please enter message.") onController:self.navigationController];

    }
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForEmailSending {
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    if ([self.particularDetail isKindOfClass:[RowDataModal class]]) {
        RowDataModal *messageDetail = self.particularDetail;
        [requestDict setValue:messageDetail.userID forKey:pReceiver];
    }else {
        EmailDataModal *messageDetail = self.particularDetail;
        if ([messageDetail.senderID isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]])
          [requestDict setValue:messageDetail.receiverID forKey:pReceiver];
        else
          [requestDict setValue:messageDetail.senderID forKey:pReceiver];
    }

    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pSender];
    [requestDict setValue:modalObject.strMessage forKey:pMessage];
    
    [requestDict setValue:@"hello" forKey:pSubject];
    [requestDict setValue:@"hello" forKey:pSubject];

    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"message/insert_message" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            EmailDataModal *sendEmailObject = [EmailDataModal parseEmailList:result];
            
            [self.delegate updateEmailList:sendEmailObject];
            [self.navigationController popViewControllerAnimated:YES];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
   
}

@end
