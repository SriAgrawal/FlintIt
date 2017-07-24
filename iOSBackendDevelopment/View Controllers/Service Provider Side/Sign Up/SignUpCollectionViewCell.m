//
//  SignUpCollectionViewCell.m
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 21/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "SignUpCollectionViewCell.h"
#import "EXPhotoViewer.h"

@implementation SignUpCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sampleImageView.layer.cornerRadius = 25;
    self.sampleImageView.clipsToBounds = YES;
}

- (IBAction)zoomButtonAction:(id)sender {
     [EXPhotoViewer showImageFrom:self.sampleImageView];
}

@end
