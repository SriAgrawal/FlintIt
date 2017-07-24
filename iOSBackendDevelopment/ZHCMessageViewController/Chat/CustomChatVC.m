//
//  CustomChatVC.m
//  iOSBackendDevelopment

//  Created by Anand Yadav on 16/10/23.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "CustomChatVC.h"
#import "ChatHistoryModel.h"
#import "Flink_It-Swift.h"
#import "MacroFile.h"
#import <GoogleMaps/GoogleMaps.h>
#import "EXPhotoViewer.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "ZHCMessagesViewController.h"


@interface CustomChatVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GMSMapViewDelegate,MKMapViewDelegate>{
    SocketIOClient* socket;
    NSArray *tempArray;
    NSInteger userLoggedInStatus, pageNumber, maxPageNumber;
    UIRefreshControl *refreshControl;
    
}

@end

@implementation CustomChatVC

#pragma mark - life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.status.text = @"";
    
    
//    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:self.userProfileDetail.userImage] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //Your main thread code goes in here
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:self.userProfileDetail.userImage] placeholderImage:[UIImage imageNamed:@"user_icon"]];
    });

    
    [self.status setTranslatesAutoresizingMaskIntoConstraints:YES];
//  [self.status setFrame:CGRectMake(SCREEN_WIDTH - 130, 24, 122, 40)];
    [self.status setFrame:CGRectMake(SCREEN_WIDTH - 130, 24, 125, 40)];

    [self.status setTextAlignment:NSTextAlignmentRight];
//    if (self.userProfileDetail.messageTime.length > 0) {
//        //        self.status.text = [NSString stringWithFormat:@"Last seen: %@", [self convertDateWithString:self.userProfileDetail.messageTime]];
//        self.status.text = [NSString stringWithFormat:@"%@ %@",KNSLOCALIZEDSTRING(@"Last seen:"), [self convertDateWithString:self.userProfileDetail.messageTime]];
//        self.status.font = [UIFont fontWithName:@"Candara" size:14];
//    }else {
//        [self performSelector:@selector(requestToFetchLastSeen) withObject:nil afterDelay:.5];
//    }
    // To get last seen time.
    [self performSelector:@selector(requestToFetchLastSeen) withObject:nil afterDelay:.5];

    [self.status setNumberOfLines:2];
    self.name.text = self.userProfileDetail.userName.length?self.userProfileDetail.userName:@"";
    pageNumber= 1;
    maxPageNumber = -1;
    [self performSelector:@selector(apiCallForChatHistory) withObject:nil afterDelay:0.5];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.messageTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    self.chatTitleLabel.text = KNSLOCALIZEDSTRING(@"Chat");
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.backBtnOutlet setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.backBtnOutlet setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
        [self.status setFrame:CGRectMake(10, 24, 120, 40)];
        [self.status setTextAlignment:NSTextAlignmentLeft];

    }
    if(SCREEN_WIDTH == 320){
        [[self chatTitleLabel] setFont:[UIFont systemFontOfSize:20]];
    }
    [self registerForTheNotifications:YES];
//    [self callAPIToUpdateUserStatus];
}

- (void)registerForTheNotifications:(BOOL)registerForNotifications
{
    if (registerForNotifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredBackGround) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredForeGround) name:UIApplicationWillEnterForegroundNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromPush:) name:@"PushData" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.messageTableView.dataSource = nil;
        self.messageTableView.delegate = nil;
        self.inputMessageBarView.contentView.textView.delegate = nil;
        self.inputMessageBarView.delegate = nil;
        self.messageMoreView.dataSource = nil;
        self.messageMoreView.delegate = nil;
        self.messageEmojiView.delegate = nil;
    }
}


-(void)applicationEnteredForeGround
{
    //[socket connect];
    [self performSelector:@selector(apiCallForChatHistory) withObject:nil afterDelay:0.5];
}

-(void)applicationEnteredBackGround {
    [socket disconnect];
}

-(void)getDataFromPush:(NSNotification *)notification {
    
    RowDataModal *data = [[RowDataModal alloc] init];
    data.userID = [notification.userInfo objectForKeyNotNull:@"senderId" expectedObj:@""];
    data.userName = [notification.userInfo objectForKeyNotNull:@"username" expectedObj:@""];
    
    //other user image to be added
    data.userImage = [notification.userInfo objectForKeyNotNull:@"userImage" expectedObj:@""];
    self.userProfileDetail = data;
    pageNumber = 1;
    [self performSelector:@selector(apiCallForChatHistory) withObject:nil afterDelay:0.5];
}

-(void)apiCallForChatHistory
{
    [self requestToFetchUserChatHistory:pageNumber];
    
    // Do any additional setup after loading the view.
    // [self performSelectorInBackground:@selector(socketIOConnectionEstablish) withObject:nil];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self socketIOConnectionEstablish];
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self registerForTheNotifications:NO];
}

