//
//  EmailViewVC.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 15/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailDataModal.h"

@protocol DelegateForDeleteEmailRow <NSObject>

-(void)previousObject:(EmailDataModal *)oldEmailListObj andModifyObject:(EmailDataModal *)newEmailListObj andIsArrayEmpty:(BOOL)isArrayEmpty;

@end

@interface EmailViewVC : UIViewController

@property(nonatomic,strong) EmailDataModal *emailListObj;

@property(nonatomic,strong) id delegate;

@end
