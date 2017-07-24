//
//  OPServiceHelper.h
//  Openia
//
//  Created by Sunil Verma on 25/03/16.
//  Copyright © 2016 Mobiloitte Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^RequestComplitopnBlock)(id result, NSError  *error);


@interface OPServiceHelper : NSObject

+(id)sharedServiceHelper;

-(NSString *)getCountryDialingCode;
-(void)cancelGetRequestSession;
-(void)cancelPostRequestSession;


// use to call get apis

-(void)GetAPICallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName   WithComptionBlock:(RequestComplitopnBlock)block;

// Use to call post apis
-(void)PostAPICallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  WithComptionBlock:(RequestComplitopnBlock)block;

// use to down load 

-(void)multipartApiCallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  WithComptionBlock:(RequestComplitopnBlock)block;



@end
