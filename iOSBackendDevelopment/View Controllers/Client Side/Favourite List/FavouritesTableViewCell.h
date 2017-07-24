//
//  FavouritesTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Anshu on 30/03/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface FavouritesTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *workLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet DXStarRatingView *starRatingView;
@property (strong, nonatomic) IBOutlet UIImageView *categoryImageview;

@end
