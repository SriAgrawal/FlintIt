//
//  ReportProfileVC.h
//  iOSBackendDevelopment
//
//  Created by Arjun Hastir on 26/03/16.
//  Copyright © 2016 Mobiloitte technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RowDataModal.h"

@interface ReportProfileVC : UIViewController

@property (strong, nonatomic) RowDataModal *particularReportDetail;
@property (strong, nonatomic) id delegate;

@end
