//
//  ServiceTrackingTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "ServiceTrackingTableViewCell.h"

@implementation ServiceTrackingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _serviceTrackingImageView.layer.cornerRadius = 40.0f;
    _serviceTrackingImageView.layer.masksToBounds = YES;
    _serviceTypeImageView.layer.cornerRadius = 20.0f;
    _serviceTypeImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
