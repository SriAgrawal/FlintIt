//
//  GenderTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@end
