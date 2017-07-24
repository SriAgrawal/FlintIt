//
//  ServiceTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 06/06/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ServiceTableViewCell.h"

@implementation ServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _clientImageView.layer.cornerRadius = 40.0f;
    _clientImageView.layer.masksToBounds = YES;
    _serviceTypeImageView.layer.cornerRadius = 15.0f;
    _serviceTypeImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
