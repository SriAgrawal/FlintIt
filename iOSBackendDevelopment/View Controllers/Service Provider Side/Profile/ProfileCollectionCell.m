//
//  ProfileCollectionCell.m
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ProfileCollectionCell.h"
#import "EXPhotoViewer.h"

@implementation ProfileCollectionCell

- (void)awakeFromNib {

    [super awakeFromNib];
    self.profileImageView.layer.cornerRadius = 25;
    self.profileImageView.clipsToBounds = YES;
}

- (IBAction)zoomOutButtonAction:(id)sender {
    [EXPhotoViewer showImageFrom:self.profileImageView];

}

@end
