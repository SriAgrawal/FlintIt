//
//  CustomTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by admin on 11/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnUpload;
@property (strong, nonatomic) IBOutlet UIImageView *docImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewLeftconstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewRightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutButton;

@end
