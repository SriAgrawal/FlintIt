//
//  NotificationTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
