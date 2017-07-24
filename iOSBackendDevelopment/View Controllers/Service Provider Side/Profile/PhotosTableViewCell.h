//
//  PhotosTableViewCell.h
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *outerView;
@property (strong, nonatomic) IBOutlet UILabel *lblPhotos;
@property (strong, nonatomic) IBOutlet UIButton *btnLeftArrow;
@property (strong, nonatomic) IBOutlet UIButton *btnRightArrow;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
