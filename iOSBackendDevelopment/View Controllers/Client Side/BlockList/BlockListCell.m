//
//  BlockListCell.m
//  iOSBackendDevelopment
//
//  Created by Yogesh Pal on 08/12/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "BlockListCell.h"

@implementation BlockListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userImageView.layer.cornerRadius = 35.0f;
    self.userImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
