//
//  CategoryNameTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by admin on 09/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "CategoryNameTableViewCell.h"

@implementation CategoryNameTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.starRatingView setUserInteractionEnabled:NO];
    
    //Set Image Outlet
    [self.userImageView.layer setCornerRadius:35];
    [self.userImageView setClipsToBounds:YES];
    
    [self.starRatingView setIsOnReview:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
