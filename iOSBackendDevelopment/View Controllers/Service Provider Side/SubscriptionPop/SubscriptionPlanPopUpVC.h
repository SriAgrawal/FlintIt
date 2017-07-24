//
//  CustomPopUpVC.h
//  CustomPopUp
//
//  Created by Pushpraj Chaudhary on 23/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DemoPopDelegate<NSObject>
-(void)cancelButtonMethod;
@end
@interface SubscriptionPlanPopUpVC : UIViewController

@property (strong , nonatomic)id<DemoPopDelegate> delegate;

@end
