//
//  ReviewRelatedData.m
//  iOSBackendDevelopment
//
//  Created by Aiman Akhtar on 14/05/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "ReviewRelatedData.h"
#import "NSDictionary+NullChecker.h"
#import "DTConstants.h"

@implementation ReviewRelatedData

+(ReviewRelatedData *)parseReviewList:(NSDictionary *)ReviewList {
    ReviewRelatedData *reviewRowData = [[ReviewRelatedData alloc]init];
    
    reviewRowData.strDate = [ReviewList objectForKeyNotNull:@"review_date" expectedObj:@""];
    reviewRowData.userName = [ReviewList objectForKeyNotNull:pUserName expectedObj:@""];
    reviewRowData.rating = [ReviewList objectForKeyNotNull:pRating expectedObj:@""];        
    reviewRowData.comment = [ReviewList objectForKeyNotNull:pComment expectedObj:@""];
    reviewRowData.profileImage = [ReviewList objectForKeyNotNull:pProfileImage expectedObj:@""];
    reviewRowData.profileImageURL = [NSURL URLWithString:reviewRowData.profileImage];
    reviewRowData.jobImage = [ReviewList objectForKeyNotNull:pJobImage expectedObj:@""];
    reviewRowData.jobImageURL = [NSURL URLWithString:reviewRowData.jobImage];
    
    reviewRowData.block_status = [ReviewList objectForKeyNotNull:pblock_status expectedObj:@""];

    return reviewRowData;
}

@end
