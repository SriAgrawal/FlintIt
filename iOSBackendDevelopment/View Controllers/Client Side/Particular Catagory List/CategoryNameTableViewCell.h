//
//  CategoryNameTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by admin on 09/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface CategoryNameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (strong, nonatomic) IBOutlet DXStarRatingView *starRatingView;

@property (weak, nonatomic) IBOutlet UILabel *catagoryLbl;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblreview;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;

@end
