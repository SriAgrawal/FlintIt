//
//  Review&RatingsCell.m
//  iOSBackendDevelopment
//
//  Created by Ratneshwar Singh on 11/26/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ReviewRatingsCell.h"
#import "EXPhotoViewer.h"

@implementation ReviewRatingsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.providerImageView.layer.cornerRadius = 35.0f;
    self.providerImageView.clipsToBounds = YES;
    
    self.jobImageView.layer.cornerRadius = 25.0f;
    self.jobImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)zoomButtonAction:(id)sender {
    [EXPhotoViewer showImageFrom:self.jobImageView];
}


@end
