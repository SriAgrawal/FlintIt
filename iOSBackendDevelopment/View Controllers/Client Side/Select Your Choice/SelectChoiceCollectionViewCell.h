//
//  SelectChoiceCollectionViewCell.h
//  iOSBackendDevelopment
//
//  Created by Anshu on 02/04/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectChoiceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (strong, nonatomic) IBOutlet UIImageView *choiceImageView;
@property (strong, nonatomic) IBOutlet UILabel *choiceLabel;

@end
