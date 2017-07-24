//
//  ScrollTableViewCell.m
//  iOSBackendDevelopment
//
//  Created by Aditi Tiwari on 21/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ScrollTableViewCell.h"

@implementation ScrollTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

//- (IBAction)leftArrowButtonAction:(id)sender {
//    
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
//                                    atScrollPosition:UICollectionViewScrollPositionLeft
//                                            animated:YES];
//    
//}
//
//- (IBAction)rightArrowButtonAction:(id)sender {
//    
//    NSInteger section=[self.collectionView numberOfSections]-1;
//    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
//    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
//    
//        [self.collectionView scrollToItemAtIndexPath:lastIndexPath
//                                    atScrollPosition:UICollectionViewScrollPositionRight
//                                            animated:YES];
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
