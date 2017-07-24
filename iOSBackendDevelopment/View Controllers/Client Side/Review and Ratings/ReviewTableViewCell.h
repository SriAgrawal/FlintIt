//
//  ReviewTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface ReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet DXStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sampleImageView;
@property (weak, nonatomic) IBOutlet UIButton *zoomButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
