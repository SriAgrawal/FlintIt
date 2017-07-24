//
//  DescriptionTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by admin on 11/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "DescriptionTableViewCell.h"

@implementation DescriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.descriptionTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
