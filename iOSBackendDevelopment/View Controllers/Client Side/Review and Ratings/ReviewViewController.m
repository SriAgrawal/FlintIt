//
//  ReviewViewController.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"

static NSString *identifier = @"ReviewTableViewCell";

@interface ReviewViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *reviewTableView;

@property (weak, nonatomic) IBOutlet UILabel *reviewTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end

@implementation ReviewViewController
{
    NSMutableArray *userDataArray;
    
    //For Pagination
    BOOL isLoadMoreExecuting;
    CCPagination *pagination;
    UIRefreshControl *refreshControl;
}

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

-(void)initialSetup {
    //Register Cell
    [self.reviewTableView registerNib:[UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil] forCellReuseIdentifier:@"ReviewTableViewCell"];
    
    _reviewTitleLabel.text = KNSLOCALIZEDSTRING(@"Ratings and Reviews");
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.btnBack setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.btnBack setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];

    }
    //Alloc array
    userDataArray = [[NSMutableArray alloc]init];
    
    //Initalise For Pagination
    pagination = [[CCPagination alloc] init];
    pagination.pageNo = 0;
    
    [self addPullToRefresh];

    //Get Review And Rating List
    [self requestDictForReviewList:pagination];
    _reviewTableView.estimatedRowHeight = 98.0f;
    _reviewTableView.rowHeight = UITableViewAutomaticDimension;
    
}

-(void)addPullToRefresh{
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refereshTable) forControlEvents:UIControlEventValueChanged];
    [self.reviewTableView addSubview:refreshControl];
}

-(void)refereshTable {
    
    pagination.pageNo = 0;
    [self  requestDictForReviewList:pagination];
    [self performSelector:@selector(endrefresing) withObject:nil afterDelay:1.0];
}

-(void)endrefresing{
    [refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReviewTableViewCell *cell = (ReviewTableViewCell *)[self.reviewTableView dequeueReusableCellWithIdentifier:identifier];
    
    ReviewRelatedData *reviewList = [userDataArray objectAtIndex:indexPath.row];
    
    [cell.userNameLabel setText:reviewList.userName];
    [cell.userImageView sd_setImageWithURL:reviewList.profileImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [cell.descriptionLabel setText:reviewList.comment];
    [cell.starRatingView setStars:[reviewList.rating intValue]];
    [cell.sampleImageView sd_setImageWithURL:reviewList.jobImageURL placeholderImage:[UIImage imageNamed:@"user_icon"]];
    //added to show date
    [cell.dateLabel setText:reviewList.strDate];
    if ([[reviewList.jobImageURL absoluteString] isEqualToString:@""]) {
        [cell.sampleImageView setHidden:YES];
        [cell.zoomButton setHidden:YES];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) {
        
        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
            
            [self requestDictForReviewList:pagination];
        }
    }
}
/*********************** Service Implementation Methods ****************/

-(void)requestDictForReviewList:(CCPagination *)page {
    
    
    isLoadMoreExecuting = NO;
   
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    // change for user id
    [requestDict setObject:self.particularReviewDetail.userID forKey:@"review_id"];
    
    [requestDict setObject:[NSUSERDEFAULT valueForKey:@"userID"] forKey:pUserId];

    [requestDict setObject:@"10" forKey:pPageSize];
    [requestDict setObject:[NSString stringWithFormat:@"%ld",(long)[pagination.pageNo integerValue]+1] forKey:pPageNumber];
    [requestDict setObject:[[CDLanguageHandler sharedLocalSystem] getCurretLanguage] forKey:@"language_preference"];
    [requestDict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:pDeviceToken] forKey:pDeviceToken];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[OPServiceHelper sharedServiceHelper] PostAPICallWithParameter:requestDict apiName:@"Job/review_data" WithComptionBlock:^(id result, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            if ([pagination.pageNo integerValue] == 0) {
                [userDataArray removeAllObjects];
            }
            
            if ([[result objectForKeyNotNull:pResponseMsg expectedObj:@""] isEqualToString:KNSLOCALIZEDSTRING(@"No record found.")]) {
                UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.reviewTableView.bounds.size.width,  self.reviewTableView.bounds.size.height)];
                noDataLabel.text             = KNSLOCALIZEDSTRING([result objectForKeyNotNull:pResponseMsg expectedObj:@""]);
                noDataLabel.textColor        = [UIColor whiteColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.reviewTableView.backgroundView = noDataLabel;
                
                [self.reviewTableView reloadData];
            }else {
                isLoadMoreExecuting = YES;
                
                pagination = [CCPagination getPaginationInfoFromDict:[result objectForKeyNotNull:pPagination expectedObj:[NSDictionary dictionary]]];
                
                NSMutableArray *reviewArray = [result objectForKeyNotNull:pReviewList expectedObj:[NSArray array]];
                for (NSDictionary *dict in reviewArray) {
                    [userDataArray addObject:[ReviewRelatedData parseReviewList:dict]];
                }
                [self.reviewTableView reloadData];
            }

        }else
        {
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Error!") andMessage:error.localizedDescription onController:self.navigationController];

        }
    }];
    
    
}


@end
