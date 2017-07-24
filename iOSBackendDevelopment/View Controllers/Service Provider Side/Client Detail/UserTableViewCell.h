//
//  UserTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet DXStarRatingView *starRatingView;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
