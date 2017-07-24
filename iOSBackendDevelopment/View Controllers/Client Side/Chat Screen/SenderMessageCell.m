//
//  SenderMessageCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "SenderMessageCell.h"

@implementation SenderMessageCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.cellbackgroundView.layer setCornerRadius:8.0];
    if (self.zoomImageButton.selected) {
        [self.zoomImageButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
