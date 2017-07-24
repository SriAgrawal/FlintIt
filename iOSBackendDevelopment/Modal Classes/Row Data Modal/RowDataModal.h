//
//  RowDataModal.h
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 05/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RowDataModal : NSObject

@property (strong,nonatomic) NSString *userName;
@property (assign,nonatomic) NSInteger ratingNumber;
@property (strong,nonatomic) NSString *reviewDetail;
@property (strong,nonatomic) NSString *userAddress;
@property (strong,nonatomic) NSString *userCatagory;
@property (strong,nonatomic) NSString *userImage;
@property (strong,nonatomic) UIImage *userImageObject;
@property (strong,nonatomic) NSString *userCatagoryImage;
@property (strong,nonatomic) NSString *userNumberFollowed;
@property (strong,nonatomic) NSString *userDistance;

@property (strong,nonatomic) NSString *block_status;


@property (strong,nonatomic) NSString *clientPrice;
@property (strong,nonatomic) NSString *userEmail;
@property (strong,nonatomic) NSString *userAge;
@property (strong,nonatomic) NSString *userGender;
@property (strong,nonatomic) NSString *userState;
@property (strong,nonatomic) NSString *userCountry;
@property (strong,nonatomic) NSString *userContactNumber;
@property (strong,nonatomic) NSURL    *userProfileImageURL;
@property (strong,nonatomic) NSString *userDistancePrefrence;
@property (strong,nonatomic) NSString *userLatitute;
@property (strong,nonatomic) NSString *userLongitute;
@property (strong, nonatomic) NSString *userLocationName;
@property (strong,nonatomic) NSString *userPrice;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *userExperenceDoc;
@property (strong,nonatomic) NSURL    *userExperenceDocURL;
@property (strong,nonatomic) NSMutableArray    *userSampleImage;
@property (strong,nonatomic) NSString *userDescription;
@property (strong,nonatomic) NSString *userJobStatus;
@property (strong,nonatomic) NSString *jobStatusString;
@property (strong,nonatomic) NSArray  *userDescriptionArray;
@property (strong,nonatomic) NSString *userLanguauge;
@property (assign,nonatomic) BOOL     userAvailabilty;
@property (assign,nonatomic) BOOL     isTakenFirstJob;
@property (assign,nonatomic) BOOL     isAlreadyFavourite;
@property (strong,nonatomic) NSString *starRating;
@property (assign,nonatomic) NSInteger selectedServiceProviderIndex;
@property (strong,nonatomic) NSString *jobID;
@property (strong,nonatomic) NSString *jobName;
@property (strong,nonatomic) NSString *jobdescription;
@property (strong,nonatomic) NSString *userStatus;
@property (strong,nonatomic) NSString *sampleImage;
@property (strong,nonatomic) NSString *FavouriteID;

// temporary

@property (assign,nonatomic) NSUInteger index;


//Message related attributes
@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSString *messageTime;
@property (strong,nonatomic) NSString *profileImage;

@property (assign,nonatomic) BOOL     isProviderSelected;
@property (assign,nonatomic) BOOL     isBlockStatus;
@property (assign,nonatomic) BOOL     isLocationFetched;



//
@property (strong,nonatomic) NSString *serviceName;
@property (strong,nonatomic) NSString *clientName;
@property (strong,nonatomic) NSString *clientID;
@property (strong,nonatomic) NSString *serviceProviderName;
@property (strong,nonatomic) NSString *serviceDistanceDetail;
@property (strong,nonatomic) NSString *serviceStartTime;
@property (strong,nonatomic) NSString *serviceDate;
@property (strong,nonatomic) NSString *serviceContactNumber;
@property (strong,nonatomic) NSString *serviceTime;
@property (strong,nonatomic) NSString *serviceTimeLeft;
@property (strong,nonatomic) NSString *serviceProviderCategoryName;
@property (strong,nonatomic) NSString *serviceProviderCategoryImage;
@property (assign,nonatomic) NSInteger selectedIndex;
//@property (strong,nonatomic) NSString *jobID;
@property (strong,nonatomic) NSString *ServiceProviderId;
@property (strong,nonatomic) NSString *serviceProviderLatitude;
@property (strong,nonatomic) NSString *serviceProviderLongitude;
@property (strong,nonatomic) NSString *ClientLongitude;
@property (strong,nonatomic) NSString *ClientLatitude;

//+(RowDataModal *)parseCatagoryList:(NSDictionary *)catagoryList;
+(RowDataModal *)parseCatagoryList:(NSDictionary *)catagoryList comingFromServiceTracking:(BOOL)isfromServiceTracking;
+(RowDataModal *)parseJobRequestList:(NSDictionary *)JobRequestList;
+(RowDataModal *)parseListOfChatUsers:(NSDictionary *)userList;
+(RowDataModal *)parseServiceTrackingForProviderLocationWithDict :(NSDictionary *)serviceDict isFromClient:(BOOL)status;
-(void)getUserAddressFromObjModal:(RowDataModal *)addressModal  completionHandler:(void (^)(void))completionBlock;

@end

@interface ServiceTrackingModal : NSObject

@property (strong,nonatomic) NSString *serviceName;
@property (strong,nonatomic) NSString *clientName;
@property (strong,nonatomic) NSString *clientID;
@property (strong,nonatomic) NSString *serviceProviderName;
@property (strong,nonatomic) NSString *serviceDistanceDetail;
@property (strong,nonatomic) NSString *serviceStartTime;
@property (strong,nonatomic) NSString *serviceDate;
@property (strong,nonatomic) NSString *serviceContactNumber;
@property (strong,nonatomic) NSString *serviceTime;
@property (strong,nonatomic) NSString *serviceTimeLeft;
@property (strong,nonatomic) NSString *serviceProviderCategoryName;
@property (strong,nonatomic) NSString *serviceProviderCategoryImage;
@property (assign,nonatomic) NSInteger selectedIndex;
@property (strong,nonatomic) NSString *jobID;
@property (strong,nonatomic) NSString *ServiceProviderId;
@property (strong,nonatomic) NSString *serviceProviderLatitude;
@property (strong,nonatomic) NSString *serviceProviderLongitude;
@property (strong,nonatomic) NSString *ClientLongitude;
@property (strong,nonatomic) NSString *ClientLatitude;
@property (strong,nonatomic) NSString *profileImage;

@property (strong,nonatomic) NSString *jobLatestStatus;;

+(ServiceTrackingModal *)parseServiceListService:(NSDictionary *)serviceList;
+(ServiceTrackingModal *)parseServiceListClient:(NSDictionary *)serviceList;
//+(ServiceTrackingModal *)parseServiceTracking:(NSDictionary *)serviceList;
//+(ServiceTrackingModal *)parseServiceTracking:(NSDictionary *)serviceList isFromClient:(BOOL)status;




@end




