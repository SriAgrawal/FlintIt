//
//  ScrollTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 21/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *outerView;
@property (strong, nonatomic) IBOutlet UILabel *lblSampleWork;
@property (strong, nonatomic) IBOutlet UIButton *btnLeftArrow;
@property (strong, nonatomic) IBOutlet UIButton *btnRightArrow;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