-(void)refreshTable {
    if (pageNumber < maxPageNumber) {
        pageNumber += 1;
        [self requestToFetchUserChatHistory:pageNumber];
    }else {
        [refreshControl endRefreshing];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentBool) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    }
} 

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
}

-(NSString*)convertDateWithString:(NSString *)dateStr{
    if (dateStr.length) {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        // extend time by 3+ min to manage difference.

        // NSDate *newDate  = [date dateByAddingTimeInterval:200];

        // Convert date object to desired output format
        [dateFormat setDateFormat:@"dd/MM/YYYY hh:mm a"];
        dateStr = [dateFormat stringFromDate:date] ;

    }else {
        dateStr = @"";
    }
    
    return dateStr;
}

#pragma mark - ZHCMessagesTableViewDataSource

-(NSString *)senderDisplayName
{
    NSDictionary *dictUserInfo;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    
    return [dictUserInfo valueForKey:@"username"];
}

-(NSString *)senderId
{
    return [NSUSERDEFAULT valueForKey:@"userID"];
}

- (id<ZHCMessageData>)tableView:(ZHCMessagesTableView*)tableView messageDataForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.row];
    
}

-(void)tableView:(ZHCMessagesTableView *)tableView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.row];
}


- (nullable id<ZHCMessageBubbleImageDataSource>)tableView:(ZHCMessagesTableView *)tableView messageBubbleImageDataForCellAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your TableView view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    if (message.isMediaMessage) {
        NSLog(@"is mediaMessage");
    }
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (nullable id<ZHCMessageAvatarImageDataSource>)tableView:(ZHCMessagesTableView *)tableView avatarImageDataForCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [self.demoData.avatars objectForKey:message.senderId];
    
}


-(NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.row %3 == 0) {
        ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    //  NSAttributedString * str = [[ZHCMessagesTimestampFormatter sharedFormatter]attributedTimestampForDate:message.date];

        return [[ZHCMessagesTimestampFormatter sharedFormatter]attributedTimestampForDate:message.date];
    }
    return nil;
}


-(NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    //    /**
    //     *  iOS7-style sender name labels
    //     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if ((indexPath.row - 1) > 0) {
        ZHCMessage *preMessage = [self.demoData.messages objectAtIndex:(indexPath.row - 1)];
        if ([preMessage.senderId isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    
}


- (NSAttributedString *)tableView:(ZHCMessagesTableView *)tableView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark - Adjusting cell label heights
-(CGFloat)tableView:(ZHCMessagesTableView *)tableView heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    CGFloat labelHeight = 0.0f;
    if (indexPath.item % 3 == 0) {
        labelHeight = kZHCMessagesTableViewCellLabelHeightDefault;
    }
    return labelHeight;
}

-(CGFloat)tableView:(ZHCMessagesTableView *)tableView  heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    CGFloat labelHeight = kZHCMessagesTableViewCellLabelHeightDefault;
    ZHCMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        labelHeight = 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        ZHCMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            labelHeight = 0.0f;
        }
    }
    
    return labelHeight;
    
}


-(CGFloat)tableView:(ZHCMessagesTableView *)tableView  heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat labelHeight = 0.0f;
    return labelHeight;
}

#pragma mark - ZHCMessagesTableViewDelegate
-(void)tableView:(ZHCMessagesTableView *)tableView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didTapAvatarImageView:avatarImageView atIndexPath:indexPath];
}


-(void)tableView:(ZHCMessagesTableView *)tableView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    if([message.media isKindOfClass:[ZHCPhotoMediaItem class]]){
        ZHCPhotoMediaItem *photoItem = (ZHCPhotoMediaItem *)message.media;
        if (photoItem.image){
            
//            CGSize size = [self mediaViewDisplaySize];
//            UIImageView * imageV = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 250, 0 , 0)];

            
            [APPDELEGATE setIsTapOnImage:YES];
            
            UIImageView *imgView = [[UIImageView alloc]initWithImage:photoItem.image];
//            [imgView setFrame:CGRectMake(SCREEN_WIDTH,SCREEN_HEIGHT, 0.01, 0.01f)];
//            [SCAvatarBrowser showImageView:imgView];
//           [EXPhotoViewer showImageFrom:imgView];
            
            
            // Create image info
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
#if TRY_AN_ANIMATED_GIF == 1
            imageInfo.imageURL = [NSURL URLWithString:@"http://media.giphy.com/media/O3QpFiN97YjJu/giphy.gif"];
#else
            imageInfo.image = photoItem.image;
#endif
            imageInfo.referenceRect = imgView.frame;
            imageInfo.referenceView = imgView.superview;
            imageInfo.referenceContentMode = imgView.contentMode;
            imageInfo.referenceCornerRadius = imgView.layer.cornerRadius;
            // Setup view controller
            JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                   initWithImageInfo:imageInfo
                                                   mode:JTSImageViewControllerMode_Image
                                                   backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
            
            // Present the view controller.
            //  [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
            [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];


        }
    } else
    if([message.media isKindOfClass:[ZHCLocationMediaItem class]]){
        
        
        ZHCLocationMediaItem *locationItem = (ZHCLocationMediaItem *)message.media;
        
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:locationItem.coordinate.latitude longitude:locationItem.coordinate.longitude]; //insert your coordinates
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [ceo reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      if (placemark) {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          NSLog(@"placemark %@",placemark);
                          //String to hold address
                          NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                          /*   NSLog(@"addressDictionary %@", placemark.addressDictionary);
                           
                           NSLog(@"placemark %@",placemark.region);
                           NSLog(@"placemark %@",placemark.country);  // Give Country Name
                           NSLog(@"placemark %@",placemark.locality); // Extract the city name
                           NSLog(@"location %@",placemark.name);
                           NSLog(@"location %@",placemark.ocean);
                           NSLog(@"location %@",placemark.postalCode);
                           NSLog(@"location %@",placemark.subLocality);
                           
                           NSLog(@"location %@",placemark.location);
                           //Print the location to console
                           NSLog(@"I am currently at %@",locatedAt);*/
                          NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",
                                           [locatedAt  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                      }
                      else {
                          NSLog(@"Could not locate");
                      }
                  }
         ];
        
        
