//
//  EmailVC.h
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailDataModal.h"

@protocol DelegateForUpdateEmailList <NSObject>

-(void)updateEmailList:(EmailDataModal *) emailListObj;

@end

@interface EmailVC : UIViewController

@property (strong, nonatomic) id particularDetail;
@property(nonatomic,strong) id delegate;

@end
