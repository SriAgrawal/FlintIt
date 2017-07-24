        //
//  RowDataModal.m
//  iOSBackendDevelopment
//
//  Created by Abhishek Agarwal on 05/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "RowDataModal.h"
#import "NSDictionary+NullChecker.h"
#import "DTConstants.h"
#import "AppUtilityFile.h"
#import "MacroFile.h"

@implementation RowDataModal

+(RowDataModal *)parseCatagoryList:(NSDictionary *)catagoryList comingFromServiceTracking:(BOOL)isfromServiceTracking {
    
    RowDataModal *catagoryRowData = [[RowDataModal alloc]init];    
//    catagoryRowData.isProviderSelected = NO;
    
    catagoryRowData.userName = [catagoryList objectForKeyNotNull:pUserName expectedObj:@""];
    catagoryRowData.userAddress = [catagoryList objectForKeyNotNull:pAddress expectedObj:@""];
    catagoryRowData.userCatagory = [catagoryList objectForKeyNotNull:pCategory expectedObj:@""];
    
    catagoryRowData.block_status = [catagoryList objectForKeyNotNull:pblock_status expectedObj:@""];

    
    catagoryRowData.userEmail = [catagoryList objectForKeyNotNull:pEmailID expectedObj:@""];
    catagoryRowData.userAge = [catagoryList objectForKeyNotNull:pAge expectedObj:@""];
    catagoryRowData.userGender = [catagoryList objectForKeyNotNull:pGender expectedObj:@""];
    catagoryRowData.userState = [catagoryList objectForKeyNotNull:pState expectedObj:@""];
    catagoryRowData.userCountry = [catagoryList objectForKeyNotNull:pCountry expectedObj:@""];
    catagoryRowData.userContactNumber = [catagoryList objectForKeyNotNull:pContactNumber expectedObj:@""];
    catagoryRowData.userDistancePrefrence = [catagoryList objectForKeyNotNull:pDistancePreference expectedObj:@""];
    catagoryRowData.userLatitute = [catagoryList objectForKeyNotNull:@"latitude" expectedObj:@""];
    catagoryRowData.userLongitute = [catagoryList objectForKeyNotNull:@"longitude" expectedObj:@""];
    
    catagoryRowData.userPrice = [catagoryList objectForKeyNotNull:pPrice expectedObj:@""];
    catagoryRowData.userExperenceDoc = [catagoryList objectForKeyNotNull:pExperienceDocument expectedObj:@""];
    catagoryRowData.userExperenceDocURL = [NSURL URLWithString:catagoryRowData.userExperenceDoc];
    catagoryRowData.userSampleImage = [catagoryList objectForKeyNotNull:pImage expectedObj:[NSArray array]];
    catagoryRowData.userDescription = [catagoryList objectForKeyNotNull:pDescription expectedObj:@""];
    catagoryRowData.userDescriptionArray = [catagoryList objectForKeyNotNull:pDescriptionArray expectedObj:[NSArray array]];
    catagoryRowData.userLanguauge = [catagoryList objectForKeyNotNull:pLanguage expectedObj:@""];
    catagoryRowData.userAvailabilty = [[catagoryList objectForKeyNotNull:pAvailability expectedObj:@""] boolValue];
    catagoryRowData.userID = [catagoryList objectForKeyNotNull:pUserId expectedObj:@""] ;
    catagoryRowData.FavouriteID = [catagoryList objectForKeyNotNull:pFavouriteID expectedObj:@""];
    catagoryRowData.userImage = [catagoryList objectForKeyNotNull:pProfileImage expectedObj:@""];
    catagoryRowData.userProfileImageURL = [NSURL URLWithString:catagoryRowData.userImage];
    catagoryRowData.userSampleImage = [[NSMutableArray alloc]init];
    catagoryRowData.userSampleImage = [catagoryList objectForKeyNotNull:@"image" expectedObj:[NSArray array]];
    catagoryRowData.jobID = [catagoryList objectForKeyNotNull:pJobId expectedObj:@""];
    
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"All",@"Bodyguards",@"Chefs",@"Clean Worker",@"Consultation",@"Gardener",@"Decoration",@"Moving",@"Painter",@"Plumber",@"Towing",@"Carpenter",@"IT",@"Exterminator",@"Electrician",@"Mechanic",@"Health",@"Beauty",@"Tutor",@"Tailor",@"Snow Shoveling",@"Car wash",@"Photographer",@"Fun & Party",@"Black Smithy",@"Artist",@"Air Cooling",nil];
    NSArray *imageArray = [[NSArray alloc]initWithObjects:@"all",@"icn",@"chef_icon",@"clean_icon",@"icn2",@"gandener_icon",@"decoration_icon",@"moving_icon",@"painter_icon",@"plumber_icon",@"towing_icon",@"carpenter_icon",@"IT_icon",@"extermintor_icon",@"electrician_icon",@"m",@"health_icon1",@"beauty_icon",@"tutor_icon",@"tailor_icon",@"snow_icon",@"car_wash_icon",@"photo",@"fun_icon",@"smithy_icon",@"draw_icon",@"micn2",nil];
    
    NSInteger catagoryInTitleArray = [titleArray indexOfObject:[[catagoryRowData.userCatagory componentsSeparatedByString:@","] firstObject]];
    
    catagoryRowData.userCatagoryImage = (catagoryInTitleArray < [imageArray count])?[imageArray objectAtIndex:catagoryInTitleArray]:@"all";
    
    
    // added code for multipe jobs and icon.
    NSArray * arrayOfSelectedCategory = [catagoryRowData.userCatagory componentsSeparatedByString:@","];
    
    if ([arrayOfSelectedCategory count]>1) {
        catagoryRowData.userCatagoryImage = @"cir.png";
        catagoryRowData.userCatagory = @"Multiple Jobs";
    }
    
    
    
    catagoryRowData.ratingNumber = [[catagoryList objectForKeyNotNull:pRating expectedObj:@""] integerValue];
    catagoryRowData.reviewDetail = [NSString stringWithFormat:@"%@ Reviews",[catagoryList objectForKeyNotNull:pTotalReview expectedObj:@""]];

    NSString *totalWorked = [catagoryList objectForKeyNotNull:pTotalWork expectedObj:@""];
    
    if([TRIM_SPACE(totalWorked) length] == 0)
         catagoryRowData.userNumberFollowed = @"0, Worked";
    else
        catagoryRowData.userNumberFollowed = [NSString stringWithFormat:@"%@, Worked",[catagoryList objectForKeyNotNull:pTotalWork expectedObj:@""]];


