//
//  LoginCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 23/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "LoginCell.h"

@implementation LoginCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.cellView.layer setCornerRadius:self.cellView.frame.size.height/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
