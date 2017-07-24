//
//  SignUpTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 25/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *signUpTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewDrop;

@property (weak, nonatomic) IBOutlet UIButton *pickerButton;
@property (weak, nonatomic) IBOutlet UIButton *contactPrefixButton;
@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;

@end
