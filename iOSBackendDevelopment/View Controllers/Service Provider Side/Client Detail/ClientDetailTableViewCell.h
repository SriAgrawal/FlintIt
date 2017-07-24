//
//  ClientDetailTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXStarRatingView.h"

@interface ClientDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *clientImage;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *clientAge;

@property (weak, nonatomic) IBOutlet UIButton *clientContactNumber;
@property (weak, nonatomic) IBOutlet UILabel *clientAddress;
@property (weak, nonatomic) IBOutlet DXStarRatingView *ratingView;

@end
