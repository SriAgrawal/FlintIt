//
//  FavouritesTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 30/03/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "FavouritesTableViewCell.h"

@implementation FavouritesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.userImageView.layer setCornerRadius:35];
    [self.userImageView setClipsToBounds:YES];
    [self.starRatingView setUserInteractionEnabled:NO];
    
    [self.starRatingView setIsOnReview:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
