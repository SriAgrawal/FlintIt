//
//  ProfileViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 14/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "PhotosTableViewCell.h"
#import "ProfileCollectionCell.h"
#import "CustomTableViewCell.h"
#import "HeaderFile.h"

static NSString *cellIdentifier = @"ProfileTableViewCell";
static NSString *cellIdentifierSecond = @"PhotosTableViewCell";
static NSString *cellIdentifierThird = @"CustomTableViewCell";


@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UserInfo *modalObject;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet UITableView *profileTableView;

@property (weak, nonatomic) IBOutlet UIButton *btnUserImage;

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnmenu;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak,nonatomic ) NSString *phoneNumber;


@end

@implementation ProfileViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Get Profile Detail
    [self initialSetup];
    [self requestDictForGettingProfileDetail];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Method

-(void)initialSetup {
    
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnEdit setImageEdgeInsets:UIEdgeInsetsMake(20,0, 0, 20)];
        [self.btnmenu setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
    } else if ([language isEqualToString:@"es"]) {
        
        _lblNavTitle.text = KNSLOCALIZEDSTRING(@"Profile");
    }

    _lblNavTitle.text = KNSLOCALIZEDSTRING(@"Profile");

    
    
    //Register the tableView Cell
    [self.profileTableView registerNib:[UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProfileTableViewCell"];
    [self.profileTableView registerNib:[UINib nibWithNibName:@"PhotosTableViewCell" bundle:nil] forCellReuseIdentifier:@"PhotosTableViewCell"];
    [self.profileTableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomTableViewCell"];

    //Set Table View Header & Footer
    [self.profileTableView setTableHeaderView:self.headerView];
    
    //Set Layout of ImageView
    self.btnUserImage.layer.cornerRadius = 50;
    [self.btnUserImage setClipsToBounds:YES];

    //Alloc Modal Class Object
    modalObject = [[UserInfo alloc]init];

   self.profileTableView.rowHeight = UITableViewAutomaticDimension;
    self.profileTableView.estimatedRowHeight = 100;
}

#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 5) {
        CustomTableViewCell *cell = (CustomTableViewCell *)[self.profileTableView dequeueReusableCellWithIdentifier:cellIdentifierThird];
        [cell.docImageView sd_setImageWithURL:modalObject.strDocumentUploadURL placeholderImage:[UIImage imageNamed:@"icon"]];
        cell.viewLeftconstraint.constant = 1.0f;
        cell.viewRightConstraint.constant = 1.0f;
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"ar"]) {
            cell.btnUpload.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
        return cell;
    }
    else if(indexPath.row == 11) {
           PhotosTableViewCell *cell = (PhotosTableViewCell *)[self.profileTableView dequeueReusableCellWithIdentifier:cellIdentifierSecond];
        // Initialization code
//        if ([modalObject.sampleImageArrayURL count]) {
//            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//            flowLayout.itemSize = CGSizeMake(50.0, 50.0);
//            flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
//            [cell.collectionView setCollectionViewLayout:flowLayout];
//        }

        [cell.lblPhotos setText:KNSLOCALIZEDSTRING(@"Photos")];
        [cell.collectionView setBackgroundColor:[UIColor clearColor]];
        [cell.collectionView registerNib:[UINib nibWithNibName:@"ProfileCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ProfileCollectionCell"];
        [cell.collectionView setDelegate:self];
        [cell.collectionView setDataSource:self];
        [cell.btnLeftArrow addTarget:self action:@selector(button_leftAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnRightArrow addTarget:self action:@selector(button_rightAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnLeftArrow.hidden = ![modalObject.sampleImageArrayURL count];
        cell.btnRightArrow.hidden = ![modalObject.sampleImageArrayURL count];
        [cell.collectionView reloadData];
        return cell;
    }
    else {
        ProfileTableViewCell *cell = (ProfileTableViewCell *)[self.profileTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell.btnContact setHidden:YES];
        [cell.lblDescription setHidden:NO];
        
        switch (indexPath.row) {
            case 0: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Name");
                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:10.0f]];
                cell.lblDescription.text = modalObject.strUsername;
            }
                break;
            case 1: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Age");
                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:10.0f]];
                cell.lblDescription.text = modalObject.strAge;
            }
                break;
            case 2: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Email Address");
                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:10.0f]];
                cell.lblDescription.text = modalObject.strEmailAddress;
                }
                break;
            case 3: {
                [cell.lblDescription setHidden:YES];
                [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:10.0f]];
                [cell.btnContact setHidden:NO];
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Contact Number");
                cell.btnContact.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [cell.btnContact setTitle:modalObject.strContact forState:UIControlStateNormal];
                [cell.btnContact setImage:[UIImage new] forState:UIControlStateNormal];
                _phoneNumber = modalObject.strContact ;
