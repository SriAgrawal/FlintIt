//
//  Pagination.h
//  JerryApp
//
//  Created by Raj Kumar on 3/30/15.
//  Copyright (c) 2015 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCPagination : NSObject

@property (nonatomic, strong) NSString  *pageNo;
@property (nonatomic, strong) NSString  *maxPageNo;
@property (nonatomic, strong) NSString  *pageSize;
@property (nonatomic, strong) NSString  *totalNumberOfRecords;

+(CCPagination *)getPaginationInfoFromDict : (NSDictionary *)data;

@end