//        UIAlertController * view=   [UIAlertController
//                                     alertControllerWithTitle:@"Open With"
//                                     message:nil
//                                     preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction* ok = [UIAlertAction
//                             actionWithTitle:KNSLOCALIZEDSTRING(@"Google map")
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action)
//                             {
//                                 //Do some thing here
////                                 ZHCLocationMediaItem *locationItem = (ZHCLocationMediaItem *)message.media;
////                                 GMSMapView *mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
////                                 mapView.tag = 88888;
////                                 UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
////                                 navView.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0];
////                                 UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 20, 50, 40)];
////                                 [cancelBtn setImage:[UIImage imageNamed:@"cross_icon"] forState:UIControlStateNormal];
////                                 [cancelBtn addTarget:self action:@selector(removeMapFromView:) forControlEvents:UIControlEventTouchUpInside];
////                                 cancelBtn.tag = 99999;
////                                 [navView addSubview:cancelBtn];
////                                 [mapView addSubview:navView];
////                                 [self.view addSubview:mapView];
////                                 GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake(locationItem.coordinate.latitude, locationItem.coordinate.longitude) zoom:3];
////                                 
////                                 // zoom the map into the users current location
////                                 [mapView animateWithCameraUpdate:updatedCamera];
////                                 
////                                 GMSMarker *marker = [[GMSMarker alloc] init];
////                                 marker.position = CLLocationCoordinate2DMake(locationItem.coordinate.latitude, locationItem.coordinate.longitude);
////                                 marker.icon = [UIImage imageNamed:@"location"];
////                                 marker.map = mapView;
//                                 
//                                 
//                                ZHCLocationMediaItem *locationItem = (ZHCLocationMediaItem *)message.media;
//
//                                 CLGeocoder *ceo = [[CLGeocoder alloc]init];
//                                 CLLocation *loc = [[CLLocation alloc]initWithLatitude:locationItem.coordinate.latitude longitude:locationItem.coordinate.longitude]; //insert your coordinates
//                                 [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                                 [ceo reverseGeocodeLocation:loc
//                                           completionHandler:^(NSArray *placemarks, NSError *error) {
//                                               CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                                               if (placemark) {
//                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                                   NSLog(@"placemark %@",placemark);
//                                                   //String to hold address
//                                                   NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
//                                                   /*   NSLog(@"addressDictionary %@", placemark.addressDictionary);
//                                                    
//                                                    NSLog(@"placemark %@",placemark.region);
//                                                    NSLog(@"placemark %@",placemark.country);  // Give Country Name
//                                                    NSLog(@"placemark %@",placemark.locality); // Extract the city name
//                                                    NSLog(@"location %@",placemark.name);
//                                                    NSLog(@"location %@",placemark.ocean);
//                                                    NSLog(@"location %@",placemark.postalCode);
//                                                    NSLog(@"location %@",placemark.subLocality);
//                                                    
//                                                    NSLog(@"location %@",placemark.location);
//                                                    //Print the location to console
//                                                    NSLog(@"I am currently at %@",locatedAt);*/
//                                                   NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",
//                                                                    [locatedAt  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//                                               }
//                                               else {
//                                                   NSLog(@"Could not locate");
//                                               }
//                                           }
//                                  ];
////                                 if ([[UIApplication sharedApplication] canOpenURL:
////                                      [NSURL URLWithString:@"comgooglemaps://"]]) {
////                                     [[UIApplication sharedApplication] openURL:
////                                      [NSURL URLWithString:@"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic"]];
////                                 } else {
////                                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:@"Please install app" onController:self];
////                                 }
//
//
//                             }];
////        UIAlertAction* cancel = [UIAlertAction
////                                 actionWithTitle:KNSLOCALIZEDSTRING(@"Apple map")
////                                 style:UIAlertActionStyleDefault
////                                 handler:^(UIAlertAction * action)
////                                 {
////                                     //Do some thing here
////                                     ZHCLocationMediaItem *locationItem = (ZHCLocationMediaItem *)message.media;
////                                     MKMapView *appleMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
////                                     appleMapView.tag = 77777;
////                                     UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
////                                     navView.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0];
////                                     UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 20, 50, 40)];
////                                     [cancelBtn setImage:[UIImage imageNamed:@"cross_icon"] forState:UIControlStateNormal];
////                                     cancelBtn.tag = 55555;
////                                     [cancelBtn addTarget:self action:@selector(removeMapFromView:) forControlEvents:UIControlEventTouchUpInside];
////                                     [navView addSubview:cancelBtn];
////                                     [appleMapView addSubview:navView];
////                                     [self.view addSubview:appleMapView];
////                                     
////                                     MKPointAnnotation*    annotation = [[MKPointAnnotation alloc] init];
////                                     CLLocationCoordinate2D myCoordinate;
////                                     myCoordinate.latitude=locationItem.coordinate.latitude;
////                                     myCoordinate.longitude=locationItem.coordinate.longitude;
////                                     annotation.coordinate = myCoordinate;
////                                     appleMapView.centerCoordinate = annotation.coordinate;
////                                     [appleMapView addAnnotation:annotation];
////                                     //                                     [view dismissViewControllerAnimated:YES completion:nil];
////                                     
////                                 }];
//        
//        UIAlertAction* Cancel = [UIAlertAction
//                             actionWithTitle:KNSLOCALIZEDSTRING(@"Cancel")
//                             style:UIAlertActionStyleCancel
//                             handler:^(UIAlertAction * action)
//                             {
//                                 //Do some thing here
// 
//                             }];
//        
//        
//        [view addAction:ok];
////      [view addAction:cancel];
//        [view addAction:Cancel];
//
//        [self presentViewController:view animated:YES completion:nil];
        
    }
    
    [super tableView:tableView didTapMessageBubbleAtIndexPath:indexPath];
}

