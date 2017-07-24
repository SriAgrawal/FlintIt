//
//  SignUpTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "SignUpTableViewCell.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"

@implementation SignUpTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.imageViewDrop setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
