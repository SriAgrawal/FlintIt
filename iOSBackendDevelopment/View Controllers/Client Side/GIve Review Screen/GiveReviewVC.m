//
//  GiveReviewVC.m
//  iOSBackendDevelopment
//
//  Created by admin on 09/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "GiveReviewVC.h"
#import "DXStarRatingView.h"
#import "MacroFile.h"
#import "SZTextView.h"
#import "HeaderFile.h"
#import "ReviewRelatedData.h"
#import "NSString+CC.h"
#import "HCSStarRatingView.h"

@interface GiveReviewVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    ReviewRelatedData *modalObject;
    NSData *imageData;
}

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblFavourite;

@property (weak, nonatomic) IBOutlet UITableView *giveReviewTableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet SZTextView *commentTextView;

@property (weak, nonatomic) IBOutlet UIButton *btnAddFavourite;
@property (weak, nonatomic) IBOutlet UIButton *btnUploadPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (strong,atomic) NSString * imageType;

@end

@implementation GiveReviewVC

#pragma mark - UIViewController Life cycle methods & Memory Managment

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self initialSetup];
}

-(void)initialSetup {
    
    self.giveReviewTableView.tableHeaderView = self.headerView;
    self.giveReviewTableView.tableFooterView = self.footerView;
    self.lblNavTitle.text = KNSLOCALIZEDSTRING(@"Give a Review");
    self.lblFavourite.text = KNSLOCALIZEDSTRING(@"Do you want to add this service provider as favourite ?");
    [self.btnAddFavourite setTitle:KNSLOCALIZEDSTRING(@"Add to Favourite") forState:UIControlStateNormal] ;
    [self.btnUploadPhoto setTitle:KNSLOCALIZEDSTRING(@"Upload a photo for the job") forState:UIControlStateNormal] ;
    [self.btnSend setTitle:KNSLOCALIZEDSTRING(@"Send") forState:UIControlStateNormal] ;
    [self.btnShare setTitle:KNSLOCALIZEDSTRING(@"Share") forState:UIControlStateNormal] ;
    self.btnAddFavourite.layer.borderColor = [UIColor colorWithRed:48/255.0 green:182/255.0 blue:163/255.0 alpha:1].CGColor;
     self.btnUploadPhoto.layer.borderColor = [UIColor colorWithRed:48/255.0 green:182/255.0 blue:163/255.0 alpha:1].CGColor;
    self.btnImage.layer.borderColor = [UIColor colorWithRed:48/255.0 green:182/255.0 blue:163/255.0 alpha:1].CGColor;
    
    self.commentTextView.placeholder = KNSLOCALIZEDSTRING(@"Write a Comment");
    [self.commentTextView setTextContainerInset:UIEdgeInsetsMake(15, 0, 0, 15)];
    self.commentTextView.textColor = [UIColor blackColor];
    [self.commentTextView setDelegate:self];
    
//    [self.starRatingView setIsOnReview:NO];
    //[self.starRatingView setStars:5];
    _starRatingView.maximumValue = 5;
    _starRatingView.minimumValue = 0;
    _starRatingView.allowsHalfStars = NO;
    _starRatingView.value = 0;
    _starRatingView.emptyStarImage = [UIImage imageNamed:@"star2.png"];
    _starRatingView.filledStarImage = [UIImage imageNamed:@"star1.png"];

    //Alloc Modal Class Object
    modalObject = [[ReviewRelatedData alloc]init];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        self.commentTextView.textAlignment = NSTextAlignmentRight;
        [self.commentTextView setTextContainerInset:UIEdgeInsetsMake(15, 0, 0, 15)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    [self callApiToChkForFavouriteStatus];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    modalObject.strMessage = self.commentTextView.text;
}

- (IBAction)backAction:(id)sender {
    
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count -4] animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
    
    NSArray * viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if([viewController isKindOfClass:[JASidePanelController class]]) {
            [[APPDELEGATE navController] popToViewController:viewController animated:NO];
        }
    }
    SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
    [self.sidePanelController setCenterPanel:selectChoiceObject];

}

- (IBAction)btnShare:(id)sender {
    [self.view endEditing:YES];
    NSString *textToShare = @"Look at this awesome website for aspiring iOS Developers!";
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)btnSend:(id)sender {
    
    [self.view endEditing:YES];
    [self requestDictForGiveReview];
}

- (IBAction)btnUploadPhoto:(id)sender {
    [self.view endEditing:YES];

    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                          KNSLOCALIZEDSTRING(@"Take Photo"),
                          KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    [popup setTag:1];
    [popup showInView:self.view];
}

- (IBAction)btnAddFavourite:(id)sender {
    [self.view endEditing:YES];

    if(!self.btnAddFavourite.selected) {
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to add it as favourite?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index) {
                [self requestDictForAddFavourite:self.btnAddFavourite.selected];
            }
        }];
    }
    else {
        [[AlertView sharedManager] presentAlertWithTitle:@"" message:KNSLOCALIZEDSTRING(@"Are you sure you want to remove it as favourite?") andButtonsWithTitle:@[KNSLOCALIZEDSTRING(@"No"),KNSLOCALIZEDSTRING(@"Yes")]onController:self dismissedWith:^(NSInteger index, NSString *buttonTitle) {
            if (index) {
                [self requestDictForAddFavourite:self.btnAddFavourite.selected];
            }
        }];
    }

}

