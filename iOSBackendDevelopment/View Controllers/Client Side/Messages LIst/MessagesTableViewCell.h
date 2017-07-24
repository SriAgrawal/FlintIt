//
//  MessagesTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 26/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *userlabel;
@property (weak, nonatomic) IBOutlet UILabel *userMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
