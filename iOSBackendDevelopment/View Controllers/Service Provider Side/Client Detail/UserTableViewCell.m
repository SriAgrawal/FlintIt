//
//  UserTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.starRatingView setUserInteractionEnabled:NO];
    self.userImageView.layer.cornerRadius = 25;
    self.userImageView.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