//  catagoryRowData.userNumberFollowed = [NSString stringWithFormat:@"%@, Worked",[catagoryList objectForKeyNotNull:pTotalWork expectedObj:@""]];
    catagoryRowData.userDistance = [catagoryList objectForKeyNotNull:pDistance expectedObj:@""];
    
   catagoryRowData.jobStatusString = [catagoryList objectForKeyNotNull:pJobStatus expectedObj:@""];
    if (catagoryRowData.jobStatusString.length <= 0){
        NSArray *arr = [catagoryList objectForKeyNotNull:@"ongoing_job" expectedObj:[NSArray array]];
        NSDictionary *dict = [arr firstObject];
        catagoryRowData.jobStatusString = [dict objectForKeyNotNull:@"status" expectedObj:@""];
        
        //adding valuest to jobID
        catagoryRowData.jobID = [dict objectForKeyNotNull:pJobId expectedObj:@""];
        catagoryRowData.clientID = [dict objectForKeyNotNull:pClientID expectedObj:@""];

        catagoryRowData.clientPrice = [dict objectForKeyNotNull:pPrice expectedObj:@""];
        catagoryRowData.jobdescription = [dict objectForKeyNotNull:pJobDescription expectedObj:@""];
        catagoryRowData.jobName = [dict objectForKeyNotNull:pJobName expectedObj:@""];

        catagoryRowData.ServiceProviderId = [dict objectForKeyNotNull:@"service_provider_id" expectedObj:@""];
        catagoryRowData.serviceProviderLatitude = [dict objectForKeyNotNull:@"latitude" expectedObj:@""];
        catagoryRowData.serviceProviderLongitude = [dict objectForKeyNotNull:@"longitude" expectedObj:@""];
        
        if ([ catagoryRowData.jobStatusString isEqualToString:@"pending"]) {
            catagoryRowData.userJobStatus = KNSLOCALIZEDSTRING(@"Cancel Job Request");
        }else if ([ catagoryRowData.jobStatusString isEqualToString:@"completed"] || [ catagoryRowData.jobStatusString isEqualToString:@"accepted"]) {
            catagoryRowData.userJobStatus = KNSLOCALIZEDSTRING(@"On Going Job");
        }else if ([ catagoryRowData.jobStatusString isEqualToString:@"approved"] || [ catagoryRowData.jobStatusString isEqualToString:@"canceled"] || [TRIM_SPACE( catagoryRowData.jobStatusString) length] == 0 || [catagoryRowData.jobStatusString isEqualToString:@"decline"]||[catagoryRowData.jobStatusString isEqualToString:@"unapproved"]) {
            catagoryRowData.userJobStatus = KNSLOCALIZEDSTRING(@"Send Hiring Request");
        }
    }else{
    
    if ([ catagoryRowData.jobStatusString isEqualToString:@"pending"]) {
        catagoryRowData.userJobStatus = @"Cancel Job Request";
    }else if ([ catagoryRowData.jobStatusString isEqualToString:@"completed"] || [ catagoryRowData.jobStatusString isEqualToString:@"accepted"]) {
        catagoryRowData.userJobStatus = @"On Going Job";
    }else if ([ catagoryRowData.jobStatusString isEqualToString:@"approved"] || [ catagoryRowData.jobStatusString isEqualToString:@"canceled"] || [TRIM_SPACE( catagoryRowData.jobStatusString) length] == 0 || [catagoryRowData.jobStatusString isEqualToString:@"decline"]|| [catagoryRowData.jobStatusString isEqualToString:@"unapproved"]) {
        catagoryRowData.userJobStatus = @"Send Hiring Request";
    }
    }
    
    catagoryRowData.isTakenFirstJob = [[catagoryList objectForKeyNotNull:pIsTakenFirstJob expectedObj:@""] boolValue];
    catagoryRowData.isAlreadyFavourite = [[catagoryList objectForKeyNotNull:pIsAlreadyFavourite expectedObj:@""] boolValue];

    
    // Parsing service provider response data.
    if(isfromServiceTracking){
        
        catagoryRowData.serviceName = [catagoryList objectForKeyNotNull:pJobName expectedObj:@""];
        catagoryRowData.jobID = [catagoryList objectForKeyNotNull:pJobId expectedObj:@""];
        catagoryRowData.clientID = [catagoryList objectForKeyNotNull:pClientID expectedObj:@""];
        
        catagoryRowData.ServiceProviderId = [catagoryList objectForKeyNotNull:pServicePrividerID expectedObj:@""];
        
        catagoryRowData.serviceProviderName = [catagoryList objectForKeyNotNull:pServicePrividerName expectedObj:@""];
        catagoryRowData.serviceDistanceDetail = [catagoryList objectForKeyNotNull:pDistance expectedObj:@""];
        
        catagoryRowData.serviceStartTime = [catagoryList objectForKeyNotNull:pCreatedOn expectedObj:@""];
        catagoryRowData.serviceContactNumber = [catagoryList objectForKeyNotNull:pContactNumber expectedObj:@""];
        catagoryRowData.serviceDate = [AppUtilityFile convertTimeStampIntoDate:catagoryRowData.serviceStartTime];
        catagoryRowData.serviceTime = [AppUtilityFile convertingTimeStampIntoTime:catagoryRowData.serviceStartTime];
        catagoryRowData.serviceTimeLeft = [catagoryList objectForKeyNotNull:pDuration expectedObj:@""];
//        catagoryRowData.serviceProviderCategoryName = [catagoryList objectForKeyNotNull:pCatagoryName expectedObj:@""];
//        catagoryRowData.ClientLatitude = [catagoryList objectForKeyNotNull:@"latitude" expectedObj:@""];
//        catagoryRowData.ClientLongitude = [catagoryList objectForKeyNotNull:@"longitude" expectedObj:@""];
        
        NSArray *titleArray = [[NSArray alloc]initWithObjects:@"All",@"Bodyguards",@"Chefs",@"Clean Worker",@"Consultation",@"Gardener",@"Decoration",@"Moving",@"Painter",@"Plumber",@"Towing",@"Carpenter",@"IT",@"Exterminator",@"Electrician",@"Mechanic",@"Health",@"Beauty",@"Tutor",@"Tailor",@"Snow Shoveling",@"Car wash",@"Photographer",@"Fun & Party",@"Black Smithy",@"Artist",@"Air Cooling",nil];
        NSArray *imageArray = [[NSArray alloc]initWithObjects:@"all",@"icn",@"chef_icon",@"clean_icon",@"icn2",@"gandener_icon",@"decoration_icon",@"moving_icon",@"painter_icon",@"plumber_icon",@"towing_icon",@"carpenter_icon",@"IT_icon",@"extermintor_icon",@"electrician_icon",@"m",@"health_icon1",@"beauty_icon",@"tutor_icon",@"tailor_icon",@"snow_icon",@"car_wash_icon",@"photo",@"fun_icon",@"smithy_icon",@"draw_icon",@"micn2",nil];
        
        NSString *str = [[catagoryRowData.serviceProviderCategoryName componentsSeparatedByString:@","] firstObject];
        NSInteger catagoryInTitleArray = [titleArray indexOfObject:str];
        
        catagoryRowData.serviceProviderCategoryImage = (catagoryInTitleArray < [imageArray count])?[imageArray objectAtIndex:catagoryInTitleArray]:@"all";
    }
    
    NSDictionary *dictOngoing = [[catagoryList objectForKeyNotNull:pOnGoingJob expectedObj:[NSArray array]] firstObject];
    
    if(dictOngoing) {
        catagoryRowData.serviceName = [dictOngoing objectForKeyNotNull:pJobName expectedObj:@""];
        catagoryRowData.userPrice = [dictOngoing objectForKeyNotNull:pPrice expectedObj:@""];
        catagoryRowData.userLatitute = [catagoryList objectForKeyNotNull:@"latitude" expectedObj:@""];
        catagoryRowData.userLongitute = [catagoryList objectForKeyNotNull:@"longitude" expectedObj:@""];
    }
    return catagoryRowData;
}

