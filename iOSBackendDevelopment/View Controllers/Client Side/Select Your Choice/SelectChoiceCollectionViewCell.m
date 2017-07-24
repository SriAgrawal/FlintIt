//
//  SelectChoiceCollectionViewCell.m
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import "SelectChoiceCollectionViewCell.h"

@implementation SelectChoiceCollectionViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    [_alertLabel.layer setCornerRadius:10];
    [_alertLabel setBackgroundColor:[UIColor colorWithRed:176/255.0 green:4/255.0 blue:17/255.0 alpha:1.0]];
    _alertLabel.layer.masksToBounds = YES;

}

@end
