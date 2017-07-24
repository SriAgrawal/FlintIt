//
//  ReviewTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ReviewTableViewCell.h"
#import "EXPhotoViewer.h"

@implementation ReviewTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    
    [self.userImageView.layer setCornerRadius:35];
    [self.userImageView setClipsToBounds:YES];
    [self.sampleImageView.layer setCornerRadius:25];
    [self.sampleImageView setClipsToBounds:YES];
    [self.starRatingView setUserInteractionEnabled:NO];
    
    [self.starRatingView setIsOnReview:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)zoomButtonAction:(id)sender {
     [EXPhotoViewer showImageFrom:self.sampleImageView];
}

@end
