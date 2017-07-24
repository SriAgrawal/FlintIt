//
//  SignUpCollectionViewCell.h
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 21/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *sampleImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomButton;

@end
