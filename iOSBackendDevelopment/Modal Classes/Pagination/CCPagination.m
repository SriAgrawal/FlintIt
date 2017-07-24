//
//  Pagination.m
//  JerryApp
//
//  Created by Raj Kumar on 3/30/15.
//  Copyright (c) 2015 Mobiloitte. All rights reserved.
//

#import "NSDictionary+NullChecker.h"
#import "CCPagination.h"
#import "DTConstants.h"

@implementation CCPagination

+(CCPagination *)getPaginationInfoFromDict : (NSDictionary *)data {
    
    CCPagination *page = [[CCPagination alloc] init];
    
    page.pageNo = [data objectForKeyNotNull:pPageNumber expectedObj:@""];
    page.pageSize = [data objectForKeyNotNull:pPageSize expectedObj:@""];;
    page.maxPageNo = [data objectForKeyNotNull:pMaximumPageNumber expectedObj:@""];
    page.totalNumberOfRecords = [data objectForKeyNotNull:pTotalNumberOfRecord expectedObj:@""];
    
    return page;
}

@end
