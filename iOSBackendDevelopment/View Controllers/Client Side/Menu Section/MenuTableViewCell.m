//
//  MenuTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 01/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.viewBackground setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.65]];
    [[self.countLabel layer] setCornerRadius:10.0f];
    [[self.countLabel layer] setMasksToBounds:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
