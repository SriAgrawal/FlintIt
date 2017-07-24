//
//  Review&RatingsCell.h
//  iOSBackendDevelopment
//
//  Created by Ratneshwar Singh on 11/26/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFile.h"

@interface ReviewRatingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *providerNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *providerImageView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionView;
@property (weak, nonatomic) IBOutlet UIImageView *jobImageView;
@property (weak, nonatomic) IBOutlet UIButton *zoomButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
