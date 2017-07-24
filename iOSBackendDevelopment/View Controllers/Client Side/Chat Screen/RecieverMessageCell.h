//
//  RecieverMessageCell.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecieverMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIView *cellbackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *imgSendImageView;
@property (strong, nonatomic) IBOutlet UIButton *zoomImageButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@end
