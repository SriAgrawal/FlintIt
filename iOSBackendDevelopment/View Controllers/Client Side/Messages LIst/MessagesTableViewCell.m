//
//  MessagesTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "MessagesTableViewCell.h"

@implementation MessagesTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.userImageView.layer setCornerRadius:40];
    [self.userImageView setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