-(void)removeMapFromView:(UIButton *)btn{
    if (btn.tag == 55555) {
        MKMapView * map = (MKMapView*)[self.view viewWithTag:77777];
        [map removeFromSuperview];
    }else{
        GMSMapView * map = (GMSMapView*)[self.view viewWithTag:88888];
        [map removeFromSuperview];
    }
    
}

-(void)tableView:(ZHCMessagesTableView *)tableView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [super tableView:tableView didTapCellAtIndexPath:indexPath touchLocation:touchLocation];
}


-(void)tableView:(ZHCMessagesTableView *)tableView performAction:(SEL)action forcellAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    [super tableView:tableView performAction:action forcellAtIndexPath:indexPath withSender:sender];
    
    NSLog(@"performAction:%ld",(long)indexPath.row);
}


#pragma mark － TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.demoData.messages.count)
        return self.demoData.messages.count;
    else
        return 0;
}

-(UITableViewCell *)tableView:(ZHCMessagesTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZHCMessagesTableViewCell *cell = (ZHCMessagesTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(self.demoData.messages.count)
        [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
#pragma mark Configure Cell Data
- (void)configureCell:(ZHCMessagesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ZHCMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    if (!message.isMediaMessage) {
        if ([message.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }else{
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
}


#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
    if (self.userProfileDetail.isBlockStatus) {
        
        [self.view endEditing:YES];
        
        [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:KNSLOCALIZEDSTRING(@"You can not send message to blocked user") onController:self.navigationController];
        
        return;
    }
    //Reconnect socket if disconneceted.
    if (socket.status == 0 || socket.status == 1) {
        [socket connect];
    }
    //Get user info
    NSMutableDictionary *dictTemp;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    
    if([text length]) {
        //Posting text message via socket.
        if (!self.userProfileDetail.isBlockStatus) {
            
            NSDictionary *messageData = @{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"senderName" :[dictTemp valueForKey:@"username"] , @"message": text, @"receiverId": self.userProfileDetail.userID,@"receiverName": self.userProfileDetail.userName,@"type":@"message", @"receiverImage":[NSUSERDEFAULT boolForKey:@"isClientSide"] ? [[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"] valueForKey:@"profileimage"] : [[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"] valueForKey:@"profileimage"]};
            
            NSLog(@"Params  == %@",messageData);
            [socket emit:@"sendmessage" with:@[messageData]];
            
            ZHCMessage *message = [[ZHCMessage alloc] initWithSenderId:senderId
                                                     senderDisplayName:senderDisplayName
                                                                  date:date
                                                                  text:text messageReadStatus:@"unread"];
            
            [self.demoData.messages addObject:message];
            [self finishSendingMessageAnimated:YES];
        }else
        {
            
        }
        
        
        //Creating new text messsage object and adding to message array.
        
    }else {
        if (!self.userProfileDetail.isBlockStatus) {
            [socket emit:@"senderTypingStatus" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"receiverId": self.userProfileDetail.userID}]];
        }
    }
}


#pragma mark - ZHCMessagesInputToolbarDelegate
-(void)messagesInputToolbar:(ZHCMessagesInputToolbar *)toolbar sendVoice:(NSString *)voiceFilePath seconds:(NSTimeInterval)senconds
{
    NSMutableDictionary *dictTemp;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    NSData * audioData = [NSData dataWithContentsOfFile:voiceFilePath];
    if (!self.userProfileDetail.isBlockStatus) {
        [socket emit:@"sendmessage" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"senderName" :[dictTemp valueForKey:@"username"] , @"audio": audioData, @"receiverId": self.userProfileDetail.userID,@"receiverName": self.userProfileDetail.userName,@"type":@"audio", @"receiverImage":[NSUSERDEFAULT boolForKey:@"isClientSide"] ? [[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"] valueForKey:@"profileimage"] : [[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"] valueForKey:@"profileimage"]}]];
    }
    
    ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:audioData];
    
    ZHCMessage *audioMessage = [ZHCMessage messageWithSenderId:self.senderId
                                                   displayName:self.senderDisplayName
                                                         media:audioItem readStatus:@"unread"];
    [self.demoData.messages addObject:audioMessage];
    
    [self finishSendingMessageAnimated:YES];
    
}

