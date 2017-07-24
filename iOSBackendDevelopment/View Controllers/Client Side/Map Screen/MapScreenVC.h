//
//  MapScreenVC.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 20/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapScreenVC : UIViewController

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) NSString *mapSelectedCatagory;
@property (assign)BOOL isFromFavourite;

@end
