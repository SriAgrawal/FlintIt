//
//  GiveAReviewServiceSideVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "GiveAReviewServiceSideVC.h"
#import "SZTextView.h"
#import "DXStarRatingView.h"
#import "ReviewRelatedData.h"
#import "HeaderFile.h"
#import "NSString+CC.h"
#import "HCSStarRatingView.h"

@interface GiveAReviewServiceSideVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    ReviewRelatedData *modalObject;
    NSData *imageData;
}
@property (weak, nonatomic) IBOutlet UILabel *giveReviewTitleLabel;

@property (weak, nonatomic) IBOutlet SZTextView *textViewReview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textviewTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *btnUploadPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnSetImage;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak,nonatomic)NSString * imageType;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewStarRating;

@end

@implementation GiveAReviewServiceSideVC

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


-(void)resignKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Helper Method

-(void)initialSetup {
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    _giveReviewTitleLabel.text = KNSLOCALIZEDSTRING(@"Give a Review");
    [_btnUploadPhoto setTitle:KNSLOCALIZEDSTRING(@"Upload a photo for the job") forState:UIControlStateNormal];
    [_btnSend setTitle:KNSLOCALIZEDSTRING(@"Send") forState:UIControlStateNormal];

    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    //Set Layout of button
    self.btnUploadPhoto.layer.borderColor = [UIColor colorWithRed:48/255.0 green:182/255.0 blue:163/255.0 alpha:1].CGColor;
    self.btnSetImage.layer.borderColor = [UIColor colorWithRed:48/255.0 green:182/255.0 blue:163/255.0 alpha:1].CGColor;
   
    self.textViewReview.placeholder = KNSLOCALIZEDSTRING(@"Write a Comment");

    //Set Color and Inset of textView
    [self.textViewReview setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];
    self.textViewReview.textColor = [UIColor blackColor];
    
//    [self.viewStarRating setIsOnReview:NO];
    //[self.viewStarRating setStars:5];
    _viewStarRating.maximumValue = 5;
    _viewStarRating.minimumValue = 0;
    _viewStarRating.allowsHalfStars = NO;
    _viewStarRating.value = 0;
    _viewStarRating.emptyStarImage = [UIImage imageNamed:@"unStar.png"];
    _viewStarRating.filledStarImage = [UIImage imageNamed:@"sStar.png"];
    
    UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignKeyboard)];
    [self.view addGestureRecognizer:singleGesture];
    
    modalObject = [[ReviewRelatedData alloc]init];
    
    if (SCREEN_HEIGHT == 480)
    {
        [self.viewTopConstraint setConstant:-22];
        [self.textviewTopConstraint setConstant:-3];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    modalObject.strMessage = self.textViewReview.text;
}


#pragma mark - UIButton Actions

- (IBAction)backAction:(id)sender {
    [self.view endEditing:YES];
    NSArray * viewControllers = [[APPDELEGATE navController] viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if([viewController isKindOfClass:[JASidePanelController class]]) {
            [[APPDELEGATE navController] popToViewController:viewController animated:NO];
        }
    }
    SelectChoiceVC *selectChoiceObject = [[SelectChoiceVC alloc]initWithNibName:@"SelectChoiceVC" bundle:nil];
    [self.sidePanelController setCenterPanel:selectChoiceObject];

    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
    [self.view endEditing:YES];
    [self requestDictForGiveReview];
}

- (IBAction)uploadAction:(id)sender {
    [self.view endEditing:YES];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                           KNSLOCALIZEDSTRING(@"Take Photo"),
                           KNSLOCALIZEDSTRING(@"Choose Photo"),
                            nil];
    [popup setTag:1];
    [popup showInView:self.view];
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
#pragma mark - UITextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *textFieldString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([text isEqualToString:@" "]) {
        if ((textView == _textViewReview && range.location != 0)) {
            return YES;
        }
        return NO;
    }else if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else if (textView == _textViewReview) {
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
#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    imageData = [NSData data];
    imageData = UIImageJPEGRepresentation(image, 0.5);
    [self.btnSetImage setImage:image forState:UIControlStateNormal];
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
    [requestDict setValue:self.objRowModal.clientID forKey:pReviewID];
    [requestDict setValue: [modalObject.strMessage length
     ]?modalObject.strMessage:@""  forKey:pComment];
//   [requestDict setValue:[NSString stringWithFormat:@"%d",_viewStarRating.stars] forKey:pRating];
    // newly added
    NSString * str = [NSString stringWithFormat:@"%f",_viewStarRating.value];
    [requestDict setValue:[NSString stringWithFormat:@"%d",[str intValue]] forKey:pRating];

    [requestDict setValue:self.objRowModal.jobID forKey:pJobId];
    [requestDict setValue:[imageData base64EncodedStringWithOptions:0]?[imageData base64EncodedStringWithOptions:0]:@"" forKey:pJobImage];
//    [requestDict setValue:[_imageType length]?_imageType:@"" forKey:@"image_type"];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    [requestDict setValue:string forKey:@"review_date"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];


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
    SelectChoiceViewController *selectChoiceObject = [[SelectChoiceViewController alloc]initWithNibName:@"SelectChoiceViewController" bundle:nil];
    [self.sidePanelController setCenterPanel:selectChoiceObject];
}


@end
