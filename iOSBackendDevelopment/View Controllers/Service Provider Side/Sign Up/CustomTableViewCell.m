//
//  CustomTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by admin on 11/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "MacroFile.h"
#import "EXPhotoViewer.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
     [self.btnUpload setTitle:KNSLOCALIZEDSTRING(@"Upload your Exp Doc.") forState:UIControlStateNormal] ;
    // Configure the view for the selected state
}

- (IBAction)zoomOutButtonAction:(id)sender {
    [EXPhotoViewer showImageFrom:self.docImageView];

}

@end
