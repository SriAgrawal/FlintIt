//
//  ServiceProviderEmailRow.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 15/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ServiceProviderEmailRow.h"

@implementation ServiceProviderEmailRow

- (void)awakeFromNib {

    [super awakeFromNib];
    [self.serviceProviderImageView.layer setCornerRadius:self.serviceProviderImageView.frame.size.width/2];
    [self.serviceProviderImageView.layer setBorderWidth:2];
    [self.serviceProviderImageView.layer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:150.0/255.0 alpha:1].CGColor];
    [self.serviceProviderImageView setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
