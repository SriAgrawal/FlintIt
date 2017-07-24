//
//  ChatVC.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ChatVC.h"
#import "ADCircularMenu.h"
#import "UIViewController+JASidePanel.h"
#import "MessagesVC.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"
#import "EmailListViewController.h"
#import "ServiceTrackingVC.h"
#import "SenderMessageCell.h"
#import "RecieverMessageCell.h"
#import "SZTextView.h"
#import "AlertView.h"
#import "ChatInfo.h"
#import "EXPhotoViewer.h"
#import "AudioPlayerVC.h"
#import <AVFoundation/AVFoundation.h>

static NSString *senderCellIdentifier = @"SenderMessageCell";
static NSString *recieveCellIdentifier = @"RecieverMessageCell";

@interface ChatVC ()<ADCircularMenuDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,customAudioPlayerDelegate,AVAudioPlayerDelegate> {
    
    ADCircularMenu *circularMenuVC;
    NSMutableArray *messageDetail;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSTimer *meterTimer;
    NSInteger index;
}

@property (weak, nonatomic) IBOutlet UITableView *tblVIew;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *upperView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint_bottomView;

@property (weak, nonatomic) IBOutlet UILabel *userCurrentStatus;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet SZTextView *messageSendTextView;

@property (weak, nonatomic) IBOutlet UIButton *sendBtnProperty;
@property (weak, nonatomic) IBOutlet UIView *aboveView_textView;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnGlobal;
@end

@implementation ChatVC

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

-(void)viewWillAppear:(BOOL)animated {
    //Notification For Keyboard Up and Down
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)note {
    
    CGSize kbSize = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:[[[note userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        self.bottomConstraint_bottomView.constant = kbSize.height;
        [self.view layoutSubviews];
        
    } completion:^(BOOL finished) {
        if ([messageDetail count]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageDetail count]-1 inSection:0];
            [self.tblVIew scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [UIView animateWithDuration:[[[note userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.bottomConstraint_bottomView.constant = 0;
        [self.view layoutSubviews];
    } completion:^(BOOL finished) {
        if ([messageDetail count]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageDetail count]-1 inSection:0];
            [self.tblVIew scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

#pragma mark - Helper Class

-(void)initialSetup {
    
    _navTitle.text = KNSLOCALIZEDSTRING(@"Chat");
    
    [self.upperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    
   // Register Cell
    [self.tblVIew registerNib:[UINib nibWithNibName:@"SenderMessageCell" bundle:nil] forCellReuseIdentifier:@"SenderMessageCell"];
    [self.tblVIew registerNib:[UINib nibWithNibName:@"RecieverMessageCell" bundle:nil] forCellReuseIdentifier:@"RecieverMessageCell"];
    self.tblVIew.estimatedRowHeight = 64.0 ;
    self.tblVIew.rowHeight = UITableViewAutomaticDimension;

    //Layout UIImageView
    [self.userImage.layer setCornerRadius:self.userImage.frame.size.width/2];
    [self.userImage.layer setBorderWidth:3.0];
    [self.userImage.layer setBorderColor:[UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1].CGColor];
    
    [self.aboveView_textView.layer setCornerRadius:20.0];
    [self.sendBtnProperty.layer setCornerRadius:20.0];
    
    self.messageSendTextView.placeholder = KNSLOCALIZEDSTRING(@"Type message");
    self.messageSendTextView.placeholderTextColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1];
    
    //Initalise Array
    messageDetail = [[NSMutableArray alloc]init];
    
    [self.sendBtnProperty setEnabled:NO];
    [self.sendBtnProperty setAlpha:0.5];
    
    //Add Tap Gesture
    UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(KeyboardResign)];
    singleGesture.numberOfTapsRequired = 1;
    [self.tblVIew addGestureRecognizer:singleGesture];
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        self.messageSendTextView.textAlignment = NSTextAlignmentRight;
        [self.btnGlobal setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    NSDictionary *response;
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"isImage",@"Hiee",@"message", @"",@"imagePath",nil]];
       response = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray,@"chatArray", nil];
    messageDetail = [ChatInfo getChatInfo:response];
}

-(void)getChatMesages:(BOOL)isImage andIsAudio:(BOOL)isAudio andImage:(NSString *)image andAudio:(NSString *)audio {
    NSDictionary *response;
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isImage] ,@"isImage",_messageSendTextView.text,@"message", image,@"image",audio,@"audio",[NSNumber numberWithBool:isAudio] ,@"isAudio",nil]];
    response = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray,@"chatArray", nil];
   [messageDetail addObjectsFromArray:[ChatInfo getChatInfo:response]];
    [_tblVIew reloadData];
    if ([messageDetail count]) {
        [self.sendBtnProperty setEnabled:YES];
        [self.tblVIew reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageDetail count]-1 inSection:0];
        [self.tblVIew scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(NSMutableAttributedString *)getAttributedText :(NSString*)chatText {
    NSMutableAttributedString *paraText = [[NSMutableAttributedString alloc] initWithString:chatText];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = 2.0;
    [paraText addAttribute:NSParagraphStyleAttributeName value:para range:[[paraText string] rangeOfString:chatText]];
    return paraText;
}

-(void)KeyboardResign {
    [self.view endEditing:YES];
}

- (UIImage *) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void) playAudioVideo:(UIButton*)sender {
    ChatInfo *chatInfo = [messageDetail objectAtIndex:sender.tag - 100];
    if (chatInfo.isImage) {
        UIImageView *imgview = [[UIImageView alloc] initWithImage:chatInfo.image];
        [EXPhotoViewer showImageFrom:imgview];
    } else {
        if (!recorder.recording){
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:chatInfo.audio] error:NULL];
            [player play];
                [meterTimer invalidate];
//                timerLabel.text = @"00:00";
                meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioMeter:) userInfo:nil repeats:YES];
            }
        player.meteringEnabled = YES;
                //                audioPlayer.meteringEnabled = true
