//
//  BlockListCell.h
//  iOSBackendDevelopment
//
//  Created by Yogesh Pal on 08/12/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFile.h"

@interface BlockListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *blockTimeLbl;

@end
