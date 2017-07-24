//
//  ReviewViewController.h
//  iOSBackendDevelopment
//
//  Created by Priti Tiwari on 18/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController

@property (strong, nonatomic) RowDataModal *particularReviewDetail;
@property (strong, nonatomic) id delegate;

@end