+(RowDataModal *)parseJobRequestList:(NSDictionary *)JobRequestList {
    
    RowDataModal *jobRequestRowData = [[RowDataModal alloc]init];
    jobRequestRowData.userID = [JobRequestList objectForKeyNotNull:pUserId expectedObj:@""] ;
    jobRequestRowData.userName = [JobRequestList objectForKeyNotNull:pUserName expectedObj:@""];
    jobRequestRowData.userEmail = [JobRequestList objectForKeyNotNull:pEmailID expectedObj:@""];
    jobRequestRowData.userAge = [JobRequestList objectForKeyNotNull:pAge expectedObj:@""];
    jobRequestRowData.userGender = [JobRequestList objectForKeyNotNull:pGender expectedObj:@""];
    jobRequestRowData.starRating = [JobRequestList objectForKeyNotNull:pRating expectedObj:@""];
    jobRequestRowData.userState = [JobRequestList objectForKeyNotNull:pState expectedObj:@""];
    jobRequestRowData.userCountry = [JobRequestList objectForKeyNotNull:pCountry expectedObj:@""];
    jobRequestRowData.userContactNumber = [JobRequestList objectForKeyNotNull:pContactNumber expectedObj:@""];
    jobRequestRowData.block_status = [JobRequestList objectForKeyNotNull:pblock_status expectedObj:@""];

    jobRequestRowData.serviceStartTime = [JobRequestList objectForKeyNotNull:pCreatedOn expectedObj:@""];
    jobRequestRowData.serviceDate = [AppUtilityFile convertTimeStampIntoDate:jobRequestRowData.serviceStartTime];
    jobRequestRowData.serviceTime = [AppUtilityFile convertingTimeStampIntoTime:jobRequestRowData.serviceStartTime];

    jobRequestRowData.userLatitute = [JobRequestList objectForKeyNotNull:pLattitue expectedObj:@""];
    jobRequestRowData.userLongitute = [JobRequestList objectForKeyNotNull:pLongitute expectedObj:@""];
    jobRequestRowData.jobID = [JobRequestList objectForKeyNotNull:pJobId expectedObj:@""];
    jobRequestRowData.jobName = [JobRequestList objectForKeyNotNull:pJobName expectedObj:@""];
    jobRequestRowData.jobdescription = [JobRequestList objectForKeyNotNull:pJobDescription expectedObj:@""];
    jobRequestRowData.userPrice = [JobRequestList objectForKeyNotNull:pPrice expectedObj:@""];
    jobRequestRowData.userAddress = [JobRequestList objectForKeyNotNull:pAddress expectedObj:@""];
    jobRequestRowData.userImage = [JobRequestList objectForKeyNotNull:pProfileImage expectedObj:@""];
    jobRequestRowData.userProfileImageURL = [NSURL URLWithString:jobRequestRowData.userImage];
    
    NSString *jobStatusString = [JobRequestList objectForKeyNotNull:pJobStatus expectedObj:@""];
    
    if ([jobStatusString isEqualToString:@"pending"]) {
        jobRequestRowData.userJobStatus = @"Cancel Job Request";
    }else if ([jobStatusString isEqualToString:@"completed"]) {
        jobRequestRowData.userJobStatus = @"On Going Job";
    }else if ([jobStatusString isEqualToString:@"approved"] || [jobStatusString isEqualToString:@"canceled"] || [TRIM_SPACE(jobStatusString) length] == 0  || [jobStatusString isEqualToString:@"decline"] || [jobStatusString isEqualToString:@"unapproved"]) {
        jobRequestRowData.userJobStatus = @"Send Hiring Request";
    }

    return jobRequestRowData;
}

