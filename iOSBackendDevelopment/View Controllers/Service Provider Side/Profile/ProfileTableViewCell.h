//
//  ProfileTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 14/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblData;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnContact;
@property (weak, nonatomic) IBOutlet UIView *baseView;

@end
