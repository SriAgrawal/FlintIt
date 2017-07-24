//
//  JobRequestCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "JobRequestCell.h"

@implementation JobRequestCell

- (void)awakeFromNib {

    [super awakeFromNib];
    
    [self.clientImage.layer setCornerRadius:35];
    [self.clientImage setClipsToBounds:YES];
    [self.viewStar setUserInteractionEnabled:NO];
    
    [self.viewStar setIsOnReview:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
