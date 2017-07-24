//
//  UserInfo.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 23/03/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserInfo : NSObject

//Login
@property (strong,nonatomic) NSString *strEmail;
@property (strong,nonatomic) NSString *strPassword;

//Sign Up
@property (strong,nonatomic) NSString *strUsername;
@property (strong,nonatomic) NSString *strEmailAddress;
@property (strong,nonatomic) NSString *strPswrd;
@property (strong,nonatomic) NSString *strConfirmPswrd;
@property (strong,nonatomic) NSString *strAge;
@property (strong,nonatomic) NSString *strLocation;
@property (strong,nonatomic) NSString *strAddress;
@property (strong,nonatomic) NSString *strContact;
@property (strong,nonatomic) NSString *strOTP;
@property (strong,nonatomic) NSString *strDistance;
@property (strong,nonatomic) NSString *strCategory;
@property (strong,nonatomic) NSString *strLanguage;
@property (strong,nonatomic) NSString *strPrice;
@property (strong,nonatomic) NSString *strGender;
@property (strong,nonatomic) NSString *strDescription;
@property (strong,nonatomic) NSString *strPhonePrefix;
@property (strong,nonatomic) NSString *strBlockTime;


@property (strong,nonatomic) NSString *strUpload;
@property (strong,nonatomic) NSURL *strUploadURL;

@property (strong,nonatomic) NSString *strDocumentUpload;
@property (strong,nonatomic) NSURL *strDocumentUploadURL;

@property (strong,nonatomic) NSMutableArray *sampleImageArray;
@property (strong,nonatomic) NSMutableArray *sampleImageArrayURL;
@property (strong,nonatomic) NSMutableArray *onGoingJobArray;
@property (strong,nonatomic) NSString *strJobName;

//For Filter
@property (strong,nonatomic) NSString *strFilterByPrice;
@property (strong,nonatomic) NSString *strFilterByDistance;
@property (strong,nonatomic) NSString *strFilterByRatings;
@property (strong,nonatomic) NSString *strFilterByJobs;
@property (assign,nonatomic) BOOL    isAvailability;

//For Change Password
@property (strong,nonatomic) NSString *strOldPassword;
@property (strong,nonatomic) NSString *strNewPassword;
@property (strong,nonatomic) NSString *strConfirmPassword;

//For Availability status
@property (strong,nonatomic) NSString *strUserID;
@property (strong,nonatomic) NSString *strAvailabe;

//For Social Login
@property (strong,nonatomic) NSString *strSocialType;

//For Email 
@property (strong,nonatomic) NSString *strMessage;

@property (strong, nonatomic) UIImage *flagImage;

@property (strong,nonatomic) NSString *strServiceName;
@property (strong,nonatomic) NSString *strDateOfBirth;

@property (strong,nonatomic) NSString *strImageType;

+(UserInfo *)parseResponseForProfileDetail:(NSDictionary *)responseDict;

@end

@interface OnGoingjobDetails : NSObject

@property (strong, nonatomic) NSString *comingDate;
@property (strong, nonatomic) NSString *comingJobName;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;


+(OnGoingjobDetails *)parseResponseOnGoingjobDetails:(NSDictionary *)jobDict;

@end

@interface JobRequest : NSObject

@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) NSString *jobDecription;
@property (strong, nonatomic) NSString *pricePaid;

@end