#pragma mark - ZHCMessagesMoreViewDelegate

-(void)messagesMoreView:(ZHCMessagesMoreView *)moreView selectedMoreViewItemWithIndex:(NSInteger)index
{
    
    switch (index) {
        case 0:{//photo
            [self.view endEditing:YES];
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:KNSLOCALIZEDSTRING(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:
                                    KNSLOCALIZEDSTRING(@"Take Photo"),
                                    KNSLOCALIZEDSTRING(@"Choose Photo"),
                                    nil];
            [popup setTag:1];
            [popup showInView:self.view];
        }break;
            
        case 1:{//Location
            NSMutableDictionary *dictTemp;
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
            }else{
                dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
            }
            
            if (!self.userProfileDetail.isBlockStatus) {
                [socket emit:@"sendmessage" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"senderName" :[dictTemp valueForKey:@"username"] , @"lat": [APPDELEGATE latitude], @"long": [APPDELEGATE longitude], @"receiverId": self.userProfileDetail.userID,@"receiverName": self.userProfileDetail.userName,@"type":@"location", @"receiverImage":[NSUSERDEFAULT boolForKey:@"isClientSide"] ? [[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"] valueForKey:@"profileimage"] : [[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"] valueForKey:@"profileimage"]}]];
            }
            
            typeof(self) __weak weakSelf = self;
            __weak ZHCMessagesTableView *weakView = self.messageTableView;
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
                [weakSelf finishSendingMessage];
                
            }];
        }break;
            
        default:
            break;
    }
}



#pragma mark - ZHCMessagesMoreViewDataSource
-(NSArray *)messagesMoreViewTitles:(ZHCMessagesMoreView *)moreView
{
    //return @[@"Location",@"Photos"];
    return @[@"Photos",@"Location"];
}

-(NSArray *)messagesMoreViewImgNames:(ZHCMessagesMoreView *)moreView
{
    //return @[@"chat_bar_icons_location",@"chat_bar_icons_pic"];
    return @[@"chat_bar_icons_pic",@"chat_bar_icons_location"];
    
}


#pragma mark - PrivateMethods
-(void)closePressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    [self.view endEditing:YES];
    [self finishSendingMessage];
    [socket disconnect];
    [self registerForTheNotifications:NO];

//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Handling Socket