+(RowDataModal *)parseListOfChatUsers:(NSDictionary *)userList{
    RowDataModal *tempModel = [[RowDataModal alloc]init];
    tempModel.userID = [userList objectForKeyNotNull:@"userid" expectedObj:@""] ;
    tempModel.userName = [userList objectForKeyNotNull:@"name" expectedObj:@""];
    tempModel.messageTime = [userList objectForKeyNotNull:@"time" expectedObj:@""];
    tempModel.userImage = [userList objectForKeyNotNull:@"profile_url" expectedObj:@""];
    
    
    if ([[userList objectForKeyNotNull:@"type" expectedObj:@""] isEqualToString:@"message"]) {
        tempModel.message = [userList objectForKeyNotNull:@"message" expectedObj:@""];
    }else{
        tempModel.message = @"";
    }
    
    return tempModel;
}

+(RowDataModal *)parseServiceTrackingForProviderLocationWithDict :(NSDictionary *)serviceDict isFromClient:(BOOL)status {
    
    RowDataModal *serviceTrackingDetail = [[RowDataModal alloc]init];
    if (status) {
        serviceTrackingDetail.userLatitute = [serviceDict objectForKeyNotNull:pServiceProviderLatitude expectedObj:@""];
        serviceTrackingDetail.userLongitute = [serviceDict objectForKeyNotNull:pServiceProviderLongitude expectedObj:@""];
    }else
    {
        serviceTrackingDetail.serviceProviderLatitude = [serviceDict objectForKeyNotNull:pClientLatitude expectedObj:@""];
        serviceTrackingDetail.serviceProviderLongitude = [serviceDict objectForKeyNotNull:pClientLongitude expectedObj:@""];
    }
    
    //    serviceTrackingDetail.serviceProviderLatitude = [serviceList objectForKeyNotNull:pServiceProviderLatitude expectedObj:@""];
    //    serviceTrackingDetail.serviceProviderLongitude = [serviceList objectForKeyNotNull:pServiceProviderLongitude expectedObj:@""];
    serviceTrackingDetail.serviceTime = [serviceDict objectForKeyNotNull:pTime expectedObj:@""];
    serviceTrackingDetail.serviceDistanceDetail = [serviceDict objectForKeyNotNull:pDistance expectedObj:@""];
    
    return serviceTrackingDetail;
}

