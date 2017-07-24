//
//  UserInfo.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 23/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "UserInfo.h"
#import "DTConstants.h"
#import "NSDictionary+NullChecker.h"
#import "NSString+CC.h"
#import "UIImage+CC.h"

@implementation UserInfo

+(UserInfo *)parseResponseForProfileDetail:(NSDictionary *)responseDict {
    UserInfo *userInfoObject = [[UserInfo alloc]init];
    
    userInfoObject.strUsername = [responseDict objectForKeyNotNull:pUserName expectedObj:@""];
    userInfoObject.strEmailAddress = [responseDict objectForKeyNotNull:pEmailID expectedObj:@""];
    userInfoObject.strAge = [responseDict objectForKeyNotNull:pAge expectedObj:@""];
    
    NSString *stateString = [responseDict objectForKeyNotNull:pState expectedObj:@""];
    NSString *countryString = [responseDict objectForKeyNotNull:pCountry expectedObj:@""];
    
    if ([TRIM_SPACE(stateString) length] && [TRIM_SPACE(countryString) length]) {
        userInfoObject.strLocation = [NSString stringWithFormat:@"%@, %@",[responseDict objectForKeyNotNull:pState expectedObj:@""],[responseDict objectForKeyNotNull:pCountry expectedObj:@""]];
    }else if ([TRIM_SPACE(stateString) length] && [TRIM_SPACE(countryString) length] == 0) {
        userInfoObject.strLocation = [NSString stringWithFormat:@"%@",[responseDict objectForKeyNotNull:pState expectedObj:@""]];
    }else if ([TRIM_SPACE(stateString) length]  == 0 && [TRIM_SPACE(countryString) length]){
        userInfoObject.strLocation = [NSString stringWithFormat:@", %@",[responseDict objectForKeyNotNull:pCountry expectedObj:@""]];
    }
    
    userInfoObject.strAddress = [responseDict objectForKeyNotNull:pAddress expectedObj:@""];
    userInfoObject.strContact = [responseDict objectForKeyNotNull:pContactNumber expectedObj:@""];
    userInfoObject.strOTP = [responseDict objectForKeyNotNull:pOTP expectedObj:@""];
    userInfoObject.strDistance = [responseDict objectForKeyNotNull:pDistancePreference expectedObj:@""];
    userInfoObject.strCategory = [responseDict objectForKeyNotNull:pCategory expectedObj:@""];
    userInfoObject.strPrice = [responseDict objectForKeyNotNull:pPrice expectedObj:@""];
    userInfoObject.strLanguage = [responseDict objectForKeyNotNull:pLanguage expectedObj:@""];
    userInfoObject.strGender = [responseDict objectForKeyNotNull:pGender expectedObj:@""];
    userInfoObject.strDescription = [responseDict objectForKeyNotNull:pDescription expectedObj:@""];
    userInfoObject.strPhonePrefix = [responseDict objectForKeyNotNull:pCountryCode expectedObj:@""];
    userInfoObject.strJobName = [responseDict objectForKeyNotNull:pJobName expectedObj:@""];
    userInfoObject.onGoingJobArray = [NSMutableArray array];
    
    NSArray *serviceArray = [responseDict objectForKeyNotNull:pOnGoingJob expectedObj:[NSArray array]];
    
    for (NSDictionary *serviceDict in serviceArray) {
        [userInfoObject.onGoingJobArray addObject:[OnGoingjobDetails parseResponseOnGoingjobDetails:serviceDict]];
    }
    
    NSString *profileImg = [responseDict objectForKeyNotNull:pProfileImage expectedObj:@""];
    if ([profileImg length]) {
        NSOperationQueue *operationProfileImage = [NSOperationQueue new];
        [operationProfileImage addOperationWithBlock:^{
            userInfoObject.strUpload = [profileImg getBase64StringFromURI];
        }];
    }
    else
        userInfoObject.strUpload = @"";
        
    userInfoObject.strUploadURL = [NSURL URLWithString:profileImg];

    NSString *documentImg = [responseDict objectForKeyNotNull:pExperienceDocument expectedObj:@""];
    
    NSOperationQueue *operationDocumentImage = [NSOperationQueue new];
    [operationDocumentImage addOperationWithBlock:^{
        userInfoObject.strDocumentUpload = [documentImg getBase64StringFromURI];
    }];
    userInfoObject.strDocumentUploadURL = [NSURL URLWithString:documentImg];

    userInfoObject.sampleImageArray = [NSMutableArray array];
    userInfoObject.sampleImageArrayURL = [NSMutableArray array];

    NSArray *sampleImgArray = [responseDict objectForKeyNotNull:pImage expectedObj:[NSArray array]];
    
    for (NSDictionary *dict in sampleImgArray) {
        NSString *imageStr = [dict objectForKeyNotNull:pImage expectedObj:[NSString string]];
        [userInfoObject.sampleImageArrayURL addObject:[NSURL URLWithString:imageStr]];
        NSOperationQueue *operationQueueObj = [NSOperationQueue new];
        [operationQueueObj addOperationWithBlock:^{
            [userInfoObject.sampleImageArray addObject:[imageStr getBase64StringFromURI]];
        }];
    }

    return userInfoObject;
}

@end

@implementation OnGoingjobDetails

+(OnGoingjobDetails *)parseResponseOnGoingjobDetails:(NSDictionary *)jobDict {
    OnGoingjobDetails *jobDetail = [[OnGoingjobDetails alloc]init];
    
    jobDetail.comingJobName = [jobDict objectForKeyNotNull:pJobName expectedObj:@""];
    jobDetail.latitude = [jobDict objectForKeyNotNull:@"latitude" expectedObj:@""];
    jobDetail.longitude = [jobDict objectForKeyNotNull:@"longitude" expectedObj:@""];

    NSString *serviceStartingDate = [jobDict objectForKeyNotNull:@"created_on" expectedObj:@""];

    jobDetail.comingDate = [AppUtilityFile convertTimeStampIntoDate:serviceStartingDate];
    
    return jobDetail;
}

@end

@implementation JobRequest


@end