//                recordAudioButton.enabled = false
                if (player != nil) {
                    player.delegate = self;
                }
        UIProgressView *kView = [self.view viewWithTag:(sender.tag+100)];
        NSLog(@"tag=>%ld",(long)sender.tag);
        index = sender.tag;
        kView.progress = 0;
        [meterTimer invalidate];
        meterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCellAudioStatus:) userInfo:nil repeats:YES];
        
//                kView?.progress = 0
//                self.meterTimer.invalidate()
//                self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(1,
//                                                                         target:self,
//                                                                         selector:#selector(self.updateCellAudioStatus(_:)),
//                                                                         userInfo:nil,
//                                                                         repeats:true)
//                
//                
//                kView?.progress = 0
//            } catch {
//            }
//        } else {
//            meterTimer.invalidate()
//        }
    }
}


-(NSString*) updateAudioMeter:(NSTimer *)timer {
    
    if (recorder != nil && recorder.recording) {
        NSInteger min = (recorder.currentTime / 60);
        NSInteger sec = trunc(recorder.currentTime - min * 60);
        NSString *s =[NSString stringWithFormat:@"%ld %ld",(long)min,(long)sec];
//        timerLabel.text = s;
        [recorder updateMeters];
        return s;
          } else if (player != nil && player.playing) {
        NSInteger min = (player.currentTime / 60);
        NSInteger sec = trunc(player.currentTime - min * 60);
        NSString *s =[NSString stringWithFormat:@"%ld %ld",(long)min,(long)sec];
//        timerLabel.text = s;
        [player updateMeters];
              return s;
    }
    return nil;
}

