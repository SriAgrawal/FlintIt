//
//  TermsVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "TermsVC.h"
#import "MacroFile.h"
#import "NSDictionary+NullChecker.h"

@interface TermsVC ()

@property (weak, nonatomic) IBOutlet UILabel *lblTerms;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _lblTerms.text = KNSLOCALIZEDSTRING(@"Terms and Conditions");
    
    //Getting Serve Data
    [self requestDictForStaticContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForStaticContent{
    

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:@"1" forKey:pPageID];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/static_page" WithComptionBlock:^(id result, NSError *error) {
        
        [self.webView loadHTMLString:[result objectForKeyNotNull:pData expectedObj:@""] baseURL:nil];
        
    }];
}

@end