//                [cell.btnContact addTarget:self action:@selector(contactBtnACtion:) forControlEvents:UIControlEventTouchUpInside];
                }
                break;
            case 4: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Language Known");
                cell.lblDescription.text = modalObject.strLanguage;
                }
                break;
            case 6: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Gender");
                cell.lblDescription.text = modalObject.strGender;
                }
                break;
            case 7: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Price/Hour");
                 [cell.lblDescription setFont:[UIFont fontWithName:@"System" size:10.0f]];
                cell.lblDescription.text = modalObject.strPrice;
                }
                break;
            case 8: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Category");
                NSArray * arrayOfCat = [modalObject.strCategory componentsSeparatedByString:@","];
                NSMutableArray * arrayOfLocalisedStr = [NSMutableArray new];
                for (NSString * str in arrayOfCat) {
                    [arrayOfLocalisedStr addObject:KNSLOCALIZEDSTRING(str)];
                }
                NSString * strOfCat =  [arrayOfLocalisedStr componentsJoinedByString:@","];
                cell.lblDescription.text = strOfCat;
            }
                break;
            case 9: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Description");
                cell.lblDescription.text = modalObject.strDescription;
            }
                break;
            case 10: {
                cell.lblData.text = KNSLOCALIZEDSTRING(@"Distance Preference");
                cell.lblDescription.text = modalObject.strDistance;
                }
                break;
            default:
                break;
        }
    return cell;
    }
}




-(void)button_leftAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.profileTableView];
    NSIndexPath *indexPath = [self.profileTableView indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.profileTableView cellForRowAtIndexPath:indexPath];
    
    if (modalObject.sampleImageArray.count) {
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionLeft
                                            animated:YES];
    }
    
    
    
}
-(void)button_rightAction:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.profileTableView];
    NSIndexPath *indexPath = [self.profileTableView indexPathForRowAtPoint:buttonPosition];
    
    ScrollTableViewCell *cell = (ScrollTableViewCell *)[self.profileTableView cellForRowAtIndexPath:indexPath];
    if (modalObject.sampleImageArray.count) {
        NSInteger section=[cell.collectionView numberOfSections]-1;
        NSInteger item = [cell.collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
        [cell.collectionView scrollToItemAtIndexPath:lastIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionRight
                                            animated:YES];
    }
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 if(indexPath.row == 11)
 {
     return 100;
 }
    else
        return UITableViewAutomaticDimension;

}

-(void)contactBtnACtion : (UIButton *) sender {
    NSString *phoneNumber = self.phoneNumber;
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        // Show an error message: Your device can not do phone calls.
    }

}

#pragma mark - UICollectionView Delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [modalObject.sampleImageArrayURL count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCollectionCell *cell =(ProfileCollectionCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionCell" forIndexPath:indexPath];
    
    [cell.profileImageView sd_setImageWithURL:[modalObject.sampleImageArrayURL objectAtIndex:indexPath.row] placeholderImage:nil];
    
    return cell;
}


- (IBAction)btnMenu:(id)sender {
    [self.view endEditing:YES];

      [self.sidePanelController showLeftPanelAnimated:YES];
}

- (IBAction)btnEdit:(id)sender {
    EditProfileViewController *editProfileObject = [[EditProfileViewController alloc]initWithNibName:@"EditProfileViewController" bundle:nil];
    editProfileObject.delegate = self;
    editProfileObject.modalObject = modalObject;
    [self.navigationController pushViewController:editProfileObject animated:YES];
}

/*********************** Service Implementation Methods ****************/

-(void)requestDictForGettingProfileDetail {
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setValue:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];
    
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"User/user_profile" WithComptionBlock:^(id result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
        modalObject = [UserInfo parseResponseForProfileDetail:result];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.btnUserImage sd_setBackgroundImageWithURL:modalObject.strUploadURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon"]];
            
            
        });
        [self.profileTableView reloadData];
        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:error.localizedDescription onController:self];

        }

    }];
    
}


-(void)methodForUpdateDetail:(UserInfo *)userDetail {
//    modalObject = userDetail;
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [self.btnUserImage setBackgroundImageWithURL:modalObject.strUploadURL placeholderImage:[UIImage imageNamed:@"user_icon"] forState:UIControlStateNormal];
//        
//    });
//
//    [self.profileTableView reloadData];

}

@end
