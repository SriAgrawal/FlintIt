//
//  MenuTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Anshu on 01/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *menuImageView;

@property (strong, nonatomic) IBOutlet UILabel *menuLabel;

@property (strong, nonatomic) IBOutlet UISwitch *switchButton;

@property (weak, nonatomic) IBOutlet UIView *viewBackground;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