-(void)socketIOConnectionEstablish {
    
    
    
    self.demoData = [[ZHCModelData alloc] initWithUserInfo:self.userProfileDetail WithChatHistory:nil];
    NSURL* url = [[NSURL alloc] initWithString:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/"];
    if (!self.userProfileDetail.isBlockStatus) {
        socket = [[SocketIOClient alloc] initWithSocketURL:url config:nil];
        
        [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"socket connected");
            
            [socket on:@"onlineuser" callback:^(NSArray* data, SocketAckEmitter* ack) {
                NSLog(@"onlineuser");
            }];
            
            [socket onAny:^(SocketAnyEvent * _Nonnull event) {
               
                NSLog(@"Event Name %@   %@",event.event, event.items);
            }];
            //Get user info from default store.
            NSDictionary *dictUserInfo;
            if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
                dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
            }else{
                dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
            }
            
        # warning needed to chek crashes
            if (![NSUSERDEFAULT valueForKey:@"userID"] || ![dictUserInfo valueForKey:@"username"] ) {
                
                [socket disconnect];
                [self socketIOConnectionEstablish];
                return;
            }
            
//            [socket emit:@"initChat" with:@[@{@"userId": [NSUSERDEFAULT valueForKey:@"userID"], @"user_name":[dictUserInfo valueForKey:@"username"]}]];
            NSLog(@"other user %@ curetn user --%@",self.userProfileDetail.userID,[NSUSERDEFAULT valueForKey:@"userID"]);
            [socket emit:@"initChat" with:@[@{@"userId": [NSUSERDEFAULT valueForKey:@"userID"], @"user_name":[dictUserInfo valueForKey:@"username"],@"currentUserId":self.userProfileDetail.userID}]];
            
            //
            [socket emit:@"userStatus" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"receiverId":self.userProfileDetail.userID}]];
            
        }];
        
        [socket connect];
        // [socket reconnect];
        
        //Socket ON method to recieve chat messages.
        [socket on:@"receivemessage" callback:^(NSArray* data, SocketAckEmitter* ack) {
            //Checking message type.
            if ([[[data objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"message"]) {
                //Receive message
                ZHCMessage *message = [[ZHCMessage alloc]initWithSenderId:[[data objectAtIndex:0] objectForKey:@"senderId"] senderDisplayName:self.userProfileDetail.userName date:[NSDate date] text:[[data objectAtIndex:0] objectForKey:@"message"] messageReadStatus:@"read"];
                
                if([[[data objectAtIndex:0] objectForKey:@"senderId"] isEqualToString:self.userProfileDetail.userID]){
                    [self.demoData.messages addObject:message];
                }
                
            }else if ([[[data objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"media"]){
                //Receive Image
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",[[data objectAtIndex:0] objectForKey:@"fileUrl"]]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];
                ZHCPhotoMediaItem *photoItem = [[ZHCPhotoMediaItem alloc]initWithImage:image];
                photoItem.appliesMediaViewMaskAsOutgoing = NO;
                ZHCMessage *photoMessage = [ZHCMessage messageWithSenderId:[[data objectAtIndex:0] objectForKey:@"senderId"] displayName:self.userProfileDetail.userName  media:photoItem readStatus:@"read"];
                if([[[data objectAtIndex:0] objectForKey:@"senderId"] isEqualToString:self.userProfileDetail.userID]){
                    [self.demoData.messages addObject:photoMessage];
                }
                
            }else if ([[[data objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"audio"]){
                //Receive Audio
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",[[data objectAtIndex:0] objectForKey:@"fileUrl"]]];
                
                ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                audioItem.appliesMediaViewMaskAsOutgoing = NO;

                ZHCMessage *audioMessage = [ZHCMessage messageWithSenderId:[[data objectAtIndex:0] objectForKey:@"senderId"]
                                                               displayName:self.userProfileDetail.userName
                                                                     media:audioItem readStatus:@"read"];
                if([[[data objectAtIndex:0] objectForKey:@"senderId"] isEqualToString:self.userProfileDetail.userID]){
                    [self.demoData.messages addObject:audioMessage];
                   }
                
            }else if ([[[data objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"location"]){
                //Receive Location
                typeof(self) __weak weakSelf = self;
                __weak ZHCMessagesTableView *weakView = self.messageTableView;
                
                if ([[[data objectAtIndex:0] objectForKey:@"senderId"] isEqualToString:self.userProfileDetail.userID]) {
                    [self.demoData addLocationMediaMessageOfOtherUserWithCompletion:^{
                        
                        [weakView reloadData];
                        [weakSelf finishSendingMessage];
                        
                    }WithInfo:self.userProfileDetail MessageReadStatus:@"read"];
                }
            }
            self.status.text = @"Online";
            self.status.font = [UIFont fontWithName:@"Candara" size:16];
            
            //[self finishSendingMessage];
            
            [self.messageTableView reloadData];

       
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.messageTableView reloadData];
//            });
            
            if (self.automaticallyScrollsToMostRecentMessage) {
                [self scrollToBottomAnimated:YES];
            }
            
        }];
        
        //Socket ON method to check user online/offline status.
        [socket on:@"isUseronline" callback:^(NSArray* data, SocketAckEmitter* ack) {
            
            if ([[[data objectAtIndex:0] objectForKey:@"status"] integerValue] == 1) {
                self.status.text = @"Online";
                self.status.font = [UIFont fontWithName:@"Candara" size:16];
                self.status.textColor = [UIColor greenColor];
            }else{
                //            self.status.text = @"Offline";
                //            self.status.textColor = [UIColor redColor];
                
            }
        }];
        //Socket ON method to check if user goes to offline.
        [socket on:@"usergone" callback:^(NSArray* data, SocketAckEmitter* ack) {
            if ([[[data objectAtIndex:0] objectForKey:@"left_user"] integerValue] == self.userProfileDetail.userID.integerValue) {
                
                self.status.text = [NSString stringWithFormat:@"%@ %@", KNSLOCALIZEDSTRING(@"Last seen:"),[self convertDateWithString:[[data objectAtIndex:0] objectForKeyNotNull:@"lastSeen" expectedObj:@""]]];
                self.status.font = [UIFont fontWithName:@"Candara" size:14];
                self.status.textColor = [UIColor blackColor];
            }
        }];
        
        //Socket ON method to check if user came online.
        [socket on:@"onlineuser" callback:^(NSArray* data, SocketAckEmitter* ack) {
            if ([[[data objectAtIndex:0] objectForKey:@"users"] isEqualToString:self.userProfileDetail.userID]) {
                self.status.text = @"Online";
                self.status.font = [UIFont fontWithName:@"Candara" size:16];
                self.status.textColor = [UIColor greenColor];
            }
        }];
        
        //Socket ON method to check if other has readed the message.
        [socket on:@"messageReaded" callback:^(NSArray* data, SocketAckEmitter* ack) {
            //check message read/unread status.
            if ([[[data objectAtIndex:0] objectForKey:@"flag"] isEqualToString:@"unread"]) {
                ZHCMessage * tempChatObject = [self.demoData.messages lastObject];
                NSLog(@"------+++++++%@",tempChatObject.messageReadStatus);
                tempChatObject.messageReadStatus = @"unread";
                [self.messageTableView reloadData];
            }else if ([[[data objectAtIndex:0] objectForKey:@"flag"] isEqualToString:@"read"]) {
                ZHCMessage * tempChatObject = [self.demoData.messages lastObject];
                
           // [self.messageMoreView ]
                for (ZHCMessage * tempChatObject in self.demoData.messages) {
                    tempChatObject.messageReadStatus = @"read";
                }
                
                NSLog(@"------+++++++%@",tempChatObject.messageReadStatus);
            }else if ([[[data objectAtIndex:0] objectForKey:@"flag"] isEqualToString:@"reached"]) {
                ZHCMessage * tempChatObject = [self.demoData.messages lastObject];
                NSLog(@"------+++++++%@",tempChatObject.messageReadStatus);
//                tempChatObject.messageReadStatus = @"reached";

                //Need to chk remove code if does not work.
                for (ZHCMessage * tempChatObject in self.demoData.messages) {
                    tempChatObject.messageReadStatus = [tempChatObject.messageReadStatus isEqualToString:@"read"]?@"read":@"reached";
                }
                
            }
            [self.messageTableView reloadData];
        }];
        
        [socket on:@"recieverTypingStatus" callback:^(NSArray* data, SocketAckEmitter* ack) {
            //check message Typing status.
            self.status.text = @"Typing...";
            self.status.textColor = [UIColor greenColor];
            self.status.font = [UIFont fontWithName:@"Candara" size:16];
        }];
    }
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
    //Get user infor
    NSMutableDictionary *dictTemp;
    if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
    }else{
        dictTemp = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
    }
    if (!self.userProfileDetail.isBlockStatus) {
        //Posting image via socket.
//        [socket emit:@"sendmessage" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"senderName" :[dictTemp valueForKey:@"username"] , @"image": [image getBase64String], @"receiverId": self.userProfileDetail.userID,@"receiverName": self.userProfileDetail.userName,@"type":@"media", @"receiverImage":[NSUSERDEFAULT boolForKey:@"isClientSide"] ? [[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"] valueForKey:@"profileimage"] : [[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"] valueForKey:@"profileimage"]}]];
        
    [socket emit:@"sendmessage" with:@[@{@"senderId": [NSUSERDEFAULT valueForKey:@"userID"], @"senderName" :[dictTemp valueForKey:@"username"] , @"image": [image getBase64String], @"receiverId": self.userProfileDetail.userID,@"receiverName": self.userProfileDetail.userName,@"type":@"media", @"receiverImage":[NSUSERDEFAULT boolForKey:@"isClientSide"] ? [[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"] valueForKey:@"profileimage"] : [[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"] valueForKey:@"profileimage"],@"userName":[dictTemp valueForKey:@"username"]}]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    //Creating new text messsage object and adding to message array.
    [self.demoData addPhotoMediaMessage:image];
    [self.messageTableView reloadData];
    [self finishSendingMessage];
}

-(void)requestToFetchUserChatHistory:(NSInteger)page {
    
    
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    [requestDict setValue:self.userProfileDetail.userID forKey:@"otherUserID"];
    [requestDict setValue:[NSNumber numberWithInteger:page] forKey:@"pageNumber"];
    
    NSString *apiName = [NSString stringWithFormat:@"chatHistory/%@/%@/%@",[NSUSERDEFAULT valueForKey:@"userID"],self.userProfileDetail.userID,[NSNumber numberWithInteger:page]];
    
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        
        
        if (!error) {
            
            [self parseChatHistoryData:result];
        }
        
    }];
    
    
}

-(void)requestToFetchLastSeen {
    
    NSString *apiName = [NSString stringWithFormat:@"lastSeen/%@",self.userProfileDetail.userID];
    [[OPServiceHelper sharedServiceHelper] GetAPICallWithParameter:[NSMutableDictionary dictionary] apiName:apiName WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            
            NSDictionary * lastSeenDict = [[result objectForKeyNotNull:@"data" expectedObj:[NSArray array]] firstObject];
            if ([[lastSeenDict objectForKeyNotNull:@"lastSeen" expectedObj:@""] length]) {
                self.status.text = [NSString stringWithFormat:@"%@ %@",KNSLOCALIZEDSTRING(@"Last seen:"),[self convertDateWithString:[lastSeenDict objectForKeyNotNull:@"lastSeen" expectedObj:@""]]];
                self.status.font = [UIFont fontWithName:@"Candara" size:14];
            }else {
                self.status.text = @"";
            }
        }
    }];
    
}


-(void)parseChatHistoryData:(id)response
{
    [refreshControl endRefreshing];
    if ([[[response objectForKeyNotNull:@"result" expectedObj:[NSDictionary dictionary]] objectForKeyNotNull:@"docs" expectedObj:[NSArray array]] count]) {
        NSMutableArray * chatArray = [ChatHistoryModel getChatHistory:[[response objectForKeyNotNull:@"result" expectedObj:[NSDictionary dictionary]] objectForKeyNotNull:@"docs" expectedObj:[NSArray array]]];
        maxPageNumber = [[[response objectForKeyNotNull:@"result" expectedObj:[NSDictionary dictionary]] objectForKeyNotNull:@"pages" expectedObj:@""] integerValue];
        
        NSInteger currentPage =   [[[response objectForKeyNotNull:@"result" expectedObj:[NSDictionary dictionary]] objectForKeyNotNull:@"page" expectedObj:@""] integerValue];
        
        if (currentPage == 1) {
            self.demoData = [[ZHCModelData alloc] initWithUserInfo:self.userProfileDetail WithChatHistory:chatArray];
            [self.messageTableView reloadData];
            
            [self finishSendingMessage];
            
            
            
        }else {
            
            for (int index = (int)[chatArray count] - 1; index >=0 ; index--) {
                
                ChatHistoryModel *obj =[chatArray objectAtIndex:index];
                ZHCMessage *message;
                if ([obj.messageType isEqualToString:@"audio"]) {
                    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",obj.fileUrl]];
                    ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
                    if ([obj.senderId isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
                        audioItem.appliesMediaViewMaskAsOutgoing = YES;
                    }else{
                        audioItem.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    message = [ZHCMessage messageWithSenderId:obj.senderId displayName:self.userProfileDetail.userName media:audioItem readStatus:obj.flag];
                    
                    
                }else if ([obj.messageType isEqualToString:@"media"]) {
                    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",obj.fileUrl]];
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:imageData];
                    ZHCPhotoMediaItem *photoItem = [[ZHCPhotoMediaItem alloc]initWithImage:image];
                    if ([obj.senderId isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
                        photoItem.appliesMediaViewMaskAsOutgoing = YES;
                    }else{
                        photoItem.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    message = [ZHCMessage messageWithSenderId:obj.senderId displayName:self.userProfileDetail.userName  media:photoItem readStatus:obj.flag];
                    
                }else if ([obj.messageType isEqualToString:@"location"]) {
                    //                            typeof(self) __weak weakSelf = self;
                    __weak ZHCMessagesTableView *weakView = self.messageTableView;
                    RowDataModal *tempObj = [[RowDataModal alloc] init];
                    tempObj.userLatitute = obj.latitude;
                    tempObj.userLongitute = obj.longitude;
                    tempObj.userName = self.userProfileDetail.userName;
                    tempObj.userID = obj.senderId;
                    tempObj.index = [chatArray count] - 1 - index;
                   
                    [self.demoData addLocationMediaMessageOfOtherUserWithCompletion:^{

                    [weakView reloadData];
                    //  [weakSelf finishSendingMessage];
                        
                    }WithInfo:tempObj MessageReadStatus:obj.flag];
                }else {
                    message = [[ZHCMessage alloc] initWithSenderId:obj.senderId senderDisplayName:self.userProfileDetail.userName date:[self convertStringToData:obj.time] text:obj.message messageReadStatus:obj.flag];
                }
               // [self.demoData.messages insertObject:message atIndex:0];

                if (!message) {
                    
                }else{
                    [self.demoData.messages insertObject:message atIndex:0];
                }
            }
            [self.messageTableView reloadData];
        }
    }else{
    }
}

-(NSDate*)convertStringToData:(NSString *)dateStr{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    return date;
    
}

//-(void)callAPIToUpdateUserStatus {
//    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
//    [parameterDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
//    [parameterDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
//    
//    OPServiceHelper * helper = [[OPServiceHelper alloc] init];
//    [helper PostAPICallWithParameter:parameterDict apiName:@"User/provider_inactivity" WithComptionBlock:^(id result, NSError *error) {
//    }];
//}

/**
 Copied from Chat controller to get the bubble size

 @return size of bubble for image
 */
- (CGSize)mediaViewDisplaySize
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 225.0f);
    }
    
    return CGSizeMake(210.0f, 150.0f);
}
@end
