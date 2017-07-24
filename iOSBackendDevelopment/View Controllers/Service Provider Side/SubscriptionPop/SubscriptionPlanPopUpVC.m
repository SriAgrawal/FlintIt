//
//  CustomPopUpVC.m
//  CustomPopUp
//
//  Created by Pushpraj Chaudhary on 23/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "HeaderFile.h"
#import "SubscriptionPlanPopUpVC.h"

@interface SubscriptionPlanPopUpVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *array_plan;
}
- (IBAction)cancelButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *view_Outer;
@property (strong, nonatomic) IBOutlet UITableView *tableView_SubscriptionPopUp;
@property (weak, nonatomic) IBOutlet UILabel *labelChooseYourPaln;

@end
@implementation SubscriptionPlanPopUpVC

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self initialSetUp];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Helper Methods
-(void) initialSetUp
{
    [self.tableView_SubscriptionPopUp registerNib:[UINib nibWithNibName:@"SubscriptionPopUpTableCell" bundle:nil] forCellReuseIdentifier:@"SubscriptionPopUpTableCell"];
    
    array_plan = [[NSMutableArray alloc] initWithObjects:@"1 Month - $10",@"3 Months - $25",@"6 Months - $50",@"12 Months - $70", nil];
    
    self.view_Outer.layer.cornerRadius = 10.0;
    self.view_Outer.layer.masksToBounds = YES;
    [self.view_Outer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [_labelChooseYourPaln setText:KNSLOCALIZEDSTRING(@"Choose Your Subscription Plan")];

}
#pragma mark - UITableView DataSource and Delegate methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array_plan.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        SubscriptionPopUpTableCell *cell = (SubscriptionPopUpTableCell *)[self.tableView_SubscriptionPopUp dequeueReusableCellWithIdentifier:@"SubscriptionPopUpTableCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.label_PlanDetail.text = [array_plan objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        cell.label_Separator.hidden= YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Congratulations") andMessage:KNSLOCALIZEDSTRING(@"Your subscription is activated for one month") onController:self];
            break;
        case 1:
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Congratulations") andMessage:KNSLOCALIZEDSTRING(@"Your subscription is activated for three months") onController:self];
            break;
        case 2:
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Congratulations") andMessage:KNSLOCALIZEDSTRING(@"Your subscription is activated for six months") onController:self];
            break;
        case 3:
            [[AlertView sharedManager] displayInformativeAlertwithTitle:KNSLOCALIZEDSTRING(@"Congratulations") andMessage:KNSLOCALIZEDSTRING(@"Your subscription is activated for one year") onController:self];
            break;
        default:
            break;
    }
    [self.delegate cancelButtonMethod];

}

#pragma mark - UIButton Action Methods
- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate cancelButtonMethod];
}


@end