- (IBAction)btnImage:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                           KNSLOCALIZEDSTRING(@"Take Photo"),
                           KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    [popup setTag:1];
    [popup showInView:self.view];

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([text isEqualToString:@" "]) {
        if ((textView == _commentTextView && range.location != 0)) {
            return YES;
        }
        return NO;
    }else if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else if (textView == _commentTextView) {
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
#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch ([popup tag]) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:KNSLOCALIZEDSTRING(@"Device has no camera.") onController:[APPDELEGATE navController]];
//                        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
//                                                                              message:KNSLOCALIZEDSTRING(@"Device has no camera.")
//                                                                             delegate:nil
//                                                                    cancelButtonTitle:KNSLOCALIZEDSTRING(@"OK")
//                                                                    otherButtonTitles: nil];
//                        [myAlertView show];
                    }else
                    {
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:picker animated:YES completion:NULL];
                    }
                    break;
                case 1:
                {
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:picker animated:YES completion:NULL];
                }
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    imageData = [NSData data];
    imageData = UIImageJPEGRepresentation(image, 0.5);
    [self.btnImage setImage:image forState:UIControlStateNormal];
    NSURL *imagePath = [editingInfo objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *imageName = [imagePath lastPathComponent];
    NSLog(@"%@",imageName);
    _imageType = imageName;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForGiveReview {

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue: modalObject.strMessage.length ? modalObject.strMessage: @""  forKey:pComment];
    // [requestDict setValue:[NSString stringWithFormat:@"%d",_starRatingView.stars] forKey:pRating];
    
    // newly added
    NSString * str = [NSString stringWithFormat:@"%f",_starRatingView.value];
    [requestDict setValue:[NSString stringWithFormat:@"%d",[str intValue]] forKey:pRating];
    
    
    [requestDict setValue:[imageData base64EncodedStringWithOptions:0]?[imageData base64EncodedStringWithOptions:0]:@""  forKey:pJobImage];
//    [requestDict setValue:[_imageType length]?_imageType:@"" forKey:@"image_type"];
    
    if(_reviewDetail) {
        [requestDict setValue:_reviewDetail.userID forKey:pReviewID];
        [requestDict setValue:_reviewDetail.jobID forKey:pJobId];
    }
    else {
        [requestDict setValue:_particularReviewDetail.receiverID forKey:pReviewID];
        [requestDict setValue:_particularReviewDetail.jobID forKey:pJobId];
    }
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    [requestDict setValue:string forKey:@"review_date"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"job/give_review" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            NSArray * viewControllers = [[APPDELEGATE navController] viewControllers];
            for (UIViewController *viewController in viewControllers) {
                if([viewController isKindOfClass:[JASidePanelController class]]) {
                    [[APPDELEGATE navController] popToViewController:viewController animated:NO];
                }
            }
            [self performSelector:@selector(setCentrePanel) withObject:nil afterDelay:0.1];

//            SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
//            [self.sidePanelController setCenterPanel:selectChoiceObject];

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
        }
    }];
    
}
-(void)setCentrePanel{
    SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
    [self.sidePanelController setCenterPanel:selectChoiceObject];
}

-(void)requestDictForAddFavourite:(BOOL)isFavourite {
    
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if(_reviewDetail) {
        [requestDict setValue:_reviewDetail.userID forKey:pFavouriteID];
    }
    else {
        [requestDict setValue:_particularReviewDetail.receiverID forKey:pFavouriteID];
    }
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    if (isFavourite) {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pClientID];
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/delete_favourite_list" WithComptionBlock:^(id result, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                self.btnAddFavourite.selected = !self.btnAddFavourite.selected;
                NSLog(@"%d",self.btnAddFavourite.selected);
                self.reviewDetail.isAlreadyFavourite = self.btnAddFavourite.selected;
            }else
            {
                [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

            }
        }];
        
    }else {
        [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_favourite" WithComptionBlock:^(id result, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                
                self.btnAddFavourite.selected = !self.btnAddFavourite.selected;
            }else
            {
                [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];
            }
        }];
    }
}

-(void)callApiToChkForFavouriteStatus{
  
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:self.reviewDetail.userID forKey:pFavouriteID];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    if(_reviewDetail) {
        [requestDict setValue:_reviewDetail.userID forKey:pFavouriteID];
    }
    else {
        [requestDict setValue:_particularReviewDetail.receiverID forKey:pFavouriteID];
    }
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_favourite_check" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            if ([[result valueForKey:@"fav"]boolValue]) {
                self.btnAddFavourite.selected = YES;
                self.reviewDetail.isAlreadyFavourite = self.btnAddFavourite.selected;
                
            }else{
                self.btnAddFavourite.selected = NO;
                self.reviewDetail.isAlreadyFavourite = self.btnAddFavourite.selected;
                
            }
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
        
        
    }];
    
}


@end