-(void)getUserAddressFromObjModal:(RowDataModal *)addressModal  completionHandler:(void (^)(void))completionBlock {
    
    
    
    // Your location from latitude and longitude
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[addressModal.userLatitute doubleValue] longitude:[addressModal.userLongitute doubleValue]];
    //  __block NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
    __block NSString *str = nil;
    // Call the method to find the address
    
    [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
        
        if ([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length] && [[d valueForKey:@"Street"] length]) {
            str = [NSString stringWithFormat:@"%@, %@, %@ , %@",[d valueForKey:@"City"],[d valueForKey:@"State"],[d valueForKey:@"Country"],[d valueForKey:@"Street"]];
        }
        else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"City"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"City"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"State"] length] && [[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@, %@",[d valueForKey:@"State"],[d valueForKey:@"Country"]];
        }else if([[d valueForKey:@"City"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"City"]];
        }else if([[d valueForKey:@"State"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"State"]];
        }else if([[d valueForKey:@"Country"] length]){
            str = [NSString stringWithFormat:@"%@",[d valueForKey:@"Country"]];
        }else{
            str = @"";
        }
        
        addressModal.userLocationName = str;
        addressModal.isLocationFetched = YES;
        completionBlock();
        
    } failureHandler:^(NSError *error) {
        
        
    }];
    
    
    
}

- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler{
    // NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler([NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary]);
            }
        }
    }];
}

@end

@implementation ServiceTrackingModal

+(ServiceTrackingModal *)parseServiceListClient:(NSDictionary *)serviceList {
    
    ServiceTrackingModal *serviceDataDetail = [[ServiceTrackingModal alloc]init];
// currently in use by tracking
    serviceDataDetail.serviceName = [serviceList objectForKeyNotNull:pJobName expectedObj:@""];
    serviceDataDetail.jobID = [serviceList objectForKeyNotNull:pJobId expectedObj:@""];
    serviceDataDetail.clientID = [serviceList objectForKeyNotNull:pClientID expectedObj:@""];

    serviceDataDetail.ServiceProviderId = [serviceList objectForKeyNotNull:pServicePrividerID expectedObj:@""];

    serviceDataDetail.serviceProviderName = [serviceList objectForKeyNotNull:pServicePrividerName expectedObj:@""];
    serviceDataDetail.serviceDistanceDetail = [serviceList objectForKeyNotNull:pDistance expectedObj:@""];
    
    serviceDataDetail.serviceStartTime = [serviceList objectForKeyNotNull:pCreatedOn expectedObj:@""];
    serviceDataDetail.serviceContactNumber = [serviceList objectForKeyNotNull:pContactNumber expectedObj:@""];
    serviceDataDetail.serviceDate = [AppUtilityFile convertTimeStampIntoDate:serviceDataDetail.serviceStartTime];
    serviceDataDetail.serviceTime = [AppUtilityFile convertingTimeStampIntoTime:serviceDataDetail.serviceStartTime];
    serviceDataDetail.serviceTimeLeft = [serviceList objectForKeyNotNull:pDuration expectedObj:@""];
    serviceDataDetail.serviceProviderCategoryName = [serviceList objectForKeyNotNull:pCatagoryName expectedObj:@""];
    serviceDataDetail.ClientLatitude = [serviceList objectForKeyNotNull:@"latitude" expectedObj:@""];
    serviceDataDetail.ClientLongitude = [serviceList objectForKeyNotNull:@"longitude" expectedObj:@""];

    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"All",@"Bodyguards",@"Chefs",@"Clean Worker",@"Consultation",@"Gardener",@"Decoration",@"Moving",@"Painter",@"Plumber",@"Towing",@"Carpenter",@"IT",@"Exterminator",@"Electrician",@"Mechanic",@"Health",@"Beauty",@"Tutor",@"Tailor",@"Snow Shoveling",@"Car wash",@"Photographer",@"Fun & Party",@"Black Smithy",@"Artist",@"Air Cooling",nil];
    NSArray *imageArray = [[NSArray alloc]initWithObjects:@"all",@"icn",@"chef_icon",@"clean_icon",@"icn2",@"gandener_icon",@"decoration_icon",@"moving_icon",@"painter_icon",@"plumber_icon",@"towing_icon",@"carpenter_icon",@"IT_icon",@"extermintor_icon",@"electrician_icon",@"m",@"health_icon1",@"beauty_icon",@"tutor_icon",@"tailor_icon",@"snow_icon",@"car_wash_icon",@"photo",@"fun_icon",@"smithy_icon",@"draw_icon",@"micn2",nil];
    NSString *str = [[serviceDataDetail.serviceProviderCategoryName componentsSeparatedByString:@","] firstObject];
    NSInteger catagoryInTitleArray = [titleArray indexOfObject:str];
    
    serviceDataDetail.serviceProviderCategoryImage = (catagoryInTitleArray < [imageArray count])?[imageArray objectAtIndex:catagoryInTitleArray]:@"all";


    
    return serviceDataDetail;
}

