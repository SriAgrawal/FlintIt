//
//  ServiceTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 06/06/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeNdateLAbel;
@property (weak, nonatomic) IBOutlet UILabel *serviceProviderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UIImageView *serviceTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clientImageView;

@end