-(void) updateCellAudioStatus:(NSTimer*)timer {
    
    UILabel *kLabel = [self.view viewWithTag:(index + 200)];
    NSInteger min = (player.currentTime / 60);
    NSInteger sec = trunc(player.currentTime - min * 60);
    kLabel.text = [NSString stringWithFormat:@"%ld %ld",(long)min,(long)sec];
    UIProgressView *kView = [self.view viewWithTag:(index + 100)];
    [kView setProgress:player.currentTime/player.duration];
    [player updateMeters];
    
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messageDetail count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecieverMessageCell *recieveCell = (RecieverMessageCell *)[self.tblVIew dequeueReusableCellWithIdentifier:recieveCellIdentifier];
    SenderMessageCell *senderCell = (SenderMessageCell *)[self.tblVIew dequeueReusableCellWithIdentifier:senderCellIdentifier];
    ChatInfo *chat = [messageDetail objectAtIndex:indexPath.row];
    senderCell.timerLabel.hidden = YES;
    senderCell.progressView.hidden = YES;
    recieveCell.timerLabel.hidden = YES;
    recieveCell.progressView.hidden = YES;
    if (indexPath.row % 2 == 0) {
        [senderCell.lblText setAttributedText: [self getAttributedText: chat.message]];
        [senderCell.imgSendImageView setImage:chat.image];
        if (chat.isAudio) {
            senderCell.timerLabel.hidden = NO;
            senderCell.progressView.hidden = NO;
        }
        
        senderCell.zoomImageButton.tag = indexPath.row + 100;
        senderCell.progressView.tag = indexPath.row + 200;
        senderCell.timerLabel.tag = indexPath.row + 300;
        [senderCell.zoomImageButton addTarget:self action:@selector(playAudioVideo:) forControlEvents:UIControlEventTouchUpInside];
        //        [senderCell.lblText setText:[messageDetail objectAtIndex:indexPath.row]];
        
        return senderCell;
    } else {
        recieveCell.zoomImageButton.tag = indexPath.row + 100;
        recieveCell.progressView.tag = indexPath.row + 200;
        recieveCell.timerLabel.tag = indexPath.row + 300;
        if (chat.isAudio) {
            recieveCell.timerLabel.hidden = NO;
            recieveCell.progressView.hidden = NO;
        }

        [recieveCell.zoomImageButton addTarget:self action:@selector(playAudioVideo:) forControlEvents:UIControlEventTouchUpInside];
        [recieveCell.lblText setAttributedText:[self getAttributedText: chat.message]];
        [recieveCell.imgSendImageView setImage:chat.image];
        return recieveCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

#pragma mark TextView Delegate Method

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([TRIM_SPACE(newString) length]) {
        [self.sendBtnProperty setEnabled:YES];
        [self.sendBtnProperty setAlpha:1.0];
    }else {
        [self.sendBtnProperty setEnabled:NO];
        [self.sendBtnProperty setAlpha:0.5];
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

#pragma mark - UIButton Actions

- (IBAction)audioAction:(id)sender {
     [self.view endEditing:true];
    AudioPlayerVC *audio = [[AudioPlayerVC alloc] initWithNibName:@"AudioPlayerVC" bundle:nil];
    audio.bgImg =  [self  captureScreen];
    audio.delegate = self;
    [self.navigationController presentViewController:audio animated:YES completion:nil];
}

- (IBAction)attachmentAction:(id)sender {
    [self.view endEditing:true];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery",nil];
    [actionSheet showInView:self.view];
}

- (IBAction)backAction:(id)sender {
     [self.view endEditing:true];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
//    ChatInfo *chatInfo;
    NSString *chatting_text = TRIM_SPACE(self.messageSendTextView.text);
    
    if ([chatting_text length]) {
        if ([chatting_text length] > 1000) {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:@"The character limit is 1000. Try a shorter message, then send it again." onController:self];
        } else {
            [self.sendBtnProperty setEnabled:NO];
            [self.sendBtnProperty setAlpha:0.5];
//            [messageDetail addObject:chatting_text];
            [self getChatMesages:0 andIsAudio:0 andImage:@"" andAudio:@""];
            [self.messageSendTextView setText:[NSString string]];
        }
    }
}

- (IBAction)socialButton:(id)sender {
    circularMenuVC = nil;
     [self.view endEditing:true];
    
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

#pragma mark - UIAction sheet Delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Camera"]){
        [self takePhotoFromCamera:YES];
    }else if ([title isEqualToString:@"Gallery"]){
        [self takePhotoFromGallery];
//    }else if ([title isEqualToString:@"Audio"]){
//        [self recordAudio];
    }
}

-(void)takePhotoFromGallery {
    
    UIImagePickerController *picker= [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)takePhotoFromCamera:(BOOL)video{
    
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *profileImagePicker = [[UIImagePickerController alloc]init];
        profileImagePicker.delegate = self;
        profileImagePicker.allowsEditing = NO;
        profileImagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:profileImagePicker animated:YES completion:NULL];
        }
   }

#pragma mark - UIImagePicker Delegate method

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"latest_photo%f.png",timeStamp]];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *mediaData = UIImagePNGRepresentation(editedImage);
        [mediaData writeToFile:imagePath atomically:YES];
    }
        [picker dismissViewControllerAnimated:YES completion:^{
    }];
    [self getChatMesages:1 andIsAudio:0 andImage:imagePath andAudio:@""];
}

#pragma mark - AudioPlayer Custom delegate Methods
-(void)getRecordedAudio:(NSURL*) soundFile {
    [self getChatMesages:0 andIsAudio:1 andImage:@"" andAudio:[NSString stringWithFormat:@"%@", soundFile]];
    [_tblVIew reloadData];
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
                } else if ([controller isKindOfClass:[MessagesVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
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
                } else if ([controller isKindOfClass:[ServiceTrackingVC class]] || [controller isKindOfClass:[[self.sidePanelController centerPanel] class]]) {
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
}

#pragma mark - AVFoundation Delegate Methods

// MARK: AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
}

@end