+(ServiceTrackingModal *)parseServiceListService:(NSDictionary *)serviceList {
    ServiceTrackingModal *serviceDataDetail = [[ServiceTrackingModal alloc]init];
    
    serviceDataDetail.profileImage = [serviceList objectForKeyNotNull:pProfileImage expectedObj:@""];
    serviceDataDetail.serviceName = [serviceList objectForKeyNotNull:pJobName expectedObj:@""];
    serviceDataDetail.clientName = [serviceList objectForKeyNotNull:pClientName expectedObj:@""];
    serviceDataDetail.jobID = [serviceList objectForKeyNotNull:pJobId expectedObj:@""];
    serviceDataDetail.ServiceProviderId = [serviceList objectForKeyNotNull:pServicePrividerID expectedObj:@""];
    serviceDataDetail.clientID = [serviceList objectForKeyNotNull:pClientID expectedObj:@""];

    serviceDataDetail.serviceProviderName = [serviceList objectForKeyNotNull:pServicePrividerName expectedObj:@""];
    serviceDataDetail.serviceDistanceDetail = [serviceList objectForKeyNotNull:pDistance expectedObj:@""];
    
    serviceDataDetail.serviceStartTime = [serviceList objectForKeyNotNull:pCreatedOn expectedObj:@""];
    
    serviceDataDetail.serviceDate = [AppUtilityFile convertTimeStampIntoDate:serviceDataDetail.serviceStartTime];
    serviceDataDetail.serviceTime = [AppUtilityFile convertingTimeStampIntoTime:serviceDataDetail.serviceStartTime];
    serviceDataDetail.serviceTimeLeft = [serviceList objectForKeyNotNull:pDuration expectedObj:@""];
     serviceDataDetail.serviceContactNumber = [serviceList objectForKeyNotNull:pContactNumber expectedObj:@""];
    serviceDataDetail.serviceProviderLatitude = [serviceList objectForKeyNotNull:pLattitue expectedObj:@""];
    serviceDataDetail.serviceProviderLongitude = [serviceList objectForKeyNotNull:pLongitute expectedObj:@""];
    
    serviceDataDetail.jobLatestStatus = [serviceList objectForKeyNotNull:pJobStatus expectedObj:@""];

    
    return serviceDataDetail;
}

//+(ServiceTrackingModal *)parseServiceTracking:(NSDictionary *)serviceList isFromClient:(BOOL)status {
//    
//    ServiceTrackingModal *serviceTrackingDetail = [[ServiceTrackingModal alloc]init];
//    if (status) {
//        serviceTrackingDetail.ClientLatitude = [serviceList objectForKeyNotNull:pServiceProviderLatitude expectedObj:@""];
//        serviceTrackingDetail.ClientLongitude = [serviceList objectForKeyNotNull:pServiceProviderLongitude expectedObj:@""];
//    }else
//    {
//        serviceTrackingDetail.serviceProviderLatitude = [serviceList objectForKeyNotNull:pClientLatitude expectedObj:@""];
//        serviceTrackingDetail.serviceProviderLongitude = [serviceList objectForKeyNotNull:pClientLongitude expectedObj:@""];
//    }
//
////    serviceTrackingDetail.serviceProviderLatitude = [serviceList objectForKeyNotNull:pServiceProviderLatitude expectedObj:@""];
////    serviceTrackingDetail.serviceProviderLongitude = [serviceList objectForKeyNotNull:pServiceProviderLongitude expectedObj:@""];
//    serviceTrackingDetail.serviceTime = [serviceList objectForKeyNotNull:pTime expectedObj:@""];
//    serviceTrackingDetail.serviceDistanceDetail = [serviceList objectForKeyNotNull:pDistance expectedObj:@""];
//
//    return serviceTrackingDetail;
//}



@end
