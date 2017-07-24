//
//  ServiceTrackingTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceTrackingTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *serviceNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *serviceProviderLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (strong, nonatomic) IBOutlet UIImageView *serviceTrackingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *serviceTypeImageView;


@end
