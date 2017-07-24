//
//  ReviewRelatedData.h
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 14/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewRelatedData : NSObject
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *rating;
@property (strong,nonatomic) NSString *comment;
@property (strong,nonatomic) NSString *profileImage;
@property (strong,nonatomic) NSURL    *profileImageURL;

@property (strong,nonatomic) NSString *jobImage;
@property (strong,nonatomic) NSURL    *jobImageURL;
@property (strong,nonatomic) NSString *strMessage;
@property (strong,nonatomic) NSString *strDate;


@property (strong,nonatomic) NSString *block_status;


+(ReviewRelatedData *)parseReviewList:(NSDictionary *)ReviewList;




@end
