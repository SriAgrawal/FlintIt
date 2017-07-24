//
//  PhotosTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 22/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "PhotosTableViewCell.h"

@implementation PhotosTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (IBAction)leftArrowButtonAction:(id)sender {
//    
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
//                                atScrollPosition:UICollectionViewScrollPositionLeft
//                                        animated:YES];
//    
//}
//
//- (IBAction)rightArrowButtonAction:(id)sender {
//    
//    NSInteger section=[self.collectionView numberOfSections]-1;
//    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
//    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
//    
//    [self.collectionView scrollToItemAtIndexPath:lastIndexPath
//                                atScrollPosition:UICollectionViewScrollPositionRight
//                                        animated:YES];
//}

@end
