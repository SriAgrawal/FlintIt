//
//  GenderTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "GenderTableViewCell.h"
#import "MacroFile.h"

@implementation GenderTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    [self.maleButton setTitle:KNSLOCALIZEDSTRING(@"Male") forState:UIControlStateNormal] ;
    [self.femaleButton setTitle:KNSLOCALIZEDSTRING(@"Female") forState:UIControlStateNormal] ;
    _genderLabel.text = KNSLOCALIZEDSTRING(@"Gender");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
