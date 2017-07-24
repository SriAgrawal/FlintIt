//
//  FilterVC.h
//  iOSBackendDevelopment
//
//  Created by Anshu on 30/03/16.
//  Copyright (c) 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPagination.h"

@protocol DelegateForListAfterFilter <NSObject>

-(void)methodForListAfterFilter:(NSMutableArray *)listArray andPaginationInformation:(CCPagination *)pageInformation;

@end

@interface FilterVC : UIViewController

@property(strong,nonatomic) id delegate;

@property(strong,nonatomic) NSString *catagoryName;

@end
