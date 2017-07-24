//
//  Reviews&RatingVC.m
//  iOSBackendDevelopment
//
//  Created by Ratneshwar Singh on 11/26/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ReviewsRatingVC.h"
#import "HeaderFile.h"
#import "ReviewRatingsCell.h"

@interface ReviewsRatingVC (){
    ReviewRelatedData* modalObj;
}

@property (weak, nonatomic) IBOutlet UILabel *navTitleLbl;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITableView *ratingTableView;

@end

@implementation ReviewsRatingVC

#pragma mark - UIViewController Life cycle methods & Memory Management Method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [appDelegate startLocation];
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method

-(void)initialSetup {
    
   
    _navTitleLbl.text = KNSLOCALIZEDSTRING(@"Ratings and Reviews");
    if (![_dataSourceArray count]) {
        [self noDataFound];
    }
    NSString * language = [[[NSBundle mainBundle] preferredLocalizations]objectAtIndex:0];
    if ([language isEqualToString:@"ar"])
    {
        [self.backBtn setImageEdgeInsets:UIEdgeInsetsMake(20,20, 0, 0)];
        [self.backBtn setImage:[UIImage imageNamed:@"back_rotate"] forState:UIControlStateNormal];
    }
    
    //Register Cell
    [self.ratingTableView registerNib:[UINib nibWithNibName:@"ReviewRatingsCell" bundle:nil] forCellReuseIdentifier:@"ReviewRatingsCell"];
    
    //Alloc Modal Class Object
    modalObj = [[ReviewRelatedData alloc]init];

    self.ratingTableView.rowHeight = UITableViewAutomaticDimension;
    self.ratingTableView.estimatedRowHeight = 250;
    
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    ReviewRatingsCell  *cell = (ReviewRatingsCell *)[self.ratingTableView dequeueReusableCellWithIdentifier:@"ReviewRatingsCell" forIndexPath:indexPath];
    modalObj = [_dataSourceArray objectAtIndex:indexPath.row];
    // added for date

    cell.dateLabel.text = modalObj.strDate;
    [cell.ratingView setIsOnReview:YES];
    [cell.ratingView setUserInteractionEnabled:NO];
    [cell.ratingView setStars:(int)[modalObj.rating integerValue]];
    cell.providerNameLbl.text =KNSLOCALIZEDSTRING(modalObj.userName);
    cell.descriptionView.text =KNSLOCALIZEDSTRING(modalObj.comment);
    [cell.providerImageView sd_setImageWithURL:modalObj.profileImageURL  placeholderImage:[UIImage imageNamed:@"user_icon"]];
    [cell.jobImageView sd_setImageWithURL:modalObj.jobImageURL  placeholderImage:[UIImage imageNamed:@"user_icon"]];
    if ([[modalObj.jobImageURL absoluteString] isEqualToString:@""]) {
        [cell.jobImageView setHidden:YES];
        [cell.zoomButton setHidden:YES];
    }
    return cell;
}

-(void)noDataFound{
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.ratingTableView.bounds.size.width,  self.ratingTableView.bounds.size.height)];
    noDataLabel.text             = KNSLOCALIZEDSTRING(@"No record found.");
    noDataLabel.textColor        = [UIColor whiteColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.ratingTableView.backgroundView = noDataLabel;
    [self.ratingTableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return UITableViewAutomaticDimension;
}
- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 10.0) {
        
//        if ([pagination.pageNo integerValue] < [pagination.maxPageNo integerValue] && isLoadMoreExecuting) {
//            
//            [self requestDictForReviewList:pagination];
//        }
    }
}


@end
