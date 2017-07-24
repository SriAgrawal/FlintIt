//
//  ClientDetailTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Administrator on 4/25/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ClientDetailTableViewCell.h"

@implementation ClientDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.clientImage.layer.cornerRadius = 35;
    self.clientImage.clipsToBounds = YES;
    [self.ratingView setIsOnReview:YES];

   }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
