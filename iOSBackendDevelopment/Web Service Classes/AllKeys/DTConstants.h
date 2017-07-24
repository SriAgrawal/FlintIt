//
//  DTConstants.h
//  Dating Website
//
//  Created by Abhishek Agarwal on 05/29/15.
//  Copyright (c) 2014 mobiloitte. All rights reserved.
//


#import <Foundation/Foundation.h>

/*>>>>>>>>>>>>>>>>>>>>>Parameter Names>>>>>>>>>>>>>>>>>>>>>*/


extern NSString *pblock_status;
/*>>>>>>>>>Device Parameters>>>>>> */
extern  NSString *pDeviceToken;
extern  NSString *pDeviceType;
extern  NSString *pAction;
extern  NSString *pStatus;
extern  NSString *pResponse;
extern  NSString *pResponseMsg;
extern  NSString *pResponseCode;
extern  NSString *pSession;
extern  NSString *pUserId;
extern  NSString *pData ;
extern NSString *pID;

/*>>>>>>>>>Login & SignUp Parameters >>>>>> */
extern  NSString *pUserName;
extern  NSString *pEmailID;
extern  NSString *pPassword;
extern  NSString *pAge;
extern  NSString *pGender;
extern  NSString *pState;
extern  NSString *pCountry;
extern  NSString *pContactNumber;
extern  NSString *pProfileImage;
extern  NSString *pAddress;
extern  NSString *pUserType;
extern  NSString *pCountryCode;
extern  NSString *pDistancePreference;
extern  NSString *pCategory;
extern  NSString *pPrice;
extern  NSString *pExperienceDocument;
extern  NSString *pDescription;
extern  NSString *pImage;
extern  NSString *pLanguage;
extern  NSString *pImage;
extern  NSString *pNotificationStatus;
extern  NSString *pOTP ;
extern  NSString *pDisplayNumberStatus;
extern  NSString *pLattitue;
extern  NSString *pLongitute;
extern  NSString *pDescriptionArray;
extern  NSString *pServiceStatus;
extern  NSString *pServiceName;
extern  NSString *pServiceStaringDate;

/*>>>>>>>>>>>>Change Password Parameters>>>>>>>>>*/
extern  NSString *pCurrentPassword;
extern  NSString *pNewPassword;

/*>>>>>>>>>>>>Static Page Parameters>>>>>>>>>*/
extern  NSString *pPageID;

/*>>>>>>>>>>>Availability Status>>>>>>>>>>>*/
extern  NSString *pAvailability;

/*>>>>>>>>>>Social Login >>>>>>>>>>>>*/
extern  NSString *pSocialID;
extern  NSString *pSocialType;

/*>>>>>>>>>>>Catagory List>>>>>>>>>*/
extern  NSString *pCatagoryName;
extern  NSString *pPageNumber ;
extern  NSString *pPageSize;
extern  NSString *pProviderList;
extern NSString *pServiceTrackingList;
extern  NSString *pRating;
extern  NSString *pTotalReview;
extern  NSString *pTotalWork;
extern  NSString *pDistance;
extern  NSString *pJobStatus;
extern  NSString *pIsTakenFirstJob;
extern  NSString *pIsAlreadyFavourite;
extern NSString *pMaximumPageNumber;
extern NSString *pTotalNumberOfRecord;
extern NSString *pPagination;
extern NSString *pGetAll;


/*>>>>>>>>>>>Add Favourite >>>>>>>>>*/
extern  NSString *pFavouriteID;
extern  NSString *pFavourite;

/*>>>>>>>>>>> Filter >>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pPrice;
extern  NSString *pRating;
extern  NSString *pJobMax;
extern  NSString *pJobMin;

/*>>>>>>>>>>> Email Sending >>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pSender;
extern  NSString *pReceiver;
extern  NSString *pMessage;
extern  NSString *pSubject;
extern  NSString *pConversation;
extern  NSString *pEmailList;
extern  NSString *pCreatedOn;
extern  NSString *pEmailId;
extern  NSString *pId;

/*>>>>>>>>>>> All Notification >>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pNotificationDetail;
extern  NSString *pJobId;
extern  NSString *pText;
extern  NSString *pApprovedSt;
extern  NSString *pType;
extern  NSString *pCreatedAt;
extern  NSString *pUserTYpe;
/*>>>>>>>>>>> Job Request >>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pClientID;
extern  NSString *pClientName;
extern  NSString *pServicePrividerID;
extern  NSString *pJobName;
extern  NSString *pJobDescription;
extern  NSString *pServicePrividerName;
extern  NSString *pDuration ;
extern  NSString *pCancelRegion;
extern NSString *pJobRequest;

/*>>>>>>>>>>> Review List >>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pReviewList;
extern  NSString *pJobImage;
extern  NSString *pReviewID;
extern  NSString *pComment;

/*>>>>>>>>>>Report >>>>>>>>>>>>>>>>>>>>>>>*/
extern  NSString *pReportID;

/********>>Service Tracking CLient >>>>>>>>>>*****/
extern NSString *pClientLatitude;
extern NSString *pClientLongitude;
extern NSString *pServiceProviderLatitude;
extern NSString *pServiceProviderLongitude;
extern NSString *pTime;
extern NSString *pOnGoingJob;
@interface DTConstants : NSObject

@end
