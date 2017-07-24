//
//  SelectChoiceVC.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"

static NSString *cellIdentifier = @"SelectChoiceCollectionViewCell";

@interface SelectChoiceVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSDictionary *dictDataArray;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblSelectChoice;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (strong, nonatomic) IBOutlet UICollectionView *choiceCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *notificationCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificaionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *notifictionImageView;

@end

@implementation SelectChoiceVC

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self callApiToGetUnreadCount];
}
#pragma mark - Helper Method

-(void)initialSetup {
    
    [_notifictionImageView setTintColor:[UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:163.0/255.0 alpha:1]];

    [_notificationCountLabel setHidden:YES];
    _notificaionBtn.layer.cornerRadius = 18.0;
    _notificaionBtn.layer.masksToBounds = YES;
    _notificationCountLabel.layer.cornerRadius = 10.0;
    _notificationCountLabel.layer.masksToBounds = YES;
    _lblSelectChoice.text = KNSLOCALIZEDSTRING(@"Select Your Choice");
    //Set Title and Corresponding Image    
       NSArray *titleArray = [[NSArray alloc]initWithObjects:@"All",@"Bodyguards",@"Chefs",@"Clean Worker",@"Consultation",@"Gardener",@"Decoration",@"Moving",@"Painter",@"Plumber",@"Towing",@"Carpenter",@"IT",@"Exterminator",@"Electrician",@"Mechanic",@"Health",@"Beauty",@"Tutor",@"Tailor",@"Snow Shoveling",@"Car wash",@"Photographer",@"Fun & Party",@"Black Smithy",@"Artist",@"Air Cooling",nil];
       NSArray *imageArray = [[NSArray alloc]initWithObjects:@"all",@"icn",@"chef_icon",@"clean_icon",@"icn2",@"gandener_icon",@"decoration_icon",@"moving_icon",@"painter_icon",@"plumber_icon",@"towing_icon",@"carpenter_icon",@"IT_icon",@"extermintor_icon",@"electrician_icon",@"m",@"health_icon1",@"beauty_icon",@"tutor_icon",@"tailor_icon",@"snow_icon",@"car_wash_icon",@"photo",@"fun_icon",@"smithy_icon",@"draw_icon",@"micn2",nil];
    dictDataArray = [[NSDictionary alloc]initWithObjectsAndKeys:titleArray,@"TITLE",imageArray,@"IMAGE", nil];
    
    //Set Delegate and Datasouce of CollectionView
    [_choiceCollectionView setDataSource:self];
    [_choiceCollectionView setDelegate:self];
    
    //Register the Cell
    [_choiceCollectionView registerNib:[UINib nibWithNibName:@"SelectChoiceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnMenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callApiToGetUnreadCount) name:@"getUnreadCount" object:nil];

}

/**
 get unread count when receive a notification
 */
-(void)callApiToGetUnreadCount{
    [self requestDictForCount];
    
}
#pragma mark - UICollectionView DataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[dictDataArray valueForKey:@"TITLE"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectChoiceCollectionViewCell *cell = (SelectChoiceCollectionViewCell *)[_choiceCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.alertLabel.hidden = YES;
    cell.choiceLabel.text = KNSLOCALIZEDSTRING([[dictDataArray valueForKey:@"TITLE"] objectAtIndex:indexPath.row]);
    cell.choiceImageView.image = [UIImage imageNamed:[[dictDataArray valueForKey:@"IMAGE"] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (SCREEN_WIDTH == 320) {
        return CGSizeMake(90, 100);
    }else
      return CGSizeMake(100, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *catagoryName = KNSLOCALIZEDSTRING([[dictDataArray valueForKey:@"TITLE"] objectAtIndex:indexPath.row]);

    CategoryNameVC *catagoryObj = [[CategoryNameVC alloc]initWithNibName:@"CategoryNameVC" bundle:nil];
    catagoryObj.selectedCatagory = catagoryName;
    [self.navigationController pushViewController:catagoryObj animated:YES];
}

#pragma mark - UIButton Actions

- (IBAction)menuAction:(id)sender {
    [self.view endEditing:YES];

    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (IBAction)notificationBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [self requestDictForReadUnread:@"notification"];
}

-(void)requestDictForCount {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/get_count_read" WithComptionBlock:^(id result, NSError *error) {
        
        if (!error) {
            
           NSString * strCount = [result objectForKeyNotNull:@"notification" expectedObj:@""];
            [_notificationCountLabel setHidden:[strCount intValue]>0?NO:YES];
           _notificationCountLabel.text = strCount;
        }
        
    }];
    
    
}
-(void)requestDictForReadUnread:(NSString *)type {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    [requestDict setValue:type forKey:@"type"];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Message/read_unread_status" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            if ([[result objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"notification"]) {
                NotificationViewController *notificationObject = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
                notificationObject.isFromSelectYourChoice = YES;
                [_notificationCountLabel setHidden:YES];
                [self.navigationController pushViewController:notificationObject animated:YES];
            }
        }
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getUnreadCount" object:nil];
}


@end
