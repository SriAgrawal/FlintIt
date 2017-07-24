//
//  JobRequestCell.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface JobRequestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *clientImage;

@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *clientAge;
@property (weak, nonatomic) IBOutlet UILabel *clientAddress;
@property (weak, nonatomic) IBOutlet UILabel *jobName;
@property (weak, nonatomic) IBOutlet UILabel *timeNdateLAbel;

@property (weak, nonatomic) IBOutlet DXStarRatingView *viewStar;

@end
